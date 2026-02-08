const { User, sequelize } = require('../src/models');
const bcrypt = require('bcryptjs');

const users = [
    {
        name: 'Test Student',
        email: 'student@test.com',
        password: 'password123',
        role: 'student'
    },
    {
        name: 'Test Parent',
        email: 'parent@test.com',
        password: 'password123',
        role: 'parent'
    },
    {
        name: 'Test Warden',
        email: 'warden@test.com',
        password: 'password123',
        role: 'warden'
    },
    {
        name: 'Test Guard',
        email: 'guard@test.com',
        password: 'password123',
        role: 'guard'
    }
];

async function seed() {
    try {
        console.log('🌱 Seeding users...');

        // Ensure DB connection
        await sequelize.authenticate();
        console.log('✅ Connected to database.');

        for (const user of users) {
            const existing = await User.findOne({ where: { email: user.email } });
            if (existing) {
                console.log(`⚠️ User ${user.email} already exists. Skipping.`);
                continue;
            }

            const hashedPassword = await bcrypt.hash(user.password, 10);
            await User.create({
                name: user.name,
                email: user.email,
                password: hashedPassword,
                role: user.role
            });
            console.log(`✅ Created user: ${user.email}`);
        }

        console.log('✨ Seeding complete!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
}

seed();
