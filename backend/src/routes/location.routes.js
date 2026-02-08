// backend/src/routes/location.routes.js
const router = require("express").Router();
const LocationController = require("../controllers/location.controller");
const { authenticateToken } = require("../middleware/auth.middleware");

// Update student location (from student app - real-time)
router.post("/update", authenticateToken, LocationController.updateLocation);

// Get student's current location (for parents/warden to track)
router.get("/student/:studentId", authenticateToken, LocationController.getStudentLocation);

// Get location history
router.get("/history/:studentId", authenticateToken, LocationController.getLocationHistory);

// Get geofence violations (for admin/warden)
router.get("/violations", authenticateToken, LocationController.getGeofenceViolations);

module.exports = router;
