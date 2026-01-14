# collecta

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Poject structure

lib/
├── main.dart                    
│
├── app/                         
│   ├── app.dart                 
│   ├── routes.dart              
│   ├── theme.dart               
│   └── env.dart              
│
├── config/
│   ├── firebase_config.dart     
│   ├── database_config.dart     
│   └── permissions.dart         
│
├── data/
│   ├── models/                  
│   │   └── user_model.dart
│   │
│   ├── datasources/             
│   │   ├── remote/
│   │   │   └── firestore_source.dart
│   │   └── local/
│   │       └── local_storage.dart
│   │
│   └── repositories/            
│       └── user_repository.dart
│
├── services/                    
│   ├── auth_service.dart
│   ├── user_service.dart
│   └── country_service.dart
│
├── state/                       
│   ├── app_state.dart
│   └── auth_state.dart
│
├── ui/
│   ├── screens/                 
│   ├── widgets/                 
│   └── dialogs/
│
├── utils/
│   ├── validators.dart
│   ├── formatters.dart
│   └── logger.dart
│
└── assets/
