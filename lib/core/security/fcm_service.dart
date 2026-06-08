import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'secure_data_service.dart';

/// Handler de segundo plano / app cerrada. DEBE ser top-level.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmService.handleRemoteCommand(message);
}

class FcmService {
  static final _fcm = FirebaseMessaging.instance;
  static const _actionWipe = 'WIPE_USER_DATA';

  static Future<void> init() async {
    await _fcm.requestPermission();

    final token = await _fcm.getToken();
    debugPrint('=== FCM TOKEN ===\n$token');

    FirebaseMessaging.onMessage.listen(handleRemoteCommand);         
    FirebaseMessaging.onMessageOpenedApp.listen(handleRemoteCommand); 
  }

  /// Solo borra si el comando es WIPE **y** el uid objetivo coincide con el actual.
  static Future<void> handleRemoteCommand(RemoteMessage message) async {
    final data = message.data;
    if (data['action'] != _actionWipe) return;

    final targetUid  = data['targetUid'];
    final currentUid = await SecureDataService.instance.currentUserId();

    if (targetUid == null || targetUid != currentUid) {
      debugPrint('Wipe ignorado: objetivo=$targetUid ≠ actual=$currentUid');
      return; // <- garantiza que NO es una limpieza general
    }

    await SecureDataService.instance.wipeSensitiveData();
    debugPrint('✔ Wipe remoto ejecutado para uid $currentUid');
  }
}