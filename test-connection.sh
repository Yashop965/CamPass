#!/bin/bash

# CAMPASS Connection Test Script
# Tests the connection between frontend and backend

echo "🔍 Testing CAMPASS Frontend-Backend Connection"
echo "=============================================="

BACKEND_URL="http://192.168.246.166:5000"

# Test backend health
echo "Testing backend health..."
if curl -s "$BACKEND_URL/health" > /dev/null; then
    echo "✅ Backend is responding"
else
    echo "❌ Backend is not responding at $BACKEND_URL"
    echo "   Make sure the backend is running: cd backend && npm start"
    exit 1
fi

# Test API endpoints
echo "Testing API endpoints..."

# Health check
HEALTH_RESPONSE=$(curl -s "$BACKEND_URL/health")
if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    echo "✅ Health check passed"
else
    echo "❌ Health check failed"
fi

# Test CORS
CORS_TEST=$(curl -s -H "Origin: http://localhost:3000" -H "Access-Control-Request-Method: GET" -X OPTIONS "$BACKEND_URL/api/auth/login")
if echo "$CORS_TEST" | grep -q "200"; then
    echo "✅ CORS configuration looks good"
else
    echo "⚠️  CORS might need configuration"
fi

echo ""
echo "🎯 Frontend-Backend Connection Test Complete"
echo "============================================"
echo ""
echo "If all tests passed, your setup is ready for production!"
echo "Make sure to:"
echo "1. Update API URLs in frontend for production"
echo "2. Configure Firebase properly"
echo "3. Set up SSL certificates"
echo "4. Configure production database"
echo ""
echo "For detailed deployment instructions, see DEPLOYMENT_GUIDE.md"