import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../screens/home_screen.dart';
import '../../providers/theme_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'test_firebase_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _firebaseService = FirebaseService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Por favor completa todos los campos');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      setState(() => _errorMessage = 'Email inválido');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _firebaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      Logger.success('Login exitoso', tag: '[LoginScreen]');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      Logger.error('Error login: $e', tag: '[LoginScreen]');
      setState(() => _errorMessage = _parseFirebaseError(e.toString()));
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

  Future<void> _handleGoogleSignIn() async {
    try {
      print('DEBUG: Iniciando Google Sign-In...');
      await _firebaseService.signInWithGoogle();
      print('DEBUG: Google Sign-In completado');
      Logger.success('Google Sign-In exitoso', tag: '[LoginScreen]');

      print('DEBUG: mounted=$mounted, context=${context.toString()}');

      if (mounted) {
        print('DEBUG: Intentando navegar a HomeScreen...');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              print('DEBUG: Construyendo HomeScreen...');
              return const HomeScreen();
            },
          ),
        );
        print('DEBUG: Navegación completada');
      } else {
        print('DEBUG: Widget no está mounted');
      }
    } catch (e) {
      print('DEBUG: Error en Google Sign-In: $e');
      Logger.error('Error Google Sign-In: $e', tag: '[LoginScreen]');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _parseFirebaseError(String error) {
    print('DEBUG: Login error = $error');

    if (error.contains('user-not-found') || error.contains('USER_NOT_FOUND')) {
      return 'Usuario no encontrado. ¿Quieres crear una cuenta?';
    } else if (error.contains('wrong-password') || error.contains('INVALID_PASSWORD')) {
      return 'Contraseña incorrecta';
    } else if (error.contains('too-many-requests')) {
      return 'Demasiados intentos. Intenta más tarde.';
    } else if (error.contains('invalid-email') || error.contains('INVALID_EMAIL')) {
      return 'Email inválido';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Error de conexión. Verifica tu internet.';
    } else if (error.contains('FirebaseException')) {
      final match = RegExp(r'\[firebase_auth/([^\]]+)\]').firstMatch(error);
      if (match != null) {
        final code = match.group(1);
        print('DEBUG: Firebase error code = $code');
        return _parseFirebaseCode(code ?? 'unknown');
      }
    }
    return 'Error: ${error.split('\n').first}';
  }

  String _parseFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
      case 'invalid-password':
        return 'Contraseña incorrecta';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      default:
        return 'Error de autenticación: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                  Icons.lock_outline,
                  size: 60,
                  color: Color(0xFF1A73E8),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Bienvenido de vuelta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inicia sesión con tu cuenta AutoCare',
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                    child: const Text('¿Olvidaste la contraseña?'),
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
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
                      : const Text('Iniciar Sesión'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'O continúa con',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 16),
              GoogleSignInButton(
                onPressed: _handleGoogleSignIn,
                label: 'Continuar con Google',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? '),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegisterScreen(),
                              ),
                            );
                          },
                    child: const Text(
                      'Registrate',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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
