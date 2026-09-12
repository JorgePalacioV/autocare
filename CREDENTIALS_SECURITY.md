# 🔐 Seguridad de Credenciales

## Problema Actual

Las credenciales de Firebase están hardcodeadas en `firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyBlhtfuR1UHMstJhhoVrRSjIg7lE8Q9pUI', // ⚠️ EXPUESTO
  appId: '1:507830436078:android:4604dad4cb0d016fb333ff',
  messagingSenderId: '507830436078',
  projectId: 'autocare-2f41c',
  storageBucket: 'autocare-2f41c.firebasestorage.app',
);
```

Aunque las credenciales de **Android son públicas por diseño** (están en `AndroidManifest.xml`), es una buena práctica:
1. No commitearlas en el repositorio
2. Regenerarlas periodicamente
3. Usar variables de entorno o archivos ignorados

---

## Solución: Regenerar API Key

### Paso 1: Ir a Firebase Console

1. Abre [Firebase Console](https://console.firebase.google.com)
2. Selecciona proyecto: **autocare-2f41c**
3. Haz click en **⚙️ Settings** (esquina superior derecha)
4. Ve a la pestaña **Service Accounts**

### Paso 2: Regenerar Android API Key

1. En Firebase Console, ve a **Settings** → **APIs and Services** o **API Restrictions**
2. Busca la API Key para Android
3. Haz click en **Regenerate Key**
4. Copia la nueva key

### Paso 3: Actualizar el código

Reemplaza la antigua key en `firebase_options.dart`:

```dart
apiKey: 'NEW_API_KEY_HERE', // Nueva key generada
```

### Paso 4: Agregar a .gitignore

Agrega `firebase_options.dart` a `.gitignore` para que no se commiteé:

```bash
echo "lib/firebase_options.dart" >> .gitignore
```

---

## Solución Alternativa: Variables de Entorno

Para máxima seguridad, usa variables de entorno:

### 1. Crear archivo `.env` (NO committear)

```bash
FIREBASE_API_KEY=AIzaSyBlhtfuR1UHMstJhhoVrRSjIg7lE8Q9pUI
FIREBASE_APP_ID=1:507830436078:android:4604dad4cb0d016fb333ff
FIREBASE_PROJECT_ID=autocare-2f41c
```

### 2. Agregar a `.gitignore`

```bash
.env
firebase_options.dart
```

### 3. Instalar dotenv

```bash
flutter pub add flutter_dotenv
```

### 4. Usar en código

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY']!,
    appId: dotenv.env['FIREBASE_APP_ID']!,
    projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    // ...
  );
}
```

### 5. En main.dart

```dart
void main() async {
  await dotenv.load(fileName: ".env");
  // ... resto del código
}
```

---

## Checklist

- [ ] Regenerar API Key en Firebase Console
- [ ] Actualizar `firebase_options.dart` con nueva key
- [ ] Agregar `firebase_options.dart` a `.gitignore`
- [ ] Committear `.gitignore`
- [ ] (Opcional) Implementar solución con dotenv

---

## ⚠️ IMPORTANTE

**Para Android**, la API Key es inherentemente "pública" porque:
1. Se compila en el APK
2. Cualquiera puede descompilar y encontrarla
2. Firebase protege el acceso mediante Security Rules (que ya implementamos)

**Para iOS**, hacer lo mismo por consistencia.

**Para el backend** (si lo hay), NUNCA expongas:
- Service Account Key
- Admin SDK credentials
- JWT tokens

---

**Status**: Las credenciales actuales funcionan pero deberían regenerarse antes de producción.
