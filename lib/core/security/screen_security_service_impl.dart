import 'package:flutter/services.dart';
import 'screen_security_service.dart';

class ScreenSecurityServiceImpl implements ScreenSecurityService {
  static const MethodChannel _channel = MethodChannel('screen_security');

  @override
  Future<void> enableProtection() async {
    await _channel.invokeMethod('enable');
  }

  @override
  Future<void> disableProtection() async {
    await _channel.invokeMethod('disable');
  }
}