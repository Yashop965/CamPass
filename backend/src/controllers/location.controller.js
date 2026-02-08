// backend/src/controllers/location.controller.js
const { Location, User, SOS } = require("../models");
const { sendGeofenceViolation } = require("../config/firebase");

module.exports = {
  // Update student location (real-time tracking)
  async updateLocation(req, res) {
    try {
      const { studentId, latitude, longitude, accuracy, isGeofenceViolation } = req.body;

      if (!studentId || latitude === undefined || longitude === undefined) {
        return res.status(400).json({
          message: "studentId, latitude, longitude required",
        });
      }

      const student = await User.findByPk(studentId);
      if (!student) {
        return res.status(404).json({ message: "Student not found" });
      }

      // Store location record
      const location = await Location.create({
        studentId,
        latitude,
        longitude,
        accuracy,
        isGeofenceViolation: isGeofenceViolation || false,
      });

      // If geofence violation, trigger automatic alert and notification
      if (isGeofenceViolation) {
        try {
          // Create SOS record
          await SOS.create({
            studentId,
            latitude,
            longitude,
            alertType: "geofence",
            status: "active",
          });

          // Send Firebase notification to parents
          const parentTopic = `parent_${studentId}_tracking`;
          await sendGeofenceViolation(
            parentTopic,
            student.name,
            studentId,
            latitude,
            longitude
          );
          console.log(`Geofence violation notification sent to parents via topic: ${parentTopic}`);

          // Send to admin/warden via global admin topic
          const adminTopic = 'admin_geofence_violations';
          await sendGeofenceViolation(
            adminTopic,
            student.name,
            studentId,
            latitude,
            longitude
          );
          console.log('Geofence violation notification sent to admin/warden');
        } catch (firebaseError) {
          console.error('Error sending geofence notification:', firebaseError);
          // Don't fail the entire request if Firebase fails
        }
      }

      return res.status(201).json({
        message: "Location updated",
        location,
      });
    } catch (err) {
      console.error("updateLocation error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  // Get student's current location (for parents/warden to track)
  async getStudentLocation(req, res) {
    try {
      const { studentId } = req.params;

      // Get the latest location
      const location = await Location.findOne({
        where: { studentId },
        order: [["timestamp", "DESC"]],
      });

      if (!location) {
        return res.status(404).json({ message: "No location data found" });
      }

      res.json(location);
    } catch (err) {
      console.error("getStudentLocation error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  // Get location history for a student (for analytics)
  async getLocationHistory(req, res) {
    try {
      const { studentId } = req.params;
      const { limit = 100 } = req.query; // Default last 100 locations

      const history = await Location.findAll({
        where: { studentId },
        order: [["timestamp", "DESC"]],
        limit: parseInt(limit),
      });

      res.json(history);
    } catch (err) {
      console.error("getLocationHistory error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  // Get students currently outside geofence
  async getGeofenceViolations(req, res) {
    try {
      // Get all students with geofence violations in the last check
      const violations = await Location.findAll({
        where: { isGeofenceViolation: true },
        attributes: ["studentId"],
        group: ["studentId"],
        include: [
          {
            model: User,
            as: "student",
            attributes: ["id", "name", "email"],
          },
        ],
        order: [["timestamp", "DESC"]],
      });

      res.json(violations);
    } catch (err) {
      console.error("getGeofenceViolations error", err);
      res.status(500).json({ message: "Server error" });
    }
  },

  // Request an immediate location update from a student
  async requestUpdate(req, res) {
    try {
      const { studentId } = req.body;
      const requesterId = req.user.id;

      if (!studentId) {
        return res.status(400).json({ message: "studentId required" });
      }

      const student = await User.findByPk(studentId);
      if (!student) {
        return res.status(404).json({ message: "Student not found" });
      }

      // Verify permission
      if (req.user.role === 'parent' && student.parentId !== requesterId) {
        return res.status(403).json({ message: "Unauthorized to track this student" });
      }

      const { sendToTopic } = require("../config/firebase");
      const topic = `student_${studentId}_alerts`;

      await sendToTopic(topic, {
        title: "Location Request",
        body: "Updating location...",
      }, {
        type: 'location_request',
        requesterId: requesterId.toString()
      });

      return res.json({ message: "Location request sent" });
    } catch (err) {
      console.error("requestUpdate error", err);
      return res.status(500).json({ message: "Failed to send request" });
    }
  },
};
