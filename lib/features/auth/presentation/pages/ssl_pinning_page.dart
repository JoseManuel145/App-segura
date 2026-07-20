import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/security/ssl_pinning_service.dart';

class SslPinningPage extends StatefulWidget {
  const SslPinningPage({super.key});

  @override
  State<SslPinningPage> createState() => _SslPinningPageState();
}

class _SslPinningPageState extends State<SslPinningPage> {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://jsonplaceholder.typicode.com/posts/1',
  );
  final TextEditingController _fingerprintController = TextEditingController();

  bool _enablePinning = true;
  bool _isLoading = false;
  SslPinningResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _fingerprintController.text =
        '6F:73:ED:49:9D:45:EE:F0:03:73:FD:96:A4:20:B1:19:56:32:65:C1:AF:9A:C0:55:65:30:89:80:95:C7:70:71';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _fingerprintController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _lastResult = null;
    });

    final result = await SslPinningService.makeRequest(
      url: _urlController.text.trim(),
      expectedFingerprint: _fingerprintController.text.trim(),
      enablePinning: _enablePinning,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _lastResult = result;
      });

      // Si obtuvimos un fingerprint detectado durante la prueba, podemos autocompletarlo si el controlador está vacío
      if (result.serverFingerprint != null && _fingerprintController.text.isEmpty) {
        _fingerprintController.text = result.serverFingerprint!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSL / TLS Pinning Demo'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner explicativo de la actividad
            Card(
              color: Colors.indigo.shade50,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.indigo.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.indigo, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Protección contra Ataques MitM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Esta pantalla valida la huella digital SHA-256 del certificado SSL/TLS del servidor antes de establecer cualquier comunicación. Si un Proxy (OWASP ZAP, Charles o HTTP Toolkit) intenta interceptar la conexión, la app abortará la petición.',
                      style: TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Controles de Configuración
            const Text(
              'CONFIGURACIÓN DE LA PETICIÓN:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),

            // Selector Con Pinning / Sin Pinning
            Container(
              decoration: BoxDecoration(
                color: _enablePinning ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _enablePinning ? Colors.green.shade300 : Colors.orange.shade300,
                ),
              ),
              child: SwitchListTile(
                title: Text(
                  _enablePinning ? 'Modo: CON SSL Pinning (Seguro)' : 'Modo: SIN SSL Pinning (Vulnerable)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _enablePinning ? Colors.green.shade900 : Colors.orange.shade900,
                  ),
                ),
                subtitle: Text(
                  _enablePinning
                      ? 'Rechaza certificados no autorizados o proxies MitM.'
                      : 'Acepta cualquier certificado. Úsalo para probar la interceptación en el Proxy.',
                  style: const TextStyle(fontSize: 12),
                ),
                value: _enablePinning,
                activeThumbColor: Colors.green.shade700,
                onChanged: (value) {
                  setState(() {
                    _enablePinning = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 14),

            // Campo URL API
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL de la API Objetivo (HTTPS)',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Campo Huella SHA-256
            TextField(
              controller: _fingerprintController,
              maxLines: 2,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                labelText: 'Huella Digital SHA-256 Esperada',
                hintText: 'Ejemplo: 34:04:1E:59:...',
                prefixIcon: const Icon(Icons.fingerprint),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  tooltip: 'Pegar del portapapeles',
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      _fingerprintController.text = data!.text!;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Ayuda comando openssl
            ExpansionTile(
              dense: true,
              title: const Text(
                '💡 ¿Cómo extraer la huella con OpenSSL?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey.shade900,
                  child: SelectableText(
                    'openssl s_client -connect jsonplaceholder.typicode.com:443 -servername jsonplaceholder.typicode.com < /dev/null 2>/dev/null | openssl x509 -noout -fingerprint -sha256',
                    style: TextStyle(
                      color: Colors.greenAccent.shade200,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón Ejecutar Petición
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _testConnection,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isLoading ? 'EVALUANDO CERTIFICADO...' : 'PROBAR CONEXIÓN HTTPS',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Resultado visual de la PoC
            if (_lastResult != null) ...[
              const Text(
                'RESULTADO DE LA PRUEBA (PoC):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),

              // Card de Estado Principal
              Card(
                color: _lastResult!.isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _lastResult!.isSuccess ? Colors.green.shade400 : Colors.red.shade400,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _lastResult!.isSuccess ? Icons.check_circle : Icons.gpp_bad,
                            color: _lastResult!.isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _lastResult!.isSuccess
                                  ? 'CONEXIÓN EXITOSA (HTTP ${_lastResult!.statusCode ?? 200})'
                                  : '🔴 CONEXIÓN RECHAZADA / ATAQUE MitM DETECTADO',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _lastResult!.isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _lastResult!.message,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _lastResult!.isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Consola de Log Técnico
              const Text(
                'LOGS Y REGISTRO TÉCNICO (Para Captura de Pantalla):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _lastResult!.rawLog,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
