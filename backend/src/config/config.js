require('dotenv').config();
module.exports = {
  "development": {
    "username": process.env.DB_USER || "postgres",
    "password": process.env.DB_PASS || "RahatSwarup@21",
    "database": process.env.DB_NAME || "campass_dev",
    "host": process.env.DB_HOST || "127.0.0.1",
    "port": process.env.DB_PORT || 5432,
    "dialect": "postgres",
    "pool": {
      "max": 10,
      "min": 0,
      "acquire": 30000,
      "idle": 10000
    },
    "logging": false // Reduce noise during scale testing
  },
  "test": {
    "username": process.env.DB_USER || "postgres",
    "password": process.env.DB_PASS || "RahatSwarup@21",
    "database": process.env.DB_NAME || "campass_test",
    "host": process.env.DB_HOST || "127.0.0.1",
    "port": process.env.DB_PORT || 5432,
    "dialect": "postgres",
    "pool": {
      "max": 5,
      "min": 0,
      "acquire": 30000,
      "idle": 10000
    }
  },
  "production": {
    "username": process.env.DB_USER,
    "password": process.env.DB_PASS,
    "database": process.env.DB_NAME,
    "host": process.env.DB_HOST,
    "port": process.env.DB_PORT,
    "dialect": "postgres",
    "pool": {
      "max": 50, // Increased for 15k users (assuming caching layer handling reads)
      "min": 5,
      "acquire": 60000,
      "idle": 10000
    },
    "logging": false
  }
}
