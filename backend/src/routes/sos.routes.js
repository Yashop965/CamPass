// backend/src/routes/sos.routes.js
const router = require("express").Router();
const SOSController = require("../controllers/sos.controller");
const { authenticateToken } = require("../middleware/auth.middleware");
const { validateSOS } = require("../middleware/validation.middleware");

// Send SOS alert (from student app)
router.post("/alert", authenticateToken, validateSOS, SOSController.sendSOSAlert);

// Get active SOS alerts (for parents/admin/warden)
router.get("/active", authenticateToken, SOSController.getActiveSOSAlerts);

// Resolve SOS alert (admin/warden)
router.patch("/:sosId/resolve", authenticateToken, SOSController.resolveSOSAlert);

// Get SOS history for a student
router.get("/history/:studentId", authenticateToken, SOSController.getSOSHistory);

module.exports = router;
