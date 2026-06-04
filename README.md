# Temple App

Temple App is a personal learning project built with Flutter, Node.js, and MongoDB. I created it in my free time while learning how to connect a mobile app to a backend API and database.

## About

This project is a temple-themed login and dashboard app. The Flutter frontend communicates with an Express backend, which in turn works with MongoDB for data storage. It is still an evolving learning project, so the code and features may continue to change over time.

## Tech Stack

- Flutter
- Dart
- Node.js
- Express.js
- MongoDB

## Features

- Mobile-friendly Flutter UI
- Login flow with mobile number and OTP request
- Backend API integration using HTTP
- MongoDB-based server architecture
- Simple temple dashboard with a drawer menu

## Project Structure

```text
temple_app/
lib/        Flutter app code
backend/    Node.js + Express API
android/    Android native project files
ios/        iOS native project files
web/        Web build files
windows/    Windows desktop build files
linux/      Linux desktop build files
macos/      macOS desktop build files
```

## Getting Started

### Prerequisites

- Flutter SDK
- Node.js
- MongoDB

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd temple_app
```

### 2. Run the backend

```bash
cd backend
npm install
npm start
```

By default, the backend runs on `http://localhost:3000`.

### 3. Run the Flutter app

From the project root:

```bash
flutter pub get
flutter run
```

If you need to point the app to a different API URL, pass it when running Flutter:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

## Notes

- The app currently uses a simple OTP flow for learning purposes.
- This is not intended to be a production-ready authentication system.
- Some screens and backend endpoints may still be under active development.

## Future Improvements

- Add proper authentication and OTP validation
- Expand the temple dashboard features
- Improve error handling and form validation
- Add environment-based configuration for deployment

## License

This project is created for learning and personal development.
