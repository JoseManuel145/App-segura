import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';   // SystemNavigator
import 'package:login_app/core/security/screen_security_service.dart';
import 'package:login_app/core/security/screen_security_service_impl.dart';
import 'package:login_app/core/security/debug_security_service.dart';
import 'package:login_app/core/security/debug_security_service_impl.dart';

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

  bool _checkingGps = true;
  bool _fakeGpsDetected = false;

  @override
  void initState() {
    super.initState();
    _securityService = ScreenSecurityServiceImpl();
    _securityService.enableProtection();

    _debugService = DebugSecurityServiceImpl();

    // 1. Verificación temprana de Depuración USB (solo fuera de modo dev)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarDepuracionUsb();
    });

    // 2. Verificación de Fake GPS
    _verificarGps();
  }

  Future<void> _verificarDepuracionUsb() async {
    if (kDebugMode) return; // Excepción para desarrollo

    final activa = await _debugService.isUsbDebuggingEnabled();
    if (!mounted) return;
    if (activa) {
      _mostrarBloqueoUsb();
    }
  }

  void _mostrarBloqueoUsb() {
    showDialog(
      context: context,
      barrierDismissible: false, // No cierra al tocar fuera
      builder: (ctx) => PopScope(
        canPop: false, // No cierra con botón "atrás"
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
              onPressed: () => SystemNavigator.pop(), // Cierra la app limpio
              child: const Text('Cerrar aplicación'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verificarGps() async {
    final esFake = await GpsCheck.isFakeGps();
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
      debugPrint('Email: ${_emailController.text} | Password: ${_passwordController.text}');
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Login', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder()),
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
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _onLogin, child: const Text('Iniciar sesión')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
