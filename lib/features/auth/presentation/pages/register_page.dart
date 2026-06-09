import 'package:flutter/material.dart';
import '../../../../core/security/secure_data_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/save_sensitive_data.dart';
import 'personal_info_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final SaveSensitiveDataUseCase _saveSensitiveDataUseCase;

  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepositoryImpl(SecureDataService.instance);
    _saveSensitiveDataUseCase = SaveSensitiveDataUseCase(authRepository);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
      await _saveSensitiveDataUseCase.call(_emailController.text);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso. Datos sembrados.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onRegister,
                  child: const Text('REGISTRARSE Y PROTEGER'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
