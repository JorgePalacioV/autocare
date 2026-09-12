import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';
import 'test_firebase_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    // Validaciones
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa tu nombre');
      return;
    }

    if (_nameController.text.trim().length < 2) {
      setState(() => _errorMessage = 'El nombre debe tener al menos 2 caracteres');
      return;
    }

    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa tu email');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      setState(() => _errorMessage = 'Email inválido');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() =>
          _errorMessage = 'Contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _firebaseService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      Logger.success('Registro exitoso', tag: '[RegisterScreen]');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta creada exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      }
    } catch (e) {
      final errorMsg = e.toString();
      Logger.error('Error registro completo: $errorMsg', tag: '[RegisterScreen]');
      setState(() => _errorMessage = _parseFirebaseError(errorMsg));
      Logger.error('Error parseado: ${_errorMessage}', tag: '[RegisterScreen]');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseFirebaseError(String error) {
    print('DEBUG: Error string = $error');

    if (error.contains('email-already-in-use') || error.contains('EMAIL_EXISTS')) {
      return 'Este email ya está registrado. Intenta con otro.';
    } else if (error.contains('weak-password') || error.contains('WEAK_PASSWORD')) {
      return 'Contraseña muy débil. Usa al menos 6 caracteres.';
    } else if (error.contains('invalid-email') || error.contains('INVALID_EMAIL')) {
      return 'Email inválido. Verifica el formato.';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Error de conexión. Verifica tu internet.';
    } else if (error.contains('FirebaseException')) {
      // Extraer el mensaje específico del error de Firebase
      final match = RegExp(r'\[firebase_auth/([^\]]+)\]').firstMatch(error);
      if (match != null) {
        final code = match.group(1);
        print('DEBUG: Firebase error code = $code');
        return _parseFirebaseCode(code ?? 'unknown');
      }
    }
    return 'Error al crear cuenta: ${error.split('\n').first}';
  }

  String _parseFirebaseCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'weak-password':
        return 'Contraseña muy débil (mínimo 6 caracteres)';
      case 'invalid-email':
        return 'Email inválido';
      case 'operation-not-allowed':
        return 'Registro deshabilitado. Contacta soporte.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'Error: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  size: 60,
                  color: Color(0xFF1A73E8),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Crea tu cuenta AutoCare',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gestiona el mantenimiento de tus vehículos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  hintText: 'Juan Pérez',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'tu@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                enabled: !_isLoading,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  helperText: 'Mínimo 6 caracteres',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                enabled: !_isLoading,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Crear Cuenta'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('¿Ya tienes cuenta? '),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Inicia sesión',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TestFirebaseScreen(),
                        ),
                      );
                    },
                    child: const Text('🔧 Test'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
