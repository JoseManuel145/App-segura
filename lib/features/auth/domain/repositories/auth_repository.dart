import '../entities/sensitive_info.dart';

abstract class AuthRepository {
  Future<void> register(String email, String password);
  Future<bool> login(String email, String password);
  Future<void> clearAllSensitiveData();
  Future<SensitiveInfo> getSensitiveData();
}
