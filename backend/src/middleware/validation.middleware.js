// backend/src/middleware/validation.middleware.js
const { body, validationResult } = require('express-validator');

// Middleware to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      message: 'Validation failed',
      errors: errors.array()
    });
  }
  next();
};

// Validation rules for user registration
const validateRegistration = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters'),
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Must be a valid email'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/)
    .withMessage('Password must contain at least one special character')
    .matches(/\d/)
    .withMessage('Password must contain at least one number'),
  body('role')
    .optional()
    .isIn(['student', 'parent', 'warden', 'guard', 'admin'])
    .withMessage('Invalid role'),
  handleValidationErrors
];

// Validation rules for login
const validateLogin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Must be a valid email'),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  handleValidationErrors
];

// Validation rules for creating a pass
const validatePassCreation = [
  body('type')
    .notEmpty()
    .withMessage('Pass type is required'),
  body('validFrom')
    .optional()
    .isISO8601()
    .withMessage('Valid from must be a valid date'),
  body('validTo')
    .optional()
    .isISO8601()
    .withMessage('Valid to must be a valid date'),
  handleValidationErrors
];

// Validation rules for SOS
const validateSOS = [
  body('message')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Message must be less than 500 characters'),
  handleValidationErrors
];

// Validation rules for pass approval
const validatePassApproval = [
  body('status')
    .isIn(['approved', 'rejected'])
    .withMessage('Status must be either approved or rejected'),
  body('remarks')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Remarks must be less than 500 characters'),
  handleValidationErrors
];

module.exports = {
  validateRegistration,
  validateLogin,
  validatePassCreation,
  validateSOS,
  validatePassApproval
};