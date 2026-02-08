// backend/tests/auth.test.js
const request = require('supertest');
const app = require('../server'); // Assuming server exports the app
const { sequelize } = require('../src/models');

beforeAll(async () => {
  // Set up test database
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  await sequelize.close();
});

describe('Auth API', () => {
  test('should register a new user', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Test User',
        email: 'test@example.com',
        password: 'TestPass123!'
      });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('user');
    expect(response.body).toHaveProperty('token');
  });

  test('should login user', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'TestPass123!'
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('token');
  });

  test('should reject invalid login', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'wrongpassword'
      });

    expect(response.status).toBe(401);
  });
});