import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/security/secure_data_service.dart';
import '../../../../core/security/session_manager.dart';
import '../../../../core/security/screen_security_service.dart';
import '../../../../core/security/screen_security_service_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/sensitive_info.dart';
import '../../domain/usecases/get_sensitive_data.dart';

import 'tax_calculator_page.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final ScreenSecurityService _securityService;
  late final GetSensitiveDataUseCase _getSensitiveDataUseCase;
  late final AuthRepositoryImpl _authRepository;
  SensitiveInfo? _sensitiveInfo;

  @override
  void initState() {
    super.initState();
    _securityService = ScreenSecurityServiceImpl();
    _securityService.enableProtection();

    final secureService = SecureDataService.instance;
    _authRepository = AuthRepositoryImpl(secureService);
    _getSensitiveDataUseCase = GetSensitiveDataUseCase(_authRepository);

    secureService.dataRevision.addListener(_updateUI);
    _updateUI();
  }

  void _updateUI() async {
    final info = await _getSensitiveDataUseCase.call();
    if (mounted) {
      setState(() {
        _sensitiveInfo = info;
      });
    }
  }

  void _logout() async {
    await _authRepository.clearAllSensitiveData();
    if (mounted) {
      // Detener el monitoreo al cerrar sesión manualmente
      Provider.of<SessionManager>(context, listen: false).stop();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _securityService.disableProtection();
    SecureDataService.instance.dataRevision.removeListener(_updateUI);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil Seguro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateUI,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              color: Colors.indigo,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Protección de pantalla activa y monitoreo de inactividad.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SESIÓN ACTUAL:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (_sensitiveInfo != null) ...[
              _buildDataTile('Usuario', _sensitiveInfo!.userEmail),
              _buildDataTile('Token de Acceso', _sensitiveInfo!.accessToken),
              _buildDataTile('Refresh Token', _sensitiveInfo!.refreshToken),
              _buildDataTile('Clave Privada', _sensitiveInfo!.privateKey),
            ],
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaxCalculatorPage()),
                  );
                },
                icon: const Icon(Icons.calculate),
                label: const Text('CALCULADORA DE IMPUESTOS'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('CERRAR SESIÓN MANUALMENTE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTile(String title, String value) {
    final isEmpty = value == '— vacío —';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isEmpty ? Colors.red : Colors.green.shade700,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        dense: true,
      ),
    );
  }
}
