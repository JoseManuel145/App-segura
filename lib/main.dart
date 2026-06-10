import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/security/fcm_service.dart';
import 'core/security/session_manager.dart';
import 'core/security/secure_data_service.dart';
import 'features/auth/domain/usecases/expire_session_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/widgets/global_interaction_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FcmService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionManager(
        timeout: const Duration(seconds: 10),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final ExpireSessionUseCase _expireUseCase;

  @override
  void initState() {
    super.initState();
    _expireUseCase = ExpireSessionUseCase(SecureDataService.instance);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Escuchamos al SessionManager para actuar cuando expire
    final session = Provider.of<SessionManager>(context, listen: false);
    
    session.removeListener(_handleSessionTimeout);
    session.addListener(_handleSessionTimeout);
  }

  Future<void> _handleSessionTimeout() async {
    final session = Provider.of<SessionManager>(context, listen: false);
    
    if (session.isExpired) {
      debugPrint('[Session] Expirada por inactividad. Limpiando datos...');
      await _expireUseCase.call();

      final context = _navigatorKey.currentContext;
      if (context != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sesión expirada por inactividad. Datos eliminados."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      
      // Detenemos el monitoreo para que no siga disparando mientras estamos en el Login
      session.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalInteractionWrapper(
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'App segura',
        home: const LoginPage(),
      ),
    );
  }
}
