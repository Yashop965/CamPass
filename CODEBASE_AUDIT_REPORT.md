# Codebase Audit Report - CAMPASS
**Date:** $(date)  
**Status:** ⚠️ CRITICAL ISSUES FOUND

---

## 🔴 CRITICAL SECURITY FLAWS

### 1. **HARDCODED CREDENTIALS IN DOCKER-COMPOSE.YML** ⚠️ CRITICAL
**Location:** `docker-compose.yml` lines 9, 28, 29
- **Issue:** Database password and JWT secret are hardcoded in plain text
- **Risk:** Anyone with access to the repo can see credentials
- **Fix:** Move all secrets to `.env` file and use environment variable substitution
- **Impact:** HIGH - Complete system compromise possible

### 2. **MISSING ROOT .GITIGNORE** ⚠️ CRITICAL
**Location:** Root directory
- **Issue:** No `.gitignore` at root level
- **Risk:** Sensitive files like `serviceAccountKey.json`, `.env`, `database.sqlite` could be committed
- **Fix:** Create root `.gitignore` with:
  ```
  .env
  .env.*
  serviceAccountKey.json
  database.sqlite
  database.sqlite-journal
  logs/
  node_modules/
  ```
- **Impact:** HIGH - Credentials could leak to version control

### 3. **JWT_SECRET NOT VALIDATED ON STARTUP** ⚠️ CRITICAL
**Location:** `backend/src/controllers/auth.controller.js`, `backend/src/middleware/auth.middleware.js`
- **Issue:** If `JWT_SECRET` is undefined, JWT operations will fail silently or use undefined
- **Risk:** Authentication bypass or system crash
- **Fix:** Add startup validation:
  ```javascript
  if (!process.env.JWT_SECRET) {
    logger.error('JWT_SECRET is not set!');
    process.exit(1);
  }
  ```
- **Impact:** HIGH - Authentication system failure

### 4. **SERVICE ACCOUNT KEY HARDCODED PATH** ⚠️ CRITICAL
**Location:** `backend/src/config/firebase.js` line 17
- **Issue:** `serviceAccountKey.json` is required with no fallback or environment variable option
- **Risk:** App crashes if file missing, no graceful degradation
- **Fix:** Use environment variable for path or make it optional with proper error handling
- **Impact:** MEDIUM - Firebase features won't work

---

## 🟠 HIGH PRIORITY ISSUES

### 5. **AUTHORIZATION BYPASS IN USER ROUTES** ⚠️ HIGH
**Location:** `backend/src/routes/user.routes.js` line 18
- **Issue:** `getUserById` allows any authenticated user to view any other user's data
- **Risk:** Users can access other users' information
- **Fix:** Add authorization check:
  ```javascript
  // Users can only view their own data unless admin
  if (req.user.id !== req.params.id && req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Forbidden' });
  }
  ```
- **Impact:** HIGH - Privacy violation

### 6. **AUTHORIZATION BYPASS IN PASS ROUTES** ⚠️ HIGH
**Location:** `backend/src/routes/pass.routes.js` line 21
- **Issue:** `getPassesByUser` allows any authenticated user to view any user's passes
- **Risk:** Users can see other users' pass history
- **Fix:** Add authorization check similar to #5
- **Impact:** HIGH - Privacy violation

### 7. **NO AUTHORIZATION CHECK IN PASS APPROVAL** ⚠️ HIGH
**Location:** `backend/src/routes/pass.routes.js` lines 26-27
- **Issue:** `approveByParent` and `approveByWarden` don't verify the user has permission
- **Risk:** Any user can approve passes if they know the endpoint
- **Fix:** Add role-based authorization:
  ```javascript
  router.patch('/:id/approve-parent', authenticateToken, authorizeRoles('parent'), ...)
  router.patch('/:id/approve-warden', authenticateToken, authorizeRoles('warden', 'admin'), ...)
  ```
- **Impact:** HIGH - Unauthorized pass approvals

### 8. **EXCESSIVE JWT EXPIRATION TIME** ⚠️ MEDIUM-HIGH
**Location:** `backend/src/controllers/auth.controller.js` line 8
- **Issue:** JWT expires in 365 days (1 year) by default
- **Risk:** Compromised tokens remain valid for too long
- **Fix:** Reduce to 7-30 days and implement refresh tokens
- **Impact:** MEDIUM - Long-lived security risk

### 9. **INCONSISTENT ERROR HANDLING** ⚠️ MEDIUM
**Location:** Multiple controllers
- **Issue:** Mix of `console.error` and `logger.error`, some errors not logged
- **Risk:** Difficult to debug production issues
- **Fix:** Standardize on logger, remove all `console.error` calls
- **Impact:** MEDIUM - Poor observability

---

## 🟡 MEDIUM PRIORITY ISSUES

### 10. **MISSING INPUT VALIDATION ON USER ID** ⚠️ MEDIUM
**Location:** `backend/src/controllers/pass.controller.js` line 98
- **Issue:** `userId` from params not validated (could be SQL injection if not using Sequelize properly)
- **Risk:** Potential injection if Sequelize is bypassed
- **Fix:** Validate userId is UUID or integer before query
- **Impact:** LOW-MEDIUM - Sequelize protects but validation is good practice

### 11. **NO RATE LIMITING ON PASS SCAN** ⚠️ MEDIUM
**Location:** `backend/src/routes/pass.routes.js` line 25
- **Issue:** Pass scanning endpoint has no specific rate limit
- **Risk:** Brute force scanning attempts
- **Fix:** Add stricter rate limiter for scan endpoint
- **Impact:** MEDIUM - Resource exhaustion possible

### 12. **MISSING ENVIRONMENT VARIABLE VALIDATION** ⚠️ MEDIUM
**Location:** `backend/server.js`
- **Issue:** No validation that required env vars are set before starting
- **Risk:** App starts but fails at runtime
- **Fix:** Add startup validation for all required env vars
- **Impact:** MEDIUM - Runtime failures

### 13. **DUPLICATE MODELS DIRECTORY** ⚠️ MEDIUM
**Location:** `backend/models/` and `backend/src/models/`
- **Issue:** Two model directories exist, potential confusion
- **Risk:** Using wrong models, inconsistent codebase
- **Fix:** Consolidate to one location (prefer `src/models/`)
- **Impact:** MEDIUM - Code maintainability

### 14. **CORS CONFIGURATION TOO PERMISSIVE** ⚠️ MEDIUM
**Location:** `backend/server.js` line 21
- **Issue:** If `ALLOWED_ORIGINS` not set, CORS allows all origins (`true`)
- **Risk:** CSRF attacks, unauthorized API access
- **Fix:** Require `ALLOWED_ORIGINS` in production, fail if not set
- **Impact:** MEDIUM - Security vulnerability

### 15. **HEALTH CHECK USES WRONG METHOD** ⚠️ LOW-MEDIUM
**Location:** `backend/Dockerfile` line 24
- **Issue:** Health check uses `curl` which may not be in alpine image
- **Risk:** Health checks fail, container marked unhealthy
- **Fix:** Use `wget` or install curl, or use Node.js script
- **Impact:** LOW-MEDIUM - Deployment issues

---

## 🟢 LOW PRIORITY / CODE QUALITY

### 16. **DUPLICATE WIDGETSBINDING INITIALIZATION**
**Location:** `frontend/campass_app/lib/main.dart` lines 10, 19
- **Issue:** `WidgetsFlutterBinding.ensureInitialized()` called twice
- **Fix:** Remove duplicate on line 19
- **Impact:** LOW - Redundant code

### 17. **MISSING ERROR BOUNDARIES IN FRONTEND**
**Location:** Flutter app
- **Issue:** No global error handler for uncaught exceptions
- **Fix:** Add Flutter error handling
- **Impact:** LOW - Poor UX on crashes

### 18. **INCONSISTENT PASSWORD VALIDATION**
**Location:** `backend/src/controllers/auth.controller.js` vs `backend/src/middleware/validation.middleware.js`
- **Issue:** Password validation logic duplicated
- **Fix:** Consolidate validation logic
- **Impact:** LOW - Code duplication

### 19. **NO DATABASE CONNECTION POOL MONITORING**
**Location:** Database config
- **Issue:** No monitoring of connection pool health
- **Fix:** Add connection pool metrics
- **Impact:** LOW - Operational visibility

### 20. **MISSING API DOCUMENTATION**
**Location:** All routes
- **Issue:** No Swagger/OpenAPI documentation
- **Fix:** Add API documentation
- **Impact:** LOW - Developer experience

---

## 📊 SUMMARY

**Total Issues Found:** 20
- 🔴 **Critical:** 4
- 🟠 **High:** 5
- 🟡 **Medium:** 6
- 🟢 **Low:** 5

**Immediate Actions Required:**
1. ✅ Remove hardcoded credentials from `docker-compose.yml`
2. ✅ Create root `.gitignore`
3. ✅ Add JWT_SECRET validation on startup
4. ✅ Fix authorization bypasses in user and pass routes
5. ✅ Add role checks to pass approval endpoints

**Estimated Fix Time:** 4-6 hours for critical issues

---

## ✅ POSITIVE FINDINGS

- ✅ Using Sequelize ORM (protects against SQL injection)
- ✅ Password hashing with bcrypt
- ✅ Rate limiting implemented
- ✅ Input validation middleware exists
- ✅ Winston logger configured
- ✅ Error handling middleware present
- ✅ CORS configured (needs hardening)
- ✅ Health check endpoint exists

---

**Report Generated:** $(date)
**Next Steps:** Address critical issues immediately before deployment
