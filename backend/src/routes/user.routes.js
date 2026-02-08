// backend/src/routes/user.routes.js
const router = require("express").Router();
const UserController = require("../controllers/user.controller");
const {
  authenticateToken,
  authorizeRoles,
} = require("../middleware/auth.middleware");

// list users (admin only)
router.get(
  "/",
  authenticateToken,
  authorizeRoles("admin"),
  UserController.getAllUsers
);

// get user by id (protected)
// get user by id (protected)
router.get("/:id", authenticateToken, (req, res, next) => {
  // Allow if admin or if requesting own data
  if (req.user.role === 'admin' || req.user.id === req.params.id) {
    return next();
  }
  return res.status(403).json({ message: "Forbidden: You can only view your own data" });
}, UserController.getUserById);

module.exports = router;
