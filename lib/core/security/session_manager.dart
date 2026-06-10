import 'dart:async';
import 'package:flutter/foundation.dart';

class SessionManager extends ChangeNotifier {
  final Duration timeout;
  Timer? _timer;
  bool _isExpired = false;
  bool _isActive = false; // Nueva bandera para controlar si la sesión está activa

  SessionManager({required this.timeout});

  bool get isExpired => _isExpired;
  bool get isActive => _isActive;

  /// Inicia el monitoreo de inactividad (llamar tras el login exitoso)
  void start() {
    _isActive = true;
    _isExpired = false;
    _resetTimer();
    debugPrint('🕒 [SessionManager] Monitoreo de inactividad INICIADO.');
  }

  /// Detiene el monitoreo (llamar tras logout o expiración)
  void stop() {
    _isActive = false;
    _isExpired = false;
    _timer?.cancel();
    debugPrint('🕒 [SessionManager] Monitoreo de inactividad DETENIDO.');
  }

  void registerActivity() {
    if (!_isActive || _isExpired) return;
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(timeout, _onTimeout);
  }

  void _onTimeout() {
    _isExpired = true;
    _isActive = false; // Se desactiva automáticamente al expirar
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
