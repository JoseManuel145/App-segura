import '../../domain/entities/sensitive_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/security/secure_data_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureDataService _secureDataService;

  AuthRepositoryImpl(this._secureDataService);

  @override
  Future<void> clearAllSensitiveData() async {
    await _secureDataService.clearSensitiveData();
  }

  @override
  Future<SensitiveInfo> getSensitiveData() async {
    final data = await _secureDataService.readSensitive();
    return SensitiveInfo(
      accessToken: data[SecureDataService.kAccessToken] ?? '— vacío —',
      refreshToken: data[SecureDataService.kRefreshToken] ?? '— vacío —',
      userEmail: data[SecureDataService.kUserEmail] ?? '— vacío —',
      privateKey: data[SecureDataService.kPrivateKey] ?? '— vacío —',
    );
  }

  @override
  Future<void> saveSensitiveData(String email) async {
    await _secureDataService.seedSensitiveData(email);
  }
}
