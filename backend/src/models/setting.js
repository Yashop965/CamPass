'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Setting extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Setting.belongsTo(models.User, { foreignKey: 'userId' });
    }
  }
  Setting.init({
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      }
    },
    theme: {
      type: DataTypes.ENUM('light', 'dark'),
      defaultValue: 'light'
    },
    notifications: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    biometric: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    // Role-specific settings
    locationTracking: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    emergencyAlerts: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    passNotifications: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    autoLogout: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    sequelize,
    modelName: 'Setting',
  });
  return Setting;
};