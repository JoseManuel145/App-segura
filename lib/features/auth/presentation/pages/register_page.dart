import 'package:flutter/material.dart';
import '../../../../core/security/secure_data_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/register_usecase.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late final RegisterUseCase _registerUseCase;

  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepositoryImpl(SecureDataService.instance);
    _registerUseCase = RegisterUseCase(authRepository);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
      await _registerUseCase.call(
        _emailController.text, 
        _passwordController.text
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente localmente.')),
      );

      Navigator.pop(context); // Regresa al login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Local')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Nuevo Correo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onRegister,
                    child: const Text('CREAR CUENTA'),
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
