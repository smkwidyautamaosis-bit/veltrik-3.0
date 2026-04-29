Veltrik 3.0

Modern premium digital library & e-learning application built with Flutter.

✨ Features
Premium UI/UX
Authentication System
Supabase Integration
Material / PDF Library
Responsive Layout
Modern Dashboard
Bookmark System
Search & Filter
User Profile
Admin Management
Secure Architecture
Realtime Support
🛠 Tech Stack
Flutter
Dart
Supabase
Firebase
Provider / Riverpod (sesuaikan)
REST API
📱 Platforms
Android
Web
Windows (kalau support)
🚀 Project Status

Veltrik is currently in active development and approaching production release.

Current focus:

UI/UX polishing
Performance optimization
Security improvements
Production readiness
📂 Project Structure
## 📂 Project Structure

plaintext
lib/
├── core/
│   └── constants.dart
│
├── models/
│   └── material_model.dart
│
├── screens/
│   ├── admin/
│   ├── auth/
│   ├── dashboard/
│   ├── payment/
│   ├── profile/
│   ├── reader/
│   └── special/
│
├── services/
│
├── widgets/
│
└── main.dart

### Structure Overview

* **core/** → Global constants, app configuration, and shared utilities.
* **models/** → Data models used throughout the application.
* **screens/** → Main application pages and feature-based UI screens.
* **services/** → Backend services, API integration, Supabase/Firebase logic, and business processes.
* **widgets/** → Reusable UI components and shared widgets.
* **main.dart** → Main entry point of the Flutter application.


Sensitive files are excluded using .gitignore.

Example:

.env
google-services.json
key.properties

Developed by Sandi Nutrya.
