import '../entities/sensitive_info.dart';

abstract class AuthRepository {
  Future<void> clearAllSensitiveData();
  Future<void> saveSensitiveData(String email);
  Future<SensitiveInfo> getSensitiveData();
}
