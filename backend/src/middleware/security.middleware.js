// backend/src/middleware/security.middleware.js
const helmet = require('helmet');
const compression = require('compression');
const hpp = require('hpp');

const configureSecurity = (app) => {
    // 1. Set security HTTP headers
    app.use(helmet());

    // 2. Compress response bodies
    app.use(compression());

    // 3. Prevent HTTP Parameter Pollution
    app.use(hpp());

    // 4. Disable X-Powered-By header (Helmet does this, but good to be explicit)
    app.disable('x-powered-by');

    console.log('🛡️  Security middleware applied: Helmet, Compression, HPP');
};

module.exports = configureSecurity;
