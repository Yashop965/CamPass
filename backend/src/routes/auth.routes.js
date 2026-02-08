// backend/src/routes/auth.routes.js
const router = require("express").Router();
const AuthController = require("../controllers/auth.controller");
const { authenticateToken } = require("../middleware/auth.middleware");
const { validateRegistration, validateLogin } = require("../middleware/validation.middleware");
const { User } = require("../models");

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Authentication and User Management
 */

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               role:
 *                 type: string
 *                 enum: [student, parent, warden, guard]
 *     responses:
 *       201:
 *         description: User registered successfully
 *       400:
 *         description: Validation error
 */
router.post("/register", AuthController.register);
router.post("/link-student", authenticateToken, AuthController.linkStudent);
router.get("/children", authenticateToken, AuthController.getChildren);

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Login user and get JWT
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token:
 *                   type: string
 *       401:
 *         description: Invalid credentials
 */
router.post("/login", AuthController.login);
router.post("/change-password", authenticateToken, AuthController.changePassword);

// Update FCM token after login
router.post("/update-fcm-token", authenticateToken, async (req, res) => {
  try {
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res.status(400).json({ error: "FCM token is required" });
    }

    const user = await User.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    user.fcm_token = fcmToken;
    await user.save();

    res.json({
      message: "FCM token updated successfully",
      fcmToken: fcmToken
    });
  } catch (error) {
    console.error("Error updating FCM token:", error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
