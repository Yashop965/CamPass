// backend/src/controllers/user.controller.js
const { User, Pass } = require("../models");

module.exports = {
  async getAllUsers(req, res) {
    try {
      const users = await User.findAll({
        attributes: ["id", "name", "email", "role", "createdAt"],
      });
      res.json(users);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Server error" });
    }
  },

  async getUserById(req, res) {
    try {
      const user = await User.findByPk(req.params.id, {
        attributes: ["id", "name", "email", "role", "createdAt"],
        include: [{ model: Pass, as: "Passes" }],
      });
      if (!user) return res.status(404).json({ message: "User not found" });
      res.json(user);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Server error" });
    }
  },
};
