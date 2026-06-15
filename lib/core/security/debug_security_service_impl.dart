import 'package:flutter/services.dart';
import 'debug_security_service.dart';

class DebugSecurityServiceImpl implements DebugSecurityService {
  static const _channel = MethodChannel('com.example.login_app/debug_security');

  @override
  Future<bool> isUsbDebuggingEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isUsbDebuggingEnabled');
      return result ?? false;
    } on PlatformException {
      // Si el canal falla, devolvemos true (fail-closed: asumimos inseguro).
      // Es más conservador para una práctica de seguridad.
      return true;
    }
  }
}