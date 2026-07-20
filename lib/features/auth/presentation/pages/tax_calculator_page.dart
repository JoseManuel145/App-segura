import 'package:flutter/material.dart';
import '../../../../core/security/financial_service.dart';

class TaxCalculatorPage extends StatefulWidget {
  const TaxCalculatorPage({super.key});

  @override
  State<TaxCalculatorPage> createState() => _TaxCalculatorPageState();
}

class _TaxCalculatorPageState extends State<TaxCalculatorPage> {
  final _amountController = TextEditingController();
  final _financialService = FinancialService();
  double? _result;

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount > 0) {
      // Usamos un ID de transacción simulado para la lógica del servicio
      final tax = _financialService.computeSecurityTax(amount, "TXN-998877");
      setState(() {
        _result = tax;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Impuestos')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Card(
              color: Colors.amberAccent,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Esta página procesa información financiera usando algoritmos de negocio internos.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto a procesar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculate,
                child: const Text('CALCULAR IMPUESTO DE SEGURIDAD'),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 40),
              const Text('RESULTADO DEL PROCESAMIENTO:'),
              Text(
                '\$$_result',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
