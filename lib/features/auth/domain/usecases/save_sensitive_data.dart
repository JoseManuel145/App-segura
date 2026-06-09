import '../repositories/auth_repository.dart';

class SaveSensitiveDataUseCase {
  final AuthRepository repository;

  SaveSensitiveDataUseCase(this.repository);

  Future<void> call(String email) async {
    await repository.saveSensitiveData(email);
  }
}
