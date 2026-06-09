import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureDataService {
  SecureDataService._();
  static final SecureDataService instance = SecureDataService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final ValueNotifier<int> dataRevision = ValueNotifier<int>(0);

  // Claves requeridas para la demostración
  static const kAccessToken  = 'access_token';
  static const kRefreshToken = 'refresh_token';
  static const kUserEmail    = 'user_email';
  static const kPrivateKey   = 'private_key';

  static const sensitiveKeys = <String>[
    kAccessToken,
    kRefreshToken,
    kUserEmail,
    kPrivateKey,
  ];

  Future<void> seedSensitiveData(String email) async {
    await _storage.write(key: kAccessToken,  value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
    await _storage.write(key: kRefreshToken, value: 'def456-ghi789-jkl012');
    await _storage.write(key: kUserEmail,    value: email);
    await _storage.write(key: kPrivateKey,   value: '-----BEGIN PRIVATE KEY-----\nMIIEvA...');
    dataRevision.value++;
  }

  Future<Map<String, String>> readSensitive() async {
    final out = <String, String>{};
    for (final k in sensitiveKeys) {
      out[k] = await _storage.read(key: k) ?? '— vacío —';
    }
    return out;
  }

  Future<void> clearSensitiveData() async {
    await _storage.deleteAll();
    dataRevision.value++;
    debugPrint('🗑️ [SecureDataService] Datos sensibles eliminados localmente.');
  }
}
