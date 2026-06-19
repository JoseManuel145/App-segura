import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';
import 'debug_security_service.dart';

class DebugSecurityServiceImpl implements DebugSecurityService {
  @override
  Future<bool> isUsbDebuggingEnabled() async {
    try {
      // 1. Verificar si es un dispositivo real o emulador
      final isRealDevice = await SafeDevice.isRealDevice;
      
      // 2. Verificar específicamente la depuración USB
      final isDevelopmentMode = await SafeDevice.isDevelopmentModeEnable;
      
      // 3. Verificar si el dispositivo está rooteado
      final isJailBroken = await SafeDevice.isJailBroken;

      debugPrint('🛡️ [Security Audit] Dispositivo Real: $isRealDevice');
      debugPrint('🛡️ [Security Audit] Modo Desarrollador/USB Debug: $isDevelopmentMode');
      debugPrint('🛡️ [Security Audit] Root/Jailbreak: $isJailBroken');

      // Bloqueamos si el modo desarrollador está activo en un dispositivo real
      // O si se detecta depuración activa.
      return isDevelopmentMode;
      
    } catch (e) {
      debugPrint('❌ [Security Error] Error al verificar depuración: $e');
      return false;
    }
  }
}
