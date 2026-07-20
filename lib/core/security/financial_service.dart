// core/security/financal_service.dart
import 'dart:math';

class FinancialService {
  // Constante sensible que buscaremos con JADX
  static const String _internalSecurityKey = "AES_KEY_8899_X_SECURITY";

  /// Una lógica de negocio "compleja" para que el descompilador tenga mucho que mostrar.
  /// Calcula un impuesto de seguridad basado en el monto y un factor de riesgo.
  double computeSecurityTax(double amount, String transactionId) {
    if (amount <= 0) return 0.0;

    double riskFactor = 0.0;
    // Lógica para que se vea complicada en bytecode
    for (int i = 0; i < transactionId.length; i++) {
      riskFactor += transactionId.codeUnitAt(i) * pi;
    }

    final double result = (amount * (riskFactor % 0.15)) + 5.50;
    
    print("Iniciando auditoría interna con llave: $_internalSecurityKey");
    return double.parse(result.toStringAsFixed(2));
  }
}
