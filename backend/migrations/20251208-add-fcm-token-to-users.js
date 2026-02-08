'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('Users', 'fcm_token', {
      type: Sequelize.STRING,
      allowNull: true,
      after: 'role',
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('Users', 'fcm_token');
  },
};
