// backend/server.js
require("dotenv").config();
const express = require("express");
const cors = require("cors");
const path = require("path");
const { sequelize } = require("./src/models");
const logger = require("./src/utils/logger");
const { apiLimiter, authLimiter } = require("./src/middleware/rateLimit.middleware");
const configureSecurity = require("./src/middleware/security.middleware");

const authRoutes = require("./src/routes/auth.routes");
const userRoutes = require("./src/routes/user.routes");
const passRoutes = require("./src/routes/pass.routes");
const sosRoutes = require("./src/routes/sos.routes");
const locationRoutes = require("./src/routes/location.routes");
const settingsRoutes = require("./src/routes/settings.routes");
const { initializeFirebase } = require("./src/config/firebase");

const app = express();

// 1. Apply Security Middleware (Helmet, Compression, HPP)
configureSecurity(app);

// CORS configuration (Must be after helmet)
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

app.use(cors(corsOptions));

// Body parsing middleware
app.use(express.json({ limit: process.env.MAX_FILE_SIZE || '10mb' }));
app.use(express.urlencoded({ extended: true, limit: process.env.MAX_FILE_SIZE || '10mb' }));

// Apply rate limiting
app.use('/api/', apiLimiter);

// Health check endpoint (before auth limiter)
app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API routes
app.use("/api/auth", authLimiter, authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/passes", passRoutes);
app.use("/api/sos", sosRoutes);
app.use("/api/location", locationRoutes);
app.use("/api/settings", settingsRoutes);

// Serve barcode images statically
app.use("/barcodes", express.static(path.join(__dirname, process.env.BARCODE_OUTPUT_DIR || "docs/barcodes")));

// Swagger Documentation
const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./src/config/swagger');
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs));
logger.info('📚 API Documentation enabled at /api-docs');

// Global error handler
app.use((err, req, res, next) => {
  logger.error('Global error handler:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'production' ? 'Something went wrong' : err.message
  });
});

// 404 handler
app.use((req, res) => {
  logger.warn(`404 - Route not found: ${req.method} ${req.originalUrl}`);
  res.status(404).json({ error: 'Route not found' });
});

const PORT = process.env.PORT || 5000;

async function start() {
  try {
    // Validate environment variables
    const requiredEnv = ['JWT_SECRET', 'DB_PASS', 'DB_NAME', 'DB_USER'];
    const missingEnv = requiredEnv.filter(key => !process.env[key]);

    if (missingEnv.length > 0) {
      logger.error(`❌ Missing required environment variables: ${missingEnv.join(', ')}`);
      process.exit(1);
    }

    // Initialize Firebase
    initializeFirebase();

    // Test database connection
    await sequelize.authenticate();
    logger.info("✅ Database connected successfully");

    // Sync database (only in development, use migrations in production)
    if (process.env.NODE_ENV !== 'production') {
      await sequelize.sync({ alter: true });
      logger.info("✅ Database synchronized");
    }

    // Start server
    app.listen(PORT, '0.0.0.0', () => {
      logger.info(`🚀 Server running on port ${PORT}`);
      logger.info(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`🔗 CORS Origins: ${corsOptions.origin}`);
    });
  } catch (err) {
    logger.error("❌ Failed to start server:", err);
    process.exit(1);
  }
}

module.exports = app;

start();
