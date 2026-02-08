'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Settings', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      userId: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      theme: {
        type: Sequelize.ENUM('light', 'dark'),
        defaultValue: 'light'
      },
      notifications: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      biometric: {
        type: Sequelize.BOOLEAN,
        defaultValue: false
      },
      locationTracking: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      emergencyAlerts: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      passNotifications: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      autoLogout: {
        type: Sequelize.BOOLEAN,
        defaultValue: false
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Settings');
  }
};