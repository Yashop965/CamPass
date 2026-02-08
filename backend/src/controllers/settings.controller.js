// backend/src/controllers/settings.controller.js
const { Setting } = require("../models");

module.exports = {
  async getSettings(req, res) {
    try {
      const userId = req.user.id;

      let settings = await Setting.findOne({ where: { userId } });

      // Create default settings if none exist
      if (!settings) {
        settings = await Setting.create({
          userId,
          theme: 'light',
          notifications: true,
          biometric: false,
          locationTracking: true,
          emergencyAlerts: true,
          passNotifications: true,
          autoLogout: false
        });
      }

      return res.json({ settings });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }
  },

  async updateSettings(req, res) {
    try {
      const userId = req.user.id;
      const updates = req.body;

      // Validate allowed fields
      const allowedFields = [
        'theme', 'notifications', 'biometric', 'locationTracking',
        'emergencyAlerts', 'passNotifications', 'autoLogout'
      ];

      const filteredUpdates = {};
      for (const field of allowedFields) {
        if (updates[field] !== undefined) {
          filteredUpdates[field] = updates[field];
        }
      }

      let settings = await Setting.findOne({ where: { userId } });

      if (!settings) {
        settings = await Setting.create({
          userId,
          ...filteredUpdates
        });
      } else {
        await settings.update(filteredUpdates);
      }

      return res.json({
        message: "Settings updated successfully",
        settings
      });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }
  }
};