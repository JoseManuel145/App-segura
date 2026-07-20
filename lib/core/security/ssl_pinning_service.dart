import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class SslPinningResult {
  final bool isSuccess;
  final int? statusCode;
  final String message;
  final String? serverFingerprint;
  final String rawLog;

  SslPinningResult({
    required this.isSuccess,
    this.statusCode,
    required this.message,
    this.serverFingerprint,
    required this.rawLog,
  });
}

class SslPinningService {
  /// Huella SHA-256 por defecto para jsonplaceholder.typicode.com
  static String defaultExpectedFingerprint =
      "6F:73:ED:49:9D:45:EE:F0:03:73:FD:96:A4:20:B1:19:56:32:65:C1:AF:9A:C0:55:65:30:89:80:95:C7:70:71";

  /// Realiza una petición GET con validación de SSL/TLS Pinning
  static Future<SslPinningResult> makeRequest({
    required String url,
    required String expectedFingerprint,
    required bool enablePinning,
  }) async {
    final StringBuffer logBuffer = StringBuffer();
    String? detectedFingerprint;
    bool certificateValid = true;

    logBuffer.writeln('[SSL Pinning] Iniciando petición a: $url');
    logBuffer.writeln('[SSL Pinning] Pinning Activo: $enablePinning');
    if (enablePinning) {
      logBuffer.writeln('[SSL Pinning] SHA-256 Esperado: $expectedFingerprint');
    }

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Configurar el adaptador IOHttpClientAdapter para plataformas de escritorio/móvil
    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();

        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Extraer la huella SHA-256 en formato hexadecimal
          final certDer = cert.der;
          final sha256Digest = sha256.convert(certDer).toString().toLowerCase();
          detectedFingerprint = _formatFingerprint(sha256Digest);

          logBuffer.writeln('[SSL Pinning] Host: $host:$port');
          logBuffer.writeln('[SSL Pinning] Subject: ${cert.subject}');
          logBuffer.writeln('[SSL Pinning] Issuer: ${cert.issuer}');
          logBuffer.writeln('[SSL Pinning] SHA-256 Certificado Servidor: $detectedFingerprint');

          if (!enablePinning) {
            logBuffer.writeln('[SSL Pinning] SSL Pinning DESACTIVADO. Permitiendo conexión...');
            return true;
          }

          // Limpiar formatos (quitar dos puntos o espacios)
          final cleanExpected = expectedFingerprint.replaceAll(':', '').replaceAll(' ', '').toLowerCase();
          final cleanDetected = sha256Digest.replaceAll(':', '').replaceAll(' ', '').toLowerCase();

          final matches = (cleanExpected == cleanDetected);

          if (matches) {
            logBuffer.writeln('✅ [SSL Pinning] VALIDACIÓN EXITOSA: La huella coincide con el servidor legítimo.');
            certificateValid = true;
            return true;
          } else {
            logBuffer.writeln('🔴 [SSL Pinning] ALERTA DE SEGURIDAD: La huella NO coincide.');
            logBuffer.writeln('    Esperado: $cleanExpected');
            logBuffer.writeln('    Detectado: $cleanDetected');
            logBuffer.writeln('    ¡Posible ataque de Intermediario (Man-in-the-Middle - MitM) o certificado no confiable!');
            certificateValid = false;
            return false; // Aborta la conexión TLS inmediatamente
          }
        };

        return client;
      };
    }

    try {
      final response = await dio.get(url);
      logBuffer.writeln('✅ Respuesta HTTP exitosa. Estado: ${response.statusCode}');

      return SslPinningResult(
        isSuccess: true,
        statusCode: response.statusCode,
        message: 'Conexión segura establecida con éxito (HTTP ${response.statusCode}).',
        serverFingerprint: detectedFingerprint,
        rawLog: logBuffer.toString(),
      );
    } on DioException catch (e) {
      logBuffer.writeln('❌ DioException capturada: ${e.type} - ${e.message}');
      
      String userMessage = 'Error en la conexión.';
      if (!certificateValid || e.type == DioExceptionType.connectionError || e.error is HandshakeException) {
        userMessage = '🔴 ALERTA DE SEGURIDAD (MitM): La app bloqueó la conexión porque el certificado del servidor fue modificado o interceptado por un tercero.';
      } else {
        userMessage = 'Error al consultar la API: ${e.message}';
      }

      return SslPinningResult(
        isSuccess: false,
        statusCode: e.response?.statusCode,
        message: userMessage,
        serverFingerprint: detectedFingerprint,
        rawLog: logBuffer.toString(),
      );
    } catch (e) {
      logBuffer.writeln('❌ Error inesperado: $e');
      return SslPinningResult(
        isSuccess: false,
        message: 'Error inesperado: $e',
        serverFingerprint: detectedFingerprint,
        rawLog: logBuffer.toString(),
      );
    }
  }

  static String _formatFingerprint(String hex) {
    final buffer = StringBuffer();
    for (int i = 0; i < hex.length; i += 2) {
      if (i > 0) buffer.write(':');
      buffer.write(hex.substring(i, i + 2).toUpperCase());
    }
    return buffer.toString();
  }
}
