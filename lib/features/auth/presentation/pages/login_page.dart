import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  
  late final LoginUseCase _loginUseCase;

  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepositoryImpl(SecureDataService.instance);
    _loginUseCase = LoginUseCase(authRepository);
  }

  @override
  void dispose() {
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
        // Iniciar el monitoreo de inactividad solo al loguearse con éxito
        if (mounted) {
          Provider.of<SessionManager>(context, listen: false).start();
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
          );
        }
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
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
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
