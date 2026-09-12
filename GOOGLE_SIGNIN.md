# 🔐 Google Sign-In

AutoCare soporta **Sign-In con Google** para autenticación rápida y segura.

## Características

✅ Autenticación con Google
✅ Creación automática de cuenta
✅ Integración con Firebase
✅ Persistencia de datos
✅ Interfaz limpia y moderna

## Configuración

### 1. Firebase Console Setup

1. Ir a **Authentication** → **Sign-in method**
2. Habilitar **Google** provider
3. Configurar SHA-1 del proyecto

### 2. Android Setup

#### a) Obtener SHA-1

```bash
./gradlew signingReport
```

#### b) Configurar en Firebase Console

- Copiar SHA-1 de debug
- Agregar en **Project Settings** → **Your apps**

#### c) AndroidManifest.xml (Automático con google_sign_in)

### 3. iOS Setup

#### a) Configurar en Firebase Console

- Descargar `GoogleService-Info.plist`
- Agregar a Xcode

#### b) Info.plist

```xml
<key>GIDClientID</key>
<string>YOUR_CLIENT_ID.apps.googleusercontent.com</string>

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

## Uso

### Sign-In con Google

```dart
// En LoginScreen
GoogleSignInButton(
  onPressed: () async {
    await firebaseService.signInWithGoogle();
    // Navegar a home
  },
  label: 'Continuar con Google',
)
```

### Obtener Información del Usuario

```dart
final user = FirebaseAuth.instance.currentUser;
print('Email: ${user?.email}');
print('Nombre: ${user?.displayName}');
print('Foto: ${user?.photoURL}');
```

### Sign-Out

```dart
// Cierra sesión de Google y Firebase
await firebaseService.googleSignOut();
```

## Flujo de Autenticación

```
┌─────────────────────────────────────┐
│  Usuario toca "Continuar con Google"│
└──────────────┬──────────────────────┘
               │
        ┌──────▼────────┐
        │ Google Login  │
        │  Dialog       │
        └──────┬────────┘
               │ (Usuario ingresa credenciales)
               │
        ┌──────▼─────────────────┐
        │ Google autentica       │
        │ Retorna tokens         │
        └──────┬─────────────────┘
               │
        ┌──────▼─────────────────────┐
        │ Firebase Sign-In           │
        │ con Google credential      │
        └──────┬─────────────────────┘
               │
        ┌──────▼────────────────────┐
        │ Crear usuario en          │
        │ Firestore si no existe    │
        └──────┬─────────────────────┘
               │
        ┌──────▼──────────┐
        │ Navegar a Home  │
        └─────────────────┘
```

## Datos del Usuario

Cuando un usuario se autentica con Google, AutoCare crea automáticamente un usuario en Firestore:

```json
{
  "id": "firebase_uid",
  "email": "user@gmail.com",
  "name": "John Doe",
  "createdAt": "2024-03-15T10:30:00Z"
}
```

## Seguridad

✅ **Tokens encriptados** - Google maneja la seguridad
✅ **Credenciales no almacenadas** - Solo tokens de acceso
✅ **HTTPS obligatorio** - Todas las comunicaciones
✅ **Validación servidor** - Firebase valida tokens
✅ **Permisos mínimos** - Solo email y perfil público

## Permisos Solicitados

Google solicita acceso a:
- 📧 Email principal
- 👤 Nombre y foto de perfil
- 🆔 ID de cuenta

Estos son **mínimos necesarios** para crear la cuenta.

## Troubleshooting

| Problema | Solución |
|----------|----------|
| "Invalid client" | Verificar SHA-1 en Firebase Console |
| No muestra Google Sign-In | Verificar google_sign_in config |
| Error en iOS | Revisar GoogleService-Info.plist |
| "PlatformException" | Verificar internet y Firebase setup |

## Testing

### En Emulador Android

✅ Funciona completamente
- Usar Google Play Services
- Seleccionar cuenta Google en emulador

### En Simulator iOS

❌ Google Sign-In no funciona
- Necesario probar en dispositivo real
- Las notificaciones locales sí funcionan

### Con Firebase Emulator

⚠️ Google Sign-In requiere modo producción
- No funciona con emuladores
- Usar cuenta real para testing

## Próximas Mejoras

- [ ] Sign-In con Apple
- [ ] Sign-In con Facebook
- [ ] Linking múltiples proveedores
- [ ] Visualización de permisos

EOF
