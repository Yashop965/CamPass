const { User, sequelize } = require('../src/models');

async function checkUsers() {
    try {
        await sequelize.authenticate();
        const users = await User.findAll({ attributes: ['id', 'name', 'email', 'role'] });
        console.log('--- Database Users ---');
        console.table(users.map(u => u.toJSON()));
        console.log('----------------------');
    } catch (error) {
        console.error('Error fetching users:', error);
    } finally {
        process.exit();
    }
}

checkUsers();
