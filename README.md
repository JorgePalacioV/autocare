# AutoCare 🚗

**Gestión Inteligente de Mantenimiento Vehicular**

Aplicación Flutter para rastrear y gestionar el mantenimiento de vehículos, registrar costos, generar recordatorios automáticos y visualizar estadísticas de mantenimiento.

**Estado:** ✅ Totalmente funcional con Firebase Local Emulator Suite (desarrollo offline)

---

## 🚀 Setup Rápido - Firebase Emulators (Recomendado para desarrollo)

Esta configuración permite trabajar **sin conexión a internet** usando Firebase Local Emulator Suite.

### Requisitos previos

- **Flutter** 3.0+ instalado
- **Java** 11+ instalado  
- **Firebase CLI** instalado globalmente:
  ```bash
  npm install -g firebase-tools
  ```
- **Android SDK** (para Android Emulator)

### 1️⃣ Instalar dependencias

```bash
cd /Users/jorgepalacio/Documentos/autocare
flutter pub get
```

### 2️⃣ Iniciar Firebase Emulators (Terminal 1)

```bash
firebase emulators:start --only auth,firestore
```

**Salida esperada:**
```
✓  Auth emulator started at http://127.0.0.1:9099
✓  Firestore emulator started at http://127.0.0.1:8080
✓  Emulator UI available at http://localhost:4000
```

### 3️⃣ Iniciar Android Emulator (Terminal 2)

```bash
emulator -avd Pixel_4_API_31
```

O desde Android Studio: Tools → Device Manager → Play

### 4️⃣ Ejecutar la app (Terminal 3)

```bash
flutter run
```

**Listo! ✅** La app se conectará automáticamente a los emuladores de Firebase.

---

## 📱 Prueba la app

### Crear una cuenta de prueba:
- **Email:** `test@demo.com`
- **Contraseña:** `123456`
- **Nombre:** `juan`

Después del registro verás la **HomeScreen** con:
- Bienvenida personalizada
- Resumen de vehículos y mantenimientos
- Botones de acciones rápidas

### Ver datos en Firebase Emulator UI

Abre en tu navegador: **http://localhost:4000**

Verás:
- **Authentication**: Usuarios creados
- **Firestore Database**: Colecciones `users`, `vehicles`, `maintenances`
- **Logs**: Actividad en tiempo real

---

## ⚙️ Configuración Técnica

### Archivos clave modificados para emuladores

#### `firebase.json` - Puertos de emuladores
```json
{
  "emulators": {
    "auth": { "port": 9099 },
    "firestore": { "port": 8080 },
    "singleProjectMode": true
  }
}
```

#### `android/app/src/debug/AndroidManifest.xml` - Permisos
```xml
<application android:networkSecurityConfig="@xml/network_security_config" />
```

**Por qué:** Permite tráfico HTTP sin encriptar en modo debug (necesario para conectar a localhost)

#### `android/app/src/debug/res/xml/network_security_config.xml` - Seguridad
```xml
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">127.0.0.1</domain>
    </domain-config>
</network-security-config>
```

**Nota:** Solo en carpeta `debug/`, no afecta builds de release.

#### `lib/services/firebase_service.dart` - Conexión
```dart
Future<void> connectToEmulators() async {
  await _auth.useAuthEmulator('localhost', 9099);
  _firestore.useFirestoreEmulator('localhost', 8080);
}
```

---

## 🐛 Solución de problemas

### ❌ Error: "Cleartext HTTP traffic to 10.0.2.2 not permitted"
**Solución:** Ejecuta `flutter clean && flutter run` (no solo hot restart)

### ❌ Error: "Failed to connect to Firebase Emulator"
**Solución:** Verifica que Firebase emulators esté corriendo:
```bash
firebase emulators:start --only auth,firestore
```

### ❌ App no se conecta a emuladores
**Solución:** Revisa los logs:
```bash
adb logcat | grep -i firebase
```

Deberías ver:
```
Auth Emulator conectado (localhost:9099)
Firestore Emulator conectado (localhost:8080)
```

---

## 📊 Características Implementadas

### ✅ Fase 1 - Configuración
- ✅ Firebase Local Emulator Suite configurado
- ✅ Network Security Config para HTTP en debug
- ✅ Logging profesional
- ✅ Manejo de errores

### ✅ Fase 2 - Autenticación
- ✅ Pantalla de registro (RegisterScreen)
- ✅ Pantalla de login (LoginScreen)
- ✅ Autenticación con Firebase Auth Emulator
- ✅ Persistencia de usuarios en Firestore Emulator

### ✅ Fase 3 - UI Principal
- ✅ HomeScreen con bienvenida personalizada
- ✅ Resumen de vehículos y mantenimientos
- ✅ Acciones rápidas
- ✅ Información de perfil

### 🔄 Próximas fases
- Gestión de vehículos (agregar, editar, eliminar)
- Registro de mantenimientos
- Seguimiento de costos
- Estadísticas y gráficos
- Recordatorios automáticos

---

## 📁 Estructura del proyecto

```
autocare/
├── lib/
│   ├── main.dart
│   ├── services/
│   │   ├── firebase_service.dart       ← Conexión a emuladores
│   │   └── logger.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   └── home_screen.dart
│   └── models/
│       └── models.dart
├── android/
│   └── app/
│       └── src/
│           └── debug/
│               ├── AndroidManifest.xml
│               └── res/xml/network_security_config.xml
├── firebase.json                       ← Config emuladores
├── pubspec.yaml
└── README.md
```

---

## 🔄 Comandos útiles

```bash
# Limpiar y reconstruir
flutter clean && flutter run

# Ver logs en tiempo real
adb logcat | grep flutter

# Captura de pantalla del emulador
adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png ~/Desktop/

# Resetear datos de emuladores Firebase
rm -rf ~/.cache/firebase/emulators
firebase emulators:start --only auth,firestore

# Verificar versión de Flutter
flutter --version
```

---

## 🌐 Conectar a Firebase Cloud (producción)

Para usar Firebase Cloud en lugar de emuladores:

1. Comentar en `lib/main.dart`:
```dart
// await FirebaseService().connectToEmulators();
```

2. Configurar Firebase Console y copiar `google-services.json`

3. Ejecutar:
```bash
flutter run --release
```

---

## 📞 Contacto

**Desarrollador:** Jorge Palacio  
**Email:** jpalaciovillamizar@gmail.com  
**Versión:** 1.0.0  
**Última actualización:** 11 de septiembre de 2026  
**Estado:** ✅ En desarrollo activo
