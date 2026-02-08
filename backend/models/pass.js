"use strict";
const { Model } = require("sequelize");

module.exports = (sequelize, DataTypes) => {
  class Pass extends Model {
    static associate(models) {
      Pass.belongsTo(models.User, { foreignKey: "userId" });
    }
  }

  Pass.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
      },
      userId: DataTypes.UUID,
      type: DataTypes.STRING,
      validFrom: DataTypes.DATE,
      validTo: DataTypes.DATE,
      barcode: DataTypes.STRING,
      status: DataTypes.STRING,
    },
    {
      sequelize,
      modelName: "Pass",
    }
  );

  return Pass;
};
