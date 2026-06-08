abstract class PushNotificationService {
  Future<void> initialize();
  Future<String?> getToken();
}
