class SensitiveInfo {
  final String accessToken;
  final String refreshToken;
  final String userEmail;
  final String privateKey;

  SensitiveInfo({
    required this.accessToken,
    required this.refreshToken,
    required this.userEmail,
    required this.privateKey,
  });

  bool get isEmpty =>
      accessToken == '— vacío —' &&
      refreshToken == '— vacío —' &&
      userEmail == '— vacío —' &&
      privateKey == '— vacío —';
}
