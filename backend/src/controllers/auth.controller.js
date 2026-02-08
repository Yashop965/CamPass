// backend/src/controllers/auth.controller.js
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { User, Setting } = require("../models");
require("dotenv").config();

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "365d"; // Set to 1 year for persistent login

// Password validation function
const validatePassword = (password) => {
  if (!password || password.length < 8) {
    return "Password must be at least 8 characters long";
  }

  // Check for at least one special character
  const specialCharRegex = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/;
  if (!specialCharRegex.test(password)) {
    return "Password must contain at least one special character";
  }

  // Check for at least one number
  const numberRegex = /\d/;
  if (!numberRegex.test(password)) {
    return "Password must contain at least one number";
  }

  return null; // Valid password
};

module.exports = {
  async register(req, res) {
    try {
      const { name, email, password, role } = req.body;
      if (!name || !email || !password)
        return res
          .status(400)
          .json({ message: "name, email, password required" });

      // Validate password
      const passwordError = validatePassword(password);
      if (passwordError) {
        return res.status(400).json({ message: passwordError });
      }

      // Validate role
      const validRoles = ['student', 'parent', 'warden', 'guard', 'admin'];
      if (role && !validRoles.includes(role)) {
        return res.status(400).json({ message: "Invalid role specified" });
      }

      const existing = await User.findOne({ where: { email } });
      if (existing)
        return res.status(400).json({ message: "Email already registered" });

      const hashed = await bcrypt.hash(password, 10);
      const user = await User.create({
        name,
        email,
        password: hashed,
        role: role || "student",
      });

      // Create default settings for the user
      await Setting.create({
        userId: user.id,
        theme: 'light',
        notifications: true,
        biometric: false,
        locationTracking: true,
        emergencyAlerts: true,
        passNotifications: true,
        autoLogout: false
      });

      return res
        .status(201)
        .json({
          message: "User registered",
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
          },
        });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }
  },

  async login(req, res) {
    try {
      const { email, password } = req.body;
      if (!email || !password)
        return res.status(400).json({ message: "email and password required" });

      const user = await User.findOne({
        where: { email },
        include: [{ model: Setting, as: 'setting' }]
      });
      if (!user) return res.status(404).json({ message: "User not found" });

      const ok = await bcrypt.compare(password, user.password);
      if (!ok) return res.status(401).json({ message: "Invalid credentials" });

      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
      );

      return res.json({
        message: "Login successful",
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
        settings: user.setting || {
          theme: 'light',
          notifications: true,
          biometric: false,
          locationTracking: true,
          emergencyAlerts: true,
          passNotifications: true,
          autoLogout: false
        }
      });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }
  },

  async changePassword(req, res) {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user.id; // From auth middleware

      if (!currentPassword || !newPassword) {
        return res.status(400).json({ message: "Current password and new password are required" });
      }

      // Validate new password
      const passwordError = validatePassword(newPassword);
      if (passwordError) {
        return res.status(400).json({ message: passwordError });
      }

      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      // Verify current password
      const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
      if (!isCurrentPasswordValid) {
        return res.status(401).json({ message: "Current password is incorrect" });
      }

      // Hash new password
      const hashedNewPassword = await bcrypt.hash(newPassword, 10);

      // Update password
      await user.update({ password: hashedNewPassword });

      return res.json({ message: "Password changed successfully" });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }
  },

  async linkStudent(req, res) {
    try {
      const { studentEmail } = req.body;
      const parentId = req.user.id; // From auth middleware

      if (!studentEmail) {
        return res.status(400).json({ message: "Student email is required" });
      }

      const student = await User.findOne({ where: { email: studentEmail, role: 'student' } });
      if (!student) {
        return res.status(404).json({ message: "Student not found" });
      }

      if (student.parentId) {
        if (student.parentId === parentId) {
          return res.status(400).json({ message: "Student already linked to you" });
        }
        return res.status(400).json({ message: "Student already linked to another parent" });
      }

      student.parentId = parentId;
      await student.save();

      return res.json({ message: "Student linked successfully", student: { name: student.name, email: student.email } });
    } catch (err) {
      console.error("linkStudent error", err);
      return res.status(500).json({ message: "Server error" });
    }
  },

  async getChildren(req, res) {
    try {
      const parentId = req.user.id;
      const children = await User.findAll({
        where: { parentId },
        attributes: ['id', 'name', 'email', 'role']
      });
      res.json(children);
    } catch (err) {
      console.error("getChildren error", err);
      res.status(500).json({ message: "Server error" });
    }
  },
};
