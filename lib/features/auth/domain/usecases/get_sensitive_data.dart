import '../entities/sensitive_info.dart';
import '../repositories/auth_repository.dart';

class GetSensitiveDataUseCase {
  final AuthRepository repository;

  GetSensitiveDataUseCase(this.repository);

  Future<SensitiveInfo> call() async {
    return await repository.getSensitiveData();
  }
}
