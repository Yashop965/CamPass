const admin = require('firebase-admin');
const path = require('path');

let initialized = false;

/**
 * Initialize Firebase Admin SDK
 *
 * Download service account key from Firebase Console:
 * 1. Go to Project Settings → Service Accounts
 * 2. Click "Generate new private key"
 * 3. Save as `serviceAccountKey.json` in backend root
 *
 * DO NOT COMMIT serviceAccountKey.json TO VERSION CONTROL
 * Add to .gitignore
 */
var serviceAccount = require("../../serviceAccountKey.json");

function initializeFirebase() {
  if (initialized) {
    return admin;
  }

  try {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });

    initialized = true;
    console.log('Firebase Admin SDK initialized successfully');
    return admin;
  } catch (error) {
    console.error('Error initializing Firebase:', error.message);
    console.log(
      'Ensure serviceAccountKey.json exists in project root'
    );
    return null;
  }
}

/**
 * Send message to specific FCM topic
 */
async function sendToTopic(topic, notification, data = {}) {
  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: data,
      topic: topic,
    };

    const response = await admin.messaging().send(message);
    console.log(`Message sent to topic ${topic}:`, response);
    return response;
  } catch (error) {
    console.error(`Error sending message to topic ${topic}:`, error);
    throw error;
  }
}

/**
 * Send message to specific device token
 */
async function sendToDevice(deviceToken, notification, data = {}) {
  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: data,
      token: deviceToken,
    };

    const response = await admin.messaging().send(message);
    console.log('Message sent to device:', response);
    return response;
  } catch (error) {
    console.error('Error sending message to device:', error);
    throw error;
  }
}

/**
 * Send multicast message to multiple devices
 */
async function sendMulticast(deviceTokens, notification, data = {}) {
  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: data,
    };

    const response = await admin
      .messaging()
      .sendMulticast({
        ...message,
        tokens: deviceTokens,
      });

    console.log('Multicast message response:', response);
    return response;
  } catch (error) {
    console.error('Error sending multicast message:', error);
    throw error;
  }
}

/**
 * Send SOS alert notification
 */
async function sendSOSAlert(
  targetTopic,
  studentName,
  studentId,
  latitude,
  longitude,
  alertType = 'automatic'
) {
  try {
    const notification = {
      title: '🚨 SOS Alert!',
      body: `${studentName} has triggered an emergency alert`,
    };

    const data = {
      type: 'sos_alert',
      studentId: studentId,
      studentName: studentName,
      alertType: alertType,
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      timestamp: new Date().toISOString(),
    };

    return await sendToTopic(targetTopic, notification, data);
  } catch (error) {
    console.error('Error sending SOS alert:', error);
    throw error;
  }
}

/**
 * Send geofence violation notification
 */
async function sendGeofenceViolation(
  targetTopic,
  studentName,
  studentId,
  latitude,
  longitude
) {
  try {
    const notification = {
      title: '⚠️ Geofence Violation',
      body: `${studentName} is outside campus boundaries`,
    };

    const data = {
      type: 'geofence_violation',
      studentId: studentId,
      studentName: studentName,
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      timestamp: new Date().toISOString(),
    };

    return await sendToTopic(targetTopic, notification, data);
  } catch (error) {
    console.error('Error sending geofence violation:', error);
    throw error;
  }
}

/**
 * Send pass status update notification
 */
async function sendPassStatusUpdate(
  targetTopic,
  studentName,
  passType,
  status
) {
  try {
    const statusMessages = {
      approved: `✅ Your ${passType} pass has been approved`,
      rejected: `❌ Your ${passType} pass was rejected`,
      expired: `⏰ Your ${passType} pass has expired`,
      pending: `⏳ Your ${passType} pass is pending approval`,
    };

    const notification = {
      title: 'Pass Status Update',
      body: statusMessages[status] || `Pass status: ${status}`,
    };

    const data = {
      type: 'pass_status',
      studentName: studentName,
      passType: passType,
      status: status,
      timestamp: new Date().toISOString(),
    };

    return await sendToTopic(targetTopic, notification, data);
  } catch (error) {
    console.error('Error sending pass status update:', error);
    throw error;
  }
}

/**
 * Subscribe device to topic
 */
async function subscribeToTopic(deviceTokens, topic) {
  try {
    const response = await admin
      .messaging()
      .subscribeToTopic(deviceTokens, topic);
    console.log(`Subscribed to topic ${topic}:`, response);
    return response;
  } catch (error) {
    console.error(`Error subscribing to topic ${topic}:`, error);
    throw error;
  }
}

/**
 * Unsubscribe device from topic
 */
async function unsubscribeFromTopic(deviceTokens, topic) {
  try {
    const response = await admin
      .messaging()
      .unsubscribeFromTopic(deviceTokens, topic);
    console.log(`Unsubscribed from topic ${topic}:`, response);
    return response;
  } catch (error) {
    console.error(`Error unsubscribing from topic ${topic}:`, error);
    throw error;
  }
}

module.exports = {
  initializeFirebase,
  sendToTopic,
  sendToDevice,
  sendMulticast,
  sendSOSAlert,
  sendGeofenceViolation,
  sendPassStatusUpdate,
  subscribeToTopic,
  unsubscribeFromTopic,
  getAdmin: () => admin,
};
