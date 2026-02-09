# collecta

A new Flutter project.

## Getting Started
clone repo then type in terminal: flutter pub get

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Poject structure


collecta/

│── functions/
│   └── index.js
│
├── lib/
│   │
│   ├── main.dart
│   │
│   ├── app/
│   │   ├── app.dart
│   │   ├── routes.dart
│   │   └── theme.dart
│   │
│   ├── config/
│   │   ├── firebase_options.dart
│   │   ├── api_config.dart
│   │   └── permissions.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   |   ├── organization_model.dart
│   │   │   └── user_model.dart
│   │   │
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   └── api_source.dart
│   │   │   └── local/
│   │   │       └── local_storage.dart
│   │   │
│   │   └── repositories/
│   │       ├── organization_repository.dart
│   │       └── user_repository.dart
│   │
│   ├── services/
│   │   ├── user_service.dart
│   │   └── organization_service.dart
│   │
│   │
│   ├── ui/
│   │   └── screens/
│   │           ├── debug_firestore_screen.dart
│   │           └── entering.dart

│   │
│   └── assets/ //TODO CHECK LOCATION
│
├── tools/
│   └── seed_firestore.dart
│
├── .env
└── pubspec.yaml
