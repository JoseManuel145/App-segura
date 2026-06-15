abstract class DebugSecurityService {
  /// true si la Depuración USB (ADB) está activada en el dispositivo.
  Future<bool> isUsbDebuggingEnabled();
}