import '../../../../core/security/secure_data_service.dart';

class ExpireSessionUseCase {
  final SecureDataService secureDataService;

  ExpireSessionUseCase(this.secureDataService);

  Future<void> call() async {
    await secureDataService.clearSensitiveData();
  }
}
