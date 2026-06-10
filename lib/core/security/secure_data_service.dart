import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureDataService {
  SecureDataService._();
  static final SecureDataService instance = SecureDataService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final ValueNotifier<int> dataRevision = ValueNotifier<int>(0);

  // Claves para la sesión actual
  static const kAccessToken  = 'access_token';
  static const kRefreshToken = 'refresh_token';
  static const kUserEmail    = 'user_email';
  static const kPrivateKey   = 'private_key';

  // Prefijo para "base de datos" local de usuarios
  static const _userPrefix = 'user_pwd_';

  static const sensitiveKeys = [
    kAccessToken,
    kRefreshToken,
    kUserEmail,
    kPrivateKey,
  ];

  /// Registra un usuario localmente (Demo)
  Future<void> registerUser(String email, String password) async {
    await _storage.write(key: '$_userPrefix$email', value: password);
    debugPrint('📝 [Storage] Usuario $email registrado.');
  }

  /// Autentica contra el storage local y genera sesión (Demo)
  Future<bool> authenticate(String email, String password) async {
    final savedPwd = await _storage.read(key: '$_userPrefix$email');
    
    if (savedPwd != null && savedPwd == password) {
      // Si coincide, "generamos" los tokens de sesión
      await seedSensitiveData(email);
      return true;
    }
    return false;
  }

  Future<void> seedSensitiveData(String email) async {
    await _storage.write(key: kAccessToken,  value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
    await _storage.write(key: kRefreshToken, value: 'def456-ghi789-jkl012');
    await _storage.write(key: kUserEmail,    value: email);
    await _storage.write(key: kPrivateKey,   value: '-----BEGIN PRIVATE KEY-----\nMIIEvA...');
    dataRevision.value++;
    debugPrint('🔑 [Storage] Sesión iniciada para $email. Datos sembrados.');
  }

  Future<Map<String, String>> readSensitive() async {
    final out = <String, String>{};
    for (final k in sensitiveKeys) {
      out[k] = await _storage.read(key: k) ?? '— vacío —';
    }
    return out;
  }

  Future<void> clearSensitiveData() async {
    for (final key in sensitiveKeys) {
      await _storage.delete(key: key);
    }
    dataRevision.value++;
    debugPrint('🗑️ [Storage] Datos de sesión eliminados (Logout/Timeout).');
  }
}
