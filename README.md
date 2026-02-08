# CAMPASS - Student Safety & Tracking System

Campass is a comprehensive student safety and location tracking application designed to ensure the security of students within and outside campus premises. It features real-time tracking, SOS alerts, and role-based access for Students, Parents, Wardens, Guards, and Admins.

## Features

- **SOS Alert System**: Triggers high-priority alerts with sound to parents and admins via manual button or shake gesture.
- **Geofence Tracking**: Monitors student location in real-time and notifies when a student exits the defined 500m campus radius.
- **Smart Notifications**: Instant alerts for SOS, geofence violations, and general updates using Firebase Cloud Messaging.
- **Digital Pass System**: Generate and scan barcode-based passes for gate entry/exit.
- **Role-Based Access**: Specialized interfaces for Students, Parents, Wardens, Guards, and Administrators.

## Tech Stack

- **Frontend**: Flutter (Mobile App)
- **Backend**: Node.js with Express
- **Database**: PostgreSQL
- **Services**: Firebase Cloud Messaging (FCM), Google Maps API

## Getting Started

### Prerequisites

- Node.js & npm
- Flutter SDK
- PostgreSQL
- Android Studio / Xcode (for mobile simulation)

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure environment variables in `.env` (refer to `QUICK_REFERENCE.md`).
4. Start the server:
   ```bash
   npm start
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend/campass_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Documentation

For more detailed information, please refer to:
- `QUICK_REFERENCE.md`: Quick start guide and API overview.
- `DEPLOYMENT_GUIDE.md`: Detailed deployment instructions.
- `CODEBASE_AUDIT_REPORT.md`: Health check and audit report.

## License

[License Name]
