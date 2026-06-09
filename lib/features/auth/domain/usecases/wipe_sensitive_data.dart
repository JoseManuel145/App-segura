import '../repositories/auth_repository.dart';

class WipeSensitiveDataUseCase {
  final AuthRepository repository;

  WipeSensitiveDataUseCase(this.repository);

  Future<void> call() async {
    await repository.clearAllSensitiveData();
  }
}
