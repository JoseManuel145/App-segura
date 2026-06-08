import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureDataService {
  SecureDataService._();
  static final SecureDataService instance = SecureDataService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Se incrementa tras cada cambio para refrescar la UI.
  final ValueNotifier<int> dataRevision = ValueNotifier<int>(0);

  static const _kUserId = 'user_id';
  static const kTarjeta = 'numero_tarjeta';
  static const kCurp    = 'curp';
  static const kToken   = 'token_sesion';
  static const kSaldo   = 'saldo_cuenta';

  static const sensitiveKeys = <String>[kTarjeta, kCurp, kToken, kSaldo];

  Future<void> seedSensitiveData(String userId) async {
    await _storage.write(key: _kUserId, value: userId);
    await _storage.write(key: kTarjeta, value: '4111 1111 1111 1111');
    await _storage.write(key: kCurp,    value: 'BAMB011215HCSXXX09');
    await _storage.write(key: kToken,   value: 'eyJhbGciOiJIUzI1NiJ9.demo');
    await _storage.write(key: kSaldo,   value: '\$48,250.00 MXN');
    dataRevision.value++;
  }

  Future<String?> currentUserId() => _storage.read(key: _kUserId);

  Future<Map<String, String>> readSensitive() async {
    final out = <String, String>{};
    for (final k in sensitiveKeys) {
      out[k] = await _storage.read(key: k) ?? '— vacío —';
    }
    return out;
  }

  /// Borra únicamente los campos sensibles.
  Future<void> wipeSensitiveData() async {
    for (final k in sensitiveKeys) {
      await _storage.delete(key: k);
    }
    dataRevision.value++;
  }
}