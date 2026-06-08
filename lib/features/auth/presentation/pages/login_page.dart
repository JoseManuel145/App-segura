import 'package:flutter/material.dart';
import 'package:login_app/core/security/screen_security_service.dart';
import 'package:login_app/core/security/screen_security_service_impl.dart';
import 'package:login_app/core/location/location_service.dart';
import 'package:login_app/core/location/location_service_impl.dart';

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
  late final LocationService _locationService;

  // Estado para la verificación de GPS
  bool _checkingGps = true;
  bool _fakeGpsDetected = false;

  @override
  void initState() {
    super.initState();
    _securityService = ScreenSecurityServiceImpl();
    _locationService = LocationServiceImpl();
    
    _securityService.enableProtection();
    _verificarGps();
  }

  Future<void> _verificarGps() async {
    final esFake = await _locationService.isFakeGps();
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

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      // Aquí conectarías con tu caso de uso / backend
      debugPrint('Email: $email | Password: $password');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Mientras verifica el GPS, mostrar loader
    if (_checkingGps) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Si detecta Fake GPS, mostrar pantalla de bloqueo
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
                  const Text(
                    'Acceso bloqueado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Se detectó una ubicación falsa (Fake GPS) o el '
                    'servicio de ubicación está desactivado. '
                    'Desactiva la app de ubicación simulada para continuar.',
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

    // 3. Si todo está bien, mostrar el login normal
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (!value.contains('@')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onLogin,
                    child: const Text('Iniciar sesión'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}