import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';   // SystemNavigator
import 'package:provider/provider.dart';

import '../../../../core/location/location_service_impl.dart';
import '../../../../core/security/debug_security_service.dart';
import '../../../../core/security/debug_security_service_impl.dart';
import '../../../../core/security/screen_security_service.dart';
import '../../../../core/security/screen_security_service_impl.dart';
import '../../../../core/security/secure_data_service.dart';
import '../../../../core/security/session_manager.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import 'register_page.dart';
import 'personal_info_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final ScreenSecurityService _securityService;
  late final DebugSecurityService _debugService;
  late final LoginUseCase _loginUseCase;

  bool _checkingGps = true;
  bool _fakeGpsDetected = false;

  @override
  void initState() {
    super.initState();
    // Inicialización de servicios y arquitectura
    _securityService = ScreenSecurityServiceImpl();
    _securityService.enableProtection();
    _debugService = DebugSecurityServiceImpl();
    
    final authRepository = AuthRepositoryImpl(SecureDataService.instance);
    _loginUseCase = LoginUseCase(authRepository);

    // Verificaciones de seguridad iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarDepuracionUsb();
    });

    _verificarGps();
  }

  Future<void> _verificarDepuracionUsb() async {
    // Comentamos kDebugMode para permitir que la demo detecte el bloqueo incluso
    // mientras desarrollamos, si es que tienes el USB Debug activado.
    // if (kDebugMode) return; 

    debugPrint('🔍 [Security] Iniciando auditoría de Depuración USB...');
    final activa = await _debugService.isUsbDebuggingEnabled();
    
    debugPrint('🔍 [Security] Resultado de Depuración USB: ${activa ? "ACTIVADA (BLOQUEAR)" : "DESACTIVADA (OK)"}');

    if (!mounted) return;
    if (activa) {
      _mostrarBloqueoUsb();
    }
  }

  void _mostrarBloqueoUsb() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(Icons.usb_off, color: Colors.red, size: 48),
          title: const Text('Aplicación bloqueada'),
          content: const Text(
            'Por políticas de seguridad, esta aplicación no puede ejecutarse '
            'mientras la Depuración USB esté activa.\n\n'
            'Desactiva la opción "Depuración por USB" en '
            'Ajustes → Opciones de desarrollador, y vuelve a abrir la app.',
          ),
          actions: [
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text('Cerrar aplicación'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verificarGps() async {
    // CORRECCIÓN: Instanciar el servicio para llamar al método no-estático
    final locationService = LocationServiceImpl();
    final esFake = await locationService.isFakeGps();
    
    if (!mounted) return;
    setState(() {
      _fakeGpsDetected = esFake;
      _checkingGps = false;
    });
  }

  Future<void> _reintentarGps() async {
    setState(() {
      _checkingGps = true;
      _fakeGpsDetected = false;
    });
    await _verificarGps();
  }

  @override
  void dispose() {
    _securityService.disableProtection();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await _loginUseCase.call(
        _emailController.text, 
        _passwordController.text
      );

      if (!mounted) return;

      if (success) {
        // Iniciar el monitoreo de inactividad
        Provider.of<SessionManager>(context, listen: false).start();
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas o usuario no registrado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingGps) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_fakeGpsDetected) {
      return Scaffold(
        backgroundColor: Colors.red.shade900,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.gpp_bad, color: Colors.white, size: 80),
                  const SizedBox(height: 16),
                  const Text('Acceso bloqueado',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Se detectó una ubicación falsa (Fake GPS) o el servicio '
                    'de ubicación está desactivado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _reintentarGps,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_person, size: 100, color: Colors.blueGrey),
                  const SizedBox(height: 30),
                  const Text(
                    'App Segura Demo',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo requerido';
                      if (!v.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onLogin,
                      child: const Text('INICIAR SESIÓN'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
