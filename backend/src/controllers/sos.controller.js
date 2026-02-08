// backend/src/controllers/sos.controller.js
const { SOS, User, Location } = require("../models");
const { sendSOSAlert, sendToTopic } = require("../config/firebase");

module.exports = {
  // Send SOS alert (shake gesture from student app)
  async sendSOSAlert(req, res) {
    try {
      const { studentId, latitude, longitude, alertType = 'manual' } = req.body;

      if (!studentId) {
        return res.status(400).json({ message: "studentId required" });
      }

      const student = await User.findByPk(studentId);
      if (!student) {
        return res.status(404).json({ message: "Student not found" });
      }

      // Create SOS record
      const sos = await SOS.create({
        studentId,
        latitude,
        longitude,
        alertType,
        status: "active",
      });

      // Send Firebase notifications
      try {
        // Send to parents (topic-based)
        if (student.parentId) {
          const parentTopic = `parent_${student.parentId}_alerts`;
          await sendSOSAlert(
            parentTopic,
            student.name,
            studentId,
            latitude,
            longitude,
            alertType
          );
          console.log(`SOS notification sent to parents via topic: ${parentTopic}`);
        } else {
          console.warn(`Student ${studentId} has no parent linked. SOS notification skipped for parent.`);
        }

        // Send to admin/warden via global admin topic
        const adminTopic = 'admin_sos_alerts';
        await sendSOSAlert(
          adminTopic,
          student.name,
          studentId,
          latitude,
          longitude,
          alertType
        );
        console.log('SOS notification sent to admin/warden');
      } catch (firebaseError) {
        console.error('Error sending Firebase notification:', firebaseError);
        // Don't fail the entire request if Firebase fails
      }

      return res.status(201).json({
        message: "SOS alert sent",
        sos,
      });
    } catch (err) {
      console.error("sendSOSAlert error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  // Get active SOS alerts
  async getActiveSOSAlerts(req, res) {
    try {
      const { role, userId } = req.user; // from auth middleware

      let where = { status: "active" };

      if (role === "parent") {
        // Get SOS alerts for parent's children
        const parentChildren = await User.findAll({
          where: { parentId: userId },
          attributes: ["id"],
        });
        const childIds = parentChildren.map((c) => c.id);
        where.studentId = childIds;
      } else if (role === "student") {
        // Only student's own SOS
        where.studentId = userId;
      }
      // admin/warden see all

      const alerts = await SOS.findAll({
        where,
        include: [
          {
            model: User,
            as: "student",
            attributes: ["id", "name", "email"],
          },
        ],
        order: [["createdAt", "DESC"]],
      });

      res.json(alerts);
    } catch (err) {
      console.error("getActiveSOSAlerts error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  // Resolve SOS alert
  async resolveSOSAlert(req, res) {
    try {
      const { sosId } = req.params;
      const { userId } = req.user; // admin or warden

      const sos = await SOS.findByPk(sosId);
      if (!sos) {
        return res.status(404).json({ message: "SOS alert not found" });
      }

      sos.status = "resolved";
      sos.resolvedAt = new Date();
      sos.resolvedBy = userId;
      await sos.save();

      return res.json({
        message: "SOS alert resolved",
        sos,
      });
    } catch (err) {
      console.error("resolveSOSAlert error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  // Get SOS history for a student
  async getSOSHistory(req, res) {
    try {
      const { studentId } = req.params;

      const history = await SOS.findAll({
        where: { studentId },
        include: [
          {
            model: User,
            as: "student",
            attributes: ["id", "name", "email"],
          },
        ],
        order: [["createdAt", "DESC"]],
      });

      res.json(history);
    } catch (err) {
      console.error("getSOSHistory error", err);
      res.status(500).json({ message: "Server error" });
    }
  },
};
