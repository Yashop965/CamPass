// backend/src/controllers/pass.controller.js
const { Pass, User } = require("../models");
const { v4: uuidv4 } = require("uuid");
const { generateBarcodeImage } = require("../utils/barcode.util");

module.exports = {
  // create/generate pass (protected route)
  async generatePass(req, res) {
    try {
      const { userId, type, validFrom, validTo } = req.body;
      if (!userId || !type || !validFrom || !validTo)
        return res
          .status(400)
          .json({ message: "userId, type, validFrom, validTo required" });

      const user = await User.findByPk(userId);
      if (!user) return res.status(404).json({ message: "User not found" });

      // generate barcode string (short form if you prefer)
      const barcode = uuidv4();

      // generate barcode image (CODE128) -> writes to docs/barcodes/<barcode>.png
      const barcodeImagePath = await generateBarcodeImage(barcode);

      // create pass record
      const pass = await Pass.create({
        userId,
        type,
        purpose: req.body.purpose,
        validFrom: new Date(validFrom),
        validTo: new Date(validTo),
        barcode,
        barcodeImagePath,
        status: user.role === 'student' ? 'pending' : 'active',
      });

      // Send Notifications
      const { sendToTopic } = require('../config/firebase');

      const notification = {
        title: 'New Pass Request',
        body: `${user.name} has requested a new ${type} pass.`
      };

      const data = {
        type: 'pass_request',
        passId: pass.id,
        studentId: userId
      };

      // 1. Notify Parent (if linked)
      if (user.parentId) {
        const parentTopic = `parent_${user.parentId}_alerts`;
        await sendToTopic(parentTopic, notification, data).catch(err => console.error("Failed to notify parent:", err));
      }

      // 2. Notify Warden (General topic)
      await sendToTopic('warden_alerts', notification, data).catch(err => console.error("Failed to notify warden:", err));

      return res.status(201).json({ message: "Pass created", pass });
    } catch (err) {
      console.error("generatePass error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  // fetch pass by id (public or protected as you like)
  async getPassById(req, res) {
    try {
      const { id } = req.params;
      const pass = await Pass.findByPk(id, {
        include: [
          { model: User, as: "user", attributes: ["id", "name", "email"] },
        ],
      });
      if (!pass) return res.status(404).json({ message: "Pass not found" });
      res.json(pass);
    } catch (err) {
      console.error("getPassById error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  // scan/verify pass by barcode
  async scanPass(req, res) {
    try {
      const { barcode } = req.body;
      if (!barcode)
        return res.status(400).json({ message: "barcode required" });

      const pass = await Pass.findOne({
        where: { barcode },
        include: [
          { model: User, as: "user", attributes: ["id", "name", "email", "parentId"] },
        ],
      });
      if (!pass) return res.status(404).json({ message: "Pass not found" });

      // 'approved_parent' is an intermediate state and not valid for exit
      const validStatuses = ['active', 'approved', 'approved_warden', 'exited'];
      if (!validStatuses.includes(pass.status))
        return res.status(400).json({ message: `Pass status: ${pass.status}` });

      const now = new Date();
      // Allow 5 minutes grace period for clock skew
      const fiveMinutes = 5 * 60 * 1000;
      if (new Date(pass.validFrom) > new Date(now.getTime() + fiveMinutes))
        return res
          .status(400)
          .json({ message: "Pass not yet valid", validFrom: pass.validFrom });

      // Expiry check: Only block EXIT scan if pass is expired.
      // Entry scan (re-entry) should be allowed even if expired (Late Entry).
      if (new Date(pass.validTo) < now && !pass.exitTime)
        return res
          .status(400)
          .json({ message: "Pass expired", validTo: pass.validTo });

      // success
      // Logic for Exited/Entered toggle
      now.setTime(new Date().getTime()); // Update 'now' to current time for logic
      let scanType = '';

      if (!pass.exitTime) {
        // First scan: Marking Exit
        pass.exitTime = now;
        pass.status = 'exited';
        scanType = 'exit';
        await pass.save();
      } else if (!pass.entryTime) {
        // Second scan: Marking Entry
        pass.entryTime = now;
        pass.status = 'entered';
        scanType = 'entry';
        await pass.save();

        // Check if Late Entry
        if (now > new Date(pass.validTo)) {
          const { sendToTopic } = require('../config/firebase');
          // Format time for India (UTC+5:30) for the notification message
          const istTime = new Date(now.getTime() + (5.5 * 60 * 60 * 1000));
          const formattedTime = istTime.toISOString().substring(11, 16);

          const lateNotif = {
            title: '🚨 LATE ENTRY ALERT',
            body: `Student ${pass.user.name} LATE ENTRY at ${formattedTime}.`
          };
          const lateData = {
            type: 'late_entry',
            passId: pass.id,
            studentId: pass.userId,
            studentName: pass.user.name,
            entryTime: now.toISOString(),
            validUntil: pass.validTo.toISOString()
          };
          // Notify Wardens
          await sendToTopic('warden_alerts', lateNotif, lateData).catch(console.error);

          // Notify Parent if linked
          if (pass.user.parentId) {
            await sendToTopic(`parent_${pass.user.parentId}_alerts`, lateNotif, lateData).catch(console.error);
          }
        }
      } else {
        return res.status(400).json({ message: "Pass already used for entry" });
      }

      const passData = pass.toJSON();
      passData.studentName = pass.user?.name || null;

      return res.json({
        message: `Student ${scanType === 'exit' ? 'Exited' : 'Entered'}`,
        scanType,
        pass: passData
      });
    } catch (err) {
      console.error("scanPass error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  async getPassesByUser(req, res, next) {
    try {
      const { userId } = req.params;
      const passes = await Pass.findAll({
        where: { userId },
        order: [['createdAt', 'DESC']],
      });
      res.json(passes);
    } catch (err) {
      next(err);
    }
  },

  // approve by parent
  // approve by parent
  async approveByParent(req, res) {
    try {
      const { id } = req.params;
      const { sendToTopic, sendToDevice } = require('../config/firebase');

      const pass = await Pass.findByPk(id, {
        include: [
          { model: User, as: "user", attributes: ["id", "name", "fcm_token", "parentId"] }
        ]
      });
      if (!pass) return res.status(404).json({ message: 'Pass not found' });

      // Security Check: Ensure the requester is the parent
      if (pass.user.parentId !== req.user.id) {
        return res.status(403).json({ message: 'Unauthorized: You are not the parent of this student.' });
      }

      pass.status = 'approved_parent';
      await pass.save();

      // Notify Student
      const notification = {
        title: 'Pass Approved by Parent',
        body: 'Your outing pass has been approved by your parent.'
      };

      const data = {
        type: 'pass_approved',
        passId: pass.id,
        status: 'approved_parent'
      };

      if (pass.user.fcm_token) {
        await sendToDevice(pass.user.fcm_token, notification, data).catch(console.error);
      } else {
        await sendToTopic(`user_${pass.user.id}`, notification, data).catch(console.error);
      }

      // Notify Warden (that a pass is now ready for their approval, if logic dictates)
      // We can also notify warden that a pass IS WAITING
      const wardenNotif = {
        title: 'Pending Warden Approval',
        body: 'A pass has been approved by parent and is waiting for your approval.'
      };
      await sendToTopic('warden_alerts', wardenNotif, { type: 'pass_request' }).catch(console.error); // Reuse pass_request to trigger refresh

      return res.json({ message: 'Approved by parent', pass });
    } catch (err) {
      console.error('approveByParent error', err);
      res.status(500).json({ message: 'Server error' });
    }
  },

  // approve by warden
  async approveByWarden(req, res) {
    try {
      const { id } = req.params;
      const { sendToTopic, sendToDevice } = require('../config/firebase');

      const pass = await Pass.findByPk(id, {
        include: [
          { model: User, as: "user", attributes: ["id", "name", "fcm_token"] }
        ]
      });
      if (!pass) return res.status(404).json({ message: 'Pass not found' });

      pass.status = 'approved_warden';
      await pass.save();

      // Notify Student
      const notification = {
        title: 'Pass Approved by Warden',
        body: 'Your outing pass has been approved by the warden!'
      };

      const data = {
        type: 'pass_approved',
        passId: pass.id,
        status: 'approved_warden'
      };

      if (pass.user.fcm_token) {
        await sendToDevice(pass.user.fcm_token, notification, data).catch(console.error);
      } else {
        await sendToTopic(`user_${pass.user.id}`, notification, data).catch(console.error);
      }

      return res.json({ message: 'Approved by warden', pass });
    } catch (err) {
      console.error('approveByWarden error', err);
      res.status(500).json({ message: 'Server error' });
    }
  },

  // fetch pending passes for warden
  async getPendingWardenPasses(req, res) {
    try {
      const { Op } = require("sequelize");
      const passes = await Pass.findAll({
        where: {
          status: { [Op.in]: ['pending', 'approved_parent'] }
        },
        include: [
          { model: User, as: "user", attributes: ["id", "name", "email"] },
        ],
        order: [['createdAt', 'DESC']],
      });

      // Map to include studentName at top level for frontend
      const mappedPasses = passes.map(p => {
        const passData = p.toJSON();
        passData.studentName = passData.user?.name || null;
        return passData;
      });

      res.json(mappedPasses);
    } catch (err) {
      console.error('getPendingWardenPasses error', err);
      res.status(500).json({ message: 'Server error' });
    }
  },

  // fetch pending passes for parent
  async getPendingParentPasses(req, res) {
    try {
      const parentId = req.user.id;

      // Find children linked to this parent
      const children = await User.findAll({
        where: { parentId },
        attributes: ['id']
      });
      const childIds = children.map(c => c.id);

      if (childIds.length === 0) {
        return res.json([]); // No linked children
      }

      // Find pending OUTING passes for these children
      const passes = await Pass.findAll({
        where: {
          status: 'pending',
          userId: childIds,
          type: 'outing' // Only Outing passes for parent approval
        },
        include: [
          { model: User, as: "user", attributes: ["id", "name", "email"] },
        ],
        order: [['createdAt', 'DESC']],
      });
      res.json(passes);
    } catch (err) {
      console.error('getPendingParentPasses error', err);
      res.status(500).json({ message: 'Server error' });
    }
  },

  async getWardenPassHistory(req, res) {
    try {
      const { Op } = require("sequelize");
      // Fetch all passes that are NOT pending (completed history)
      const passes = await Pass.findAll({
        where: {
          status: { [Op.ne]: 'pending' }
        },
        include: [
          { model: User, as: "user", attributes: ["id", "name", "email"] },
        ],
        order: [['updatedAt', 'DESC']],
        limit: 100 // Limit history to last 100 entries for performance
      });


      // Map to include studentName at top level for frontend

      const mappedPasses = passes.map(p => {

        const passData = p.toJSON();

        passData.studentName = passData.user?.name || null;

        return passData;

      });



      res.json(mappedPasses);

    } catch (err) {
      console.error('getWardenPassHistory error', err);
      res.status(500).json({ message: 'Server error' });
    }
  },

  // reject pass
  async rejectPass(req, res) {
    try {
      const { id } = req.params;
      const { reason } = req.body;
      const { sendToDevice, sendToTopic } = require('../config/firebase');

      if (!reason) {
        return res.status(400).json({ message: 'Rejection reason is required' });
      }

      const pass = await Pass.findByPk(id, {
        include: [{ model: User, as: "user", attributes: ["id", "fcm_token"] }]
      });

      if (!pass) return res.status(404).json({ message: 'Pass not found' });

      // Update pass
      pass.status = 'rejected';
      pass.rejectionReason = reason;
      await pass.save();

      // Send Notification to Student
      // Use direct token if available, otherwise topic fallback (if student subscribes to their own topic)
      const studentToken = pass.user.fcm_token;

      const notification = {
        title: 'Pass Rejected',
        body: `Your pass request was rejected. Reason: ${reason}`
      };
      const data = {
        type: 'pass_rejected',
        passId: pass.id,
        reason: reason
      };

      if (studentToken) {
        await sendToDevice(studentToken, notification, data).catch(err => console.error("Failed to send rejection notification:", err));
      } else {
        // Fallback: Try topic 'user_{userId}' if convention exists, or just log warning
        await sendToTopic(`user_${pass.user.id}`, notification, data).catch(err => console.error("Failed to send rejection topic:", err));
      }

      return res.json({ message: 'Pass rejected', pass });
    } catch (err) {
      console.error('rejectPass error', err);
      res.status(500).json({ message: 'Server error' });
    }
  },
};
