import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../firebase_options.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/wipe_sensitive_data.dart';
import 'secure_data_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final data = message.data;
  debugPrint('📩 [Background] Mensaje recibido: $data');

  if (data['action'] == 'WIPE_SECURE_DATA') {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    await storage.deleteAll();
    debugPrint('🗑️ [Background] Wipe ejecutado con éxito.');
  }
}

class FcmService {
  static final _fcm = FirebaseMessaging.instance;
  static const _actionWipe = 'WIPE_SECURE_DATA';

  static final _authRepository = AuthRepositoryImpl(SecureDataService.instance);
  static final _wipeUseCase = WipeSensitiveDataUseCase(_authRepository);

  static Future<void> init() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _fcm.getToken();
    debugPrint('\n' + '=' * 40);
    debugPrint('🚀 TOKEN PARA PRUEBA (Cópialo en Firebase Console):');
    debugPrint('$token');
    debugPrint('=' * 40 + '\n');

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  static void _handleMessage(RemoteMessage message) {
    final data = message.data;
    debugPrint('📩 [Foreground] Mensaje recibido: $data');

    if (data['action'] == _actionWipe) {
      // Ejecución a través del Caso de Uso
      _wipeUseCase.call();
    }
  }
}
