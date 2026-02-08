"use strict";
const { Model } = require("sequelize");

module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    static associate(models) {
      User.hasMany(models.Pass, { foreignKey: "userId" });
      User.hasOne(models.Setting, { foreignKey: "userId" });
    }
  }

  User.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
      },
      name: DataTypes.STRING,
      email: {
        type: DataTypes.STRING,
        unique: true
      },
      password: DataTypes.STRING,
      role: {
        type: DataTypes.ENUM('student', 'parent', 'warden', 'guard', 'admin'),
        defaultValue: 'student',
        allowNull: false
      },
    },
    {
      sequelize,
      modelName: "User",
    }
  );

  return User;
};
