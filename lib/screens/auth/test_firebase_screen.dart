import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';

class TestFirebaseScreen extends StatefulWidget {
  const TestFirebaseScreen({Key? key}) : super(key: key);

  @override
  State<TestFirebaseScreen> createState() => _TestFirebaseScreenState();
}

class _TestFirebaseScreenState extends State<TestFirebaseScreen> {
  final _firebase = FirebaseService();
  String _status = 'Iniciando...';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _testFirebase();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $message');
    });
    Logger.info(message, tag: '[TestFirebase]');
  }

  Future<void> _testFirebase() async {
    try {
      _addLog('1. Probando conexión a Firebase...');
      bool connected = await _firebase.verifyConnection();
      _addLog('2. Conexión: $connected');

      _addLog('3. Intentando crear usuario...');
      await _firebase.signUp(
        'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        'Password123',
        'Test User',
      );
      _addLog('4. ¡Usuario creado exitosamente!');
      setState(() => _status = 'ÉXITO');
    } catch (e) {
      _addLog('ERROR: $e');
      _addLog('Tipo: ${e.runtimeType}');
      setState(() => _status = 'ERROR: $e');
      Logger.error('Error completo: $e', tag: '[TestFirebase]');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Firebase')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _status.contains('ÉXITO') ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Logs:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Text(
                    _logs[index],
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
