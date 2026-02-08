// backend/src/middleware/auth.middleware.js
const jwt = require("jsonwebtoken");
const { User } = require("../models");
require("dotenv").config();

const JWT_SECRET = process.env.JWT_SECRET;

async function authenticateToken(req, res, next) {
  try {
    const authHeader =
      req.headers["authorization"] || req.headers["Authorization"];
    if (!authHeader)
      return res.status(401).json({ message: "No token provided" });

    // Bearer token
    const parts = authHeader.split(" ");
    const token = parts.length === 2 ? parts[1] : authHeader;

    if (!token)
      return res.status(401).json({ message: "Invalid token format" });

    jwt.verify(token, JWT_SECRET, async (err, decoded) => {
      if (err)
        return res.status(401).json({ message: "Token invalid or expired" });

      // optional: fetch user from DB for fresh data
      const user = await User.findByPk(decoded.id);
      if (!user)
        return res.status(401).json({ message: "User no longer exists" });

      // attach to request
      req.user = {
        id: user.id,
        email: user.email,
        role: user.role,
      };

      next();
    });
  } catch (err) {
    console.error("authenticateToken error", err);
    res.status(500).json({ message: "Server error" });
  }
}

// role check middleware
function authorizeRoles(...roles) {
  return (req, res, next) => {
    if (!req.user)
      return res.status(401).json({ message: "Not authenticated" });
    if (!roles.includes(req.user.role))
      return res.status(403).json({ message: "Forbidden" });
    next();
  };
}

module.exports = {
  authenticateToken,
  authorizeRoles,
};
