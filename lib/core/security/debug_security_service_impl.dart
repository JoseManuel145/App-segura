import 'debug_security_service.dart';

class DebugSecurityServiceImpl implements DebugSecurityService {
  @override
  Future<bool> isUsbDebuggingEnabled() async {
    // Verificación deshabilitada para permitir desarrollo y pruebas con proxy (MitM)
    return false;
  }
}
