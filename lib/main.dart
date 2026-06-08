import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'core/security/fcm_service.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Registra el handler de segundo plano / app cerrada (debe ir antes de runApp).
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Permisos, token e listeners de primer plano.
  await FcmService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      home: const LoginPage(),
    );
  }
}