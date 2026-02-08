// backend/src/models/pass.js
"use strict";
const { Model } = require("sequelize");

module.exports = (sequelize, DataTypes) => {
  class Pass extends Model {
    static associate(models) {
      Pass.belongsTo(models.User, { foreignKey: "userId", as: "user" });
    }
  }

  Pass.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      userId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      type: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      purpose: {
        type: DataTypes.STRING,
        allowNull: true,
      },
      validFrom: DataTypes.DATE,
      validTo: DataTypes.DATE,
      barcode: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      barcodeImagePath: {
        type: DataTypes.STRING,
        allowNull: true,
      },
      status: {
        type: DataTypes.STRING,
        defaultValue: "active",
      },
      rejectionReason: {
        type: DataTypes.STRING,
        allowNull: true,
      },
    },
    {
      sequelize,
      modelName: "Pass",
      indexes: [
        {
          fields: ['userId']
        },
        {
          fields: ['status']
        }
      ]
    }
  );

  return Pass;
};
