import 'package:flutter/material.dart';
import '../../../../core/security/secure_data_service.dart';
import '../../../../core/security/screen_security_service.dart';
import '../../../../core/security/screen_security_service_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/sensitive_info.dart';
import '../../domain/usecases/get_sensitive_data.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final ScreenSecurityService _securityService;
  late final GetSensitiveDataUseCase _getSensitiveDataUseCase;
  SensitiveInfo? _sensitiveInfo;

  @override
  void initState() {
    super.initState();
    _securityService = ScreenSecurityServiceImpl();
    _securityService.enableProtection();

    final authRepository = AuthRepositoryImpl(SecureDataService.instance);
    _getSensitiveDataUseCase = GetSensitiveDataUseCase(authRepository);

    SecureDataService.instance.dataRevision.addListener(_updateUI);
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
        title: const Text('Información Personal'),
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
                child: Text(
                  'Esta pantalla está protegida contra capturas de pantalla.\nLos datos aquí mostrados se borrarán si se recibe un comando WIPE remoto.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'DATOS SENSIBLES EN STORAGE:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (_sensitiveInfo != null) ...[
              _buildDataTile('User Email', _sensitiveInfo!.userEmail),
              _buildDataTile('Access Token', _sensitiveInfo!.accessToken),
              _buildDataTile('Refresh Token', _sensitiveInfo!.refreshToken),
              _buildDataTile('Private Key', _sensitiveInfo!.privateKey),
            ],
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.logout),
                label: const Text('CERRAR SESIÓN (VOLVER)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTile(String title, String value) {
    final isEmpty = value == '— vacío —';
    return ListTile(
      title: Text(title),
      subtitle: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isEmpty ? Colors.red : Colors.green,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      dense: true,
    );
  }
}
