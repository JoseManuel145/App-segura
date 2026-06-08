# login_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Arquitectura actual
```
├── core
│   └── security
│       ├── screen_security_service.dart
│       └── screen_security_service_impl.dart
├── features
│   └── auth
│       ├── data
│       ├── domain
│       └── presentation
│           ├── pages
│           │   └── login_page.dart
│           ├── state
│           └── widgets
├── services
│   └── gps_check.dart
└── main.dart
```
