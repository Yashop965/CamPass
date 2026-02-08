// backend/src/routes/settings.routes.js
const router = require("express").Router();
const SettingsController = require("../controllers/settings.controller");
const { authenticateToken } = require("../middleware/auth.middleware");

router.get("/", authenticateToken, SettingsController.getSettings);
router.put("/", authenticateToken, SettingsController.updateSettings);

module.exports = router;