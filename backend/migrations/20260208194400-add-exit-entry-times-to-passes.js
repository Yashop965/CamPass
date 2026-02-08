'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.addColumn('Passes', 'exitTime', {
            type: Sequelize.DATE,
            allowNull: true,
        });
        await queryInterface.addColumn('Passes', 'entryTime', {
            type: Sequelize.DATE,
            allowNull: true,
        });
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.removeColumn('Passes', 'exitTime');
        await queryInterface.removeColumn('Passes', 'entryTime');
    }
};
