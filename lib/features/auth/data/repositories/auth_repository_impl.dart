import '../../domain/entities/sensitive_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/security/secure_data_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureDataService _secureDataService;

  AuthRepositoryImpl(this._secureDataService);

  @override
  Future<void> register(String email, String password) async {
    await _secureDataService.registerUser(email, password);
  }

  @override
  Future<bool> login(String email, String password) async {
    return await _secureDataService.authenticate(email, password);
  }

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
}
