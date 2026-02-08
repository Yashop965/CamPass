// backend/src/routes/pass.routes.js
const router = require("express").Router();
const PassController = require("../controllers/pass.controller");
const {
  authenticateToken,
  authorizeRoles,
} = require("../middleware/auth.middleware");
const { validatePassCreation, validatePassApproval } = require("../middleware/validation.middleware");

// create pass - protected (e.g., warden/admin)
router.post(
  "/generate",
  authenticateToken,
  authorizeRoles("admin", "warden", "student"),
  validatePassCreation,
  PassController.generatePass
);

// get pending passes for warden (protected)
router.get("/pending/warden", authenticateToken, authorizeRoles("warden", "admin"), PassController.getPendingWardenPasses);
router.get("/history/warden", authenticateToken, authorizeRoles("warden", "admin"), PassController.getWardenPassHistory);

// get pending passes for parent (protected)
router.get("/pending/parent", authenticateToken, authorizeRoles("parent", "admin"), PassController.getPendingParentPasses);

// get pass details (protected)
router.get("/:id", authenticateToken, PassController.getPassById);

router.get('/user/:userId', authenticateToken, async (req, res, next) => {
  // Users can only see their own passes, unless admin or warden
  if (req.user.id === req.params.userId || ['admin', 'warden'].includes(req.user.role)) {
    return next();
  }

  // If parent, check if the requested userId is their child
  if (req.user.role === 'parent') {
    const { User } = require("../models");
    try {
      const targetUser = await User.findByPk(req.params.userId);
      if (targetUser && targetUser.parentId === req.user.id) {
        return next();
      }
    } catch (err) {
      console.error("Parent auth check failed", err);
      // Fall through to forbidden
    }
  }

  return res.status(403).json({ message: "Forbidden" });
}, PassController.getPassesByUser);

// scan by barcode (Gate-side) - keep this public OR protected depending on your gate setup.
// If gate device has a token, protect it. For now, make it protected (recommended).
router.post("/scan", authenticateToken, PassController.scanPass);
router.patch('/:id/approve-parent', authenticateToken, authorizeRoles('parent'), validatePassApproval, PassController.approveByParent);
router.patch('/:id/approve-warden', authenticateToken, authorizeRoles('warden', 'admin'), validatePassApproval, PassController.approveByWarden);
router.patch('/:id/reject', authenticateToken, authorizeRoles('parent', 'warden', 'admin'), PassController.rejectPass);


module.exports = router;
