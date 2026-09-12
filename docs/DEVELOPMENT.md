# Guía de Desarrollo - AutoCare

## 🚀 Primeros Pasos

### Ejecutar la app
```bash
cd /Users/jorgepalacio/Documentos/autocare
flutter pub get
flutter run -d emulator-5554
```

### Verificar que Firebase funciona
```dart
final firebase = FirebaseService();
bool connected = await firebase.verifyConnection();
print('Firebase: $connected');
```

---

## 📋 Checklist para Fase 2 (Autenticación)

### Pantalla de Login
- [ ] Crear `lib/screens/auth/login_screen.dart`
- [ ] Campos: email, password
- [ ] Botón "Iniciar Sesión"
- [ ] Botón "¿Olvidó contraseña?"
- [ ] Validar campos antes de enviar
- [ ] Mostrar errores con `SnackBar`
- [ ] Loading spinner durante request
- [ ] Navegar a Home si login exitoso

### Pantalla de Registro
- [ ] Crear `lib/screens/auth/register_screen.dart`
- [ ] Campos: email, password, confirmPassword, name
- [ ] Validar contraseña (min 6 caracteres)
- [ ] Validar que contraseñas coinciden
- [ ] Llamar `firebase.signUp()`
- [ ] Mostrar errores específicos (email en uso, etc)
- [ ] Auto-login después de registro exitoso

### Pantalla de Recuperación
- [ ] Crear `lib/screens/auth/forgot_password_screen.dart`
- [ ] Campo: email
- [ ] Botón "Enviar email de recuperación"
- [ ] Confirmar que email se envió

### Home Screen (con Auth)
- [ ] Detectar si usuario está autenticado
- [ ] Mostrar email/nombre del usuario
- [ ] Botón "Cerrar sesión"
- [ ] Navegar según auth state

---

## 🏗️ Estructura para nueva pantalla

### Paso 1: Crear archivo
```bash
touch lib/screens/nombre/nombre_screen.dart
```

### Paso 2: Template base
```dart
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';

class NombreScreen extends StatefulWidget {
  const NombreScreen({Key? key}) : super(key: key);

  @override
  State<NombreScreen> createState() => _NombreScreenState();
}

class _NombreScreenState extends State<NombreScreen> {
  final _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Título')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Contenido aquí
              ],
            ),
    );
  }

  Future<void> _handleAction() async {
    setState(() => _isLoading = true);
    try {
      // Acción aquí
      Logger.success('Acción exitosa', tag: '[NombreScreen]');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Éxito')),
        );
      }
    } catch (e) {
      Logger.error('Error: $e', tag: '[NombreScreen]');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

### Paso 3: Agregar navegación en `main.dart`

```dart
// En MyApp, cambiar home según auth state
home: firebase.isAuthenticated 
  ? const HomeScreen() 
  : const LoginScreen(),
```

---

## 🎨 Componentes reutilizables

### Campo de texto
```dart
TextField(
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'correo@ejemplo.com',
    prefixIcon: const Icon(Icons.email),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

### Botón principal
```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: _isLoading ? null : _handleSubmit,
    child: _isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Text('Enviar'),
  ),
)
```

### Validador de email
```dart
bool _isValidEmail(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
}
```

### SnackBar de error
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(error),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 3),
  ),
);
```

---

## 🔍 Testing

### Test unitario (modelo)
```dart
test('Vehicle valida año correctamente', () {
  expect(
    () => Vehicle(..., year: 1800, ...),
    throwsArgumentError,
  );
});
```

### Test de integración (Firebase)
```dart
testWidgets('Login flow works', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Verificar que se muestra login
  expect(find.text('Iniciar Sesión'), findsOneWidget);
  
  // Ingresar datos
  await tester.enterText(
    find.byType(TextField).at(0), 
    'test@example.com',
  );
  
  // Hacer tap
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  
  // Verificar resultado
  expect(find.byType(HomeScreen), findsOneWidget);
});
```

---

## 🐛 Debugging

### Ver logs
```dart
// En main() antes de runApp()
Logger.setDebugMode(true);
```

### Firebase Console
1. Ir a: https://console.firebase.google.com
2. Seleccionar proyecto "autocare-2f41c"
3. Firestore Database → Revisar documentos
4. Authentication → Ver usuarios
5. Realtime Database (si aplica)

### Emulador
```bash
# Ver logs en tiempo real
flutter logs

# Reiniciar emulador
emulator -avd Pixel_7_API_34
```

---

## 📦 Agregar dependencia nueva

```bash
flutter pub add package_name
```

### Dependencias recomendadas para Fase 2+
```yaml
# Formularios
form_builder_validators: ^10.0.0

# Estado
provider: ^6.0.0
# o
riverpod: ^2.0.0

# Caché local
hive: ^2.0.0
hive_flutter: ^1.1.0

# Imágenes
cached_network_image: ^3.2.0

# Mapas (Fase 3)
google_maps_flutter: ^2.1.0

# Notificaciones
firebase_messaging: ^14.0.0
```

---

## 🔒 Seguridad

### Antes de producción
- [ ] Cambiar credenciales de Firebase (restringir API keys)
- [ ] Activar 2FA en Firebase Console
- [ ] Revisar Firestore Security Rules
- [ ] Habilitar reCAPTCHA en Auth
- [ ] Usar versiones específicas de dependencias
- [ ] Remover logs de debug

### Credenciales actuales (PÚBLICAS)
```
API Key: AIzaSyBlhtfuR1UHMstJhhoVrRSjIg7lE8Q9pUI
Project ID: autocare-2f41c
```
⚠️ Cambiar en producción

---

## 📈 Performance

### Optimizaciones implementadas
- ✅ Singleton FirebaseService (una sola instancia)
- ✅ Streams para datos en tiempo real
- ✅ Índices Firestore para queries comunes
- ✅ Paginación (limit en queries)

### Mejoras futuras
- Caché local con Hive
- Compresión de imágenes
- Lazy loading en listas
- Reducir tamaño APK

---

## 🎯 Próximos pasos

### Inmediato (Fase 2)
1. Crear `login_screen.dart`
2. Crear `register_screen.dart`
3. Implementar navegación
4. Probar flujo completo

### Mediano plazo (Fase 3-4)
1. Screens para vehículos
2. Screens para mantenimientos
3. Estadísticas
4. Fotos

### Largo plazo (Fase 5+)
1. Reportes PDF
2. Sincronización offline
3. Compartir vehículos
4. Versión web

---

## 📚 Recursos útiles

- [Flutter docs](https://docs.flutter.dev)
- [Firebase docs](https://firebase.google.com/docs)
- [Dart docs](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io)

---

**Última actualización:** 2026-09-10
