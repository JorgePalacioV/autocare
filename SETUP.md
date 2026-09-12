# 🔧 Guía de Instalación y Configuración

## Prerrequisitos

### Software Requerido
- **Flutter** 3.13.0 o superior
- **Dart** 3.1.0 o superior
- **Firebase CLI**
- **Android Studio** (para desarrollo Android) o **Xcode** (para iOS)
- **Git**

### Verificar instalación
```bash
flutter --version
dart --version
firebase --version
```

---

## 1. Clonar el Repositorio

```bash
git clone https://github.com/JorgePalacioV/autocare.git
cd autocare
```

---

## 2. Instalar Dependencias

```bash
flutter pub get
```

---

## 3. Configurar Firebase

### Paso 1: Crear Proyecto Firebase
1. Ir a [Firebase Console](https://console.firebase.google.com)
2. Crear nuevo proyecto "AutoCare"
3. Habilitar Google Analytics (opcional)

### Paso 2: Configurar Autenticación
1. En Firebase Console → Authentication
2. Habilitar "Email/Password"
3. Copiar URL del Emulador Auth (si usas emulador local)

### Paso 3: Configurar Firestore
1. En Firebase Console → Firestore Database
2. Crear base de datos en modo desarrollo
3. Seleccionar región más cercana
4. Copiar reglas de seguridad (ver abajo)

### Paso 4: Configurar Storage
1. En Firebase Console → Storage
2. Crear bucket
3. Copiar reglas de seguridad (ver abajo)

### Paso 5: Descargar Configuración
- **Android**: Descargar `google-services.json` → `android/app/`
- **iOS**: Descargar `GoogleService-Info.plist` → `ios/Runner/`

---

## 4. Reglas de Seguridad Firebase

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      match /{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## 5. Configurar Emuladores Locales

### Instalar Emuladores
```bash
firebase init emulators
```

### Seleccionar:
- Authentication Emulator (puerto 9099)
- Firestore Emulator (puerto 8080)
- Storage Emulator (puerto 9199)

### Iniciar Emuladores
```bash
firebase emulators:start
```

---

## 6. Configurar Variables de Entorno (Opcional)

Crear archivo `.env`:
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id
```

---

## 7. Ejecutar la Aplicación

### En Android
```bash
flutter run -d android
```

### En iOS
```bash
cd ios
pod install
cd ..
flutter run -d ios
```

### En Emulador
```bash
flutter emulators --launch <emulator_name>
flutter run
```

---

## 8. Troubleshooting

### Error: "Could not resolve com.google.firebase"
- Ejecutar: `flutter clean`
- Eliminar carpeta `build/`
- Ejecutar: `flutter pub get`

### Error: "Plugin not found"
```bash
flutter pub get
flutter clean
flutter run
```

### Error: "PlatformException" de Firebase
- Verificar que Firebase está configurado correctamente
- Revisar que `google-services.json` está en el lugar correcto
- Verificar conexión a internet

### Emulador no conecta
- Verificar que emuladores están ejecutándose
- Revisar logs: `firebase emulators:start --verbose`
- Revisar URL en `lib/services/firebase_service.dart`

---

## 9. Build para Producción

### Android
```bash
flutter build apk
# o para Play Store
flutter build appbundle
```

### iOS
```bash
flutter build ios
# Abrir en Xcode para subir a App Store
```

---

## 10. Configuración Adicional

### Cambiar Theme
Editar `lib/main.dart`:
```dart
theme: ThemeData(
  primarySwatch: Colors.blue,
  useMaterial3: true,
)
```

### Habilitar/Deshabilitar Features
Ver `lib/screens/` para importar/remover screens del navegador.

---

## ✅ Verificación Final

1. ✅ Flutter instalado
2. ✅ Dependencias instaladas
3. ✅ Firebase configurado
4. ✅ Emuladores ejecutándose
5. ✅ App ejecutándose sin errores
6. ✅ Puedes registrarte y crear vehículos

¡Listo para empezar! 🚀
