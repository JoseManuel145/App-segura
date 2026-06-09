# App Segura - Flutter

Este proyecto es una aplicación de Flutter enfocada en la implementación de medidas de seguridad de la información, siguiendo los principios de **Clean Architecture**.

## Arquitectura del Proyecto

El proyecto está organizado siguiendo una estructura de capas para garantizar la escalabilidad, mantenibilidad y facilidad de pruebas.

```text
lib/
├── core/                        # Funcionalidades transversales y servicios globales
│   ├── location/                # Servicio de validación de ubicación (Fake GPS)
│   │   ├── location_service.dart
│   │   └── location_service_impl.dart
│   ├── notifications/           # Manejo de Push Notifications y Data Messages
│   │   ├── push_notification_service.dart
│   │   └── push_notification_service_impl.dart
│   └── security/                # Servicios de seguridad (Pantalla, FCM, Almacenamiento Seguro)
│       ├── fcm_service.dart
│       ├── screen_security_service.dart
│       ├── screen_security_service_impl.dart
│       └── secure_data_service.dart
├── features/                    # Módulos de la aplicación basados en funcionalidades
│   └── auth/                    # Módulo de Autenticación
│       ├── data/                # Capa de Datos: Repositorios, Modelos y DataSources
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/              # Capa de Dominio: Entidades, Casos de Uso y Contratos
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/        # Capa de UI: Páginas, Widgets y Gestión de Estado
│           ├── pages/
│           │   └── login_page.dart
│           ├── state/
│           └── widgets/
└── main.dart                    # Punto de entrada de la aplicación
```

## Características de Seguridad Implementadas

1.  **Protección de Pantalla:** Implementación nativa para evitar capturas de pantalla y ocultar contenido en la vista de aplicaciones recientes.
2.  **Detección de Fake GPS:** Validación avanzada de la ubicación para prevenir el uso de herramientas de simulación de GPS.
3.  **Data Messages (FCM):** Sistema de comandos remotos para acciones críticas como el borrado remoto de datos (`WIPE_USER_DATA`).
4.  **Almacenamiento Seguro:** Uso de `flutter_secure_storage` con cifrado AES a nivel de hardware para proteger credenciales y tokens.
5.  **Clean Architecture:** Estructura modular que separa la lógica de negocio de los detalles de implementación (UI, Plugins, APIs).

## Requisitos y Configuración

- **Flutter SDK:** ^3.12.0
- **Firebase:** Requiere configuración activa (FCM habilitado).
- **Dependencias clave:** `geolocator`, `firebase_messaging`, `flutter_secure_storage`, `firebase_core`.
