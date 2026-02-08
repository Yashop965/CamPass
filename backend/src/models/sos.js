// backend/src/models/sos.js
"use strict";
const { Model } = require("sequelize");

module.exports = (sequelize, DataTypes) => {
  class SOS extends Model {
    static associate(models) {
      SOS.belongsTo(models.User, { foreignKey: "studentId", as: "student" });
    }
  }

  SOS.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      studentId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      latitude: DataTypes.FLOAT,
      longitude: DataTypes.FLOAT,
      alertType: {
        type: DataTypes.STRING,
        defaultValue: "manual", // 'manual' or 'geofence'
      },
      status: {
        type: DataTypes.STRING,
        defaultValue: "active", // 'active', 'resolved'
      },
      resolvedAt: DataTypes.DATE,
      resolvedBy: DataTypes.UUID, // admin or warden who resolved it
    },
    {
      sequelize,
      modelName: "SOS",
      timestamps: true,
    }
  );

  return SOS;
};
