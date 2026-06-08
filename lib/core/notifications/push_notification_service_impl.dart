import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_service.dart';

class PushNotificationServiceImpl implements PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  Future<void> initialize() async {
    // Solicitar permisos (especialmente importante en iOS)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Manejar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        _handleDataMessage(message.data);
      }
    });

    // Manejar mensajes en segundo plano/terminado
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleDataMessage(Map<String, dynamic> data) {
    // TODO: Implementar lógica de seguridad basada en los datos recibidos
    // Ejemplo: Bloqueo remoto, limpieza de sesión, etc.
    print('Data Message recibido: $data');
  }

  @override
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}

// Esta función debe estar fuera de la clase para que FCM pueda ejecutarla en un isolate separado
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Manejando mensaje en background: ${message.messageId}');
  if (message.data.isNotEmpty) {
    print('Datos del mensaje en background: ${message.data}');
  }
}
