# 🔒 Logging Seguro

## Problema

El archivo `logger.dart` está loguando información que NUNCA debería exponerse en producción:

```dart
// ❌ MAL - Expone datos sensibles
Logger.log('Registrando usuario: $email');
Logger.log('Contraseña: $password');
Logger.log('Token: $authToken');
```

---

## ✅ Solución: Redacting Logs

### Principios

1. **NUNCA logguear**:
   - Contraseñas
   - Tokens de autenticación
   - Emails (en mensajes directos)
   - Datos personales (teléfono, documento)
   - Información de tarjetas de crédito

2. **SÍ es seguro logguear**:
   - IDs anónimos (user-123abc...)
   - Estados de operaciones
   - Timestamps
   - Niveles de error

3. **Usar redacting en producción**:
   - Reemplazar datos sensibles con `[REDACTED]`
   - Solo en dev logs mostrar detalles

---

## Implementar Logging Seguro

### Opción 1: Redacting Manual (Simple)

```dart
// lib/services/logger.dart

class Logger {
  static bool isProduction = const bool.fromEnvironment('dart.vm.product');

  static String _redact(String value, String name) {
    if (isProduction) {
      return '[REDACTED $name]';
    }
    return value;
  }

  // ✅ CORRECTO
  static void logLogin(String email) {
    final redactedEmail = _redact(email, 'email');
    Logger.log('Login attempt: $redactedEmail');
  }

  static void logError(String error, String? password) {
    final redactedPassword = password != null ? _redact(password, 'password') : null;
    Logger.error('Auth error: $error, pwd: $redactedPassword');
  }
}
```

---

## Audit de Logging Actual

Revisar `logger.dart` y `firebase_service.dart` para:

```bash
# Buscar logs peligrosos
grep -r "email\|password\|token\|uid\|auth" lib/services/logger.dart lib/services/firebase_service.dart
```

### Cambios necesarios:

| Ubicación | Cambio | Razón |
|---|---|---|
| `logger.dart` | Agregar `_redact()` | Redacting automático |
| `firebase_service.dart` | No logguear email en `signUp()` | Evitar exposición |
| `firebase_service.dart` | No logguear contraseña | NUNCA |
| `firebase_service.dart` | No logguear tokens | NUNCA |

---

## Ejemplo de Logs Seguros

### ❌ ANTES (Inseguro)

```
I/flutter: Registrando usuario: juan@example.com
I/flutter: Contraseña ingresada: MyPassword123!
I/flutter: Auth token: eyJhbGciOiJIUzI1NiIs...
```

### ✅ DESPUÉS (Seguro)

```
I/flutter: Registrando usuario: [REDACTED email]
I/flutter: Contraseña ingresada: [REDACTED password]
I/flutter: Auth token: [REDACTED token]
```

---

## Firebase Console Logs

**IMPORTANTE:** Los logs en Firebase Console (Analytics, Crash Reports) pueden contener datos sensibles:

1. **Configura Data Retention**: Firestore → Settings → Data Retention
   - Producción: 30 días máximo
   - Elimina logs automáticamente

2. **No loguear en Analytics**:
   ```dart
   // ❌ Evita esto
   analytics.logEvent(name: 'login_email', parameters: {'email': user.email});
   
   // ✅ Usa esto
   analytics.logEvent(name: 'login_success');
   ```

3. **Crash Reports**: Cloudflare/Sentry también pueden contener datos sensibles
   - Configurar filtros de redacting
   - No incluir stack traces con email/contraseña

---

## Checklist de Auditoría

Ejecutar antes de producción:

```bash
# Buscar logs peligrosos
grep -r "password\|token\|email.*log\|creditCard" lib/

# Buscar en Firebase calls
grep -r "logEvent.*email\|logEvent.*password" lib/
```

**Ninguno debería encontrar resultados.**

---

## Implementación Inmediata

1. **Agregar método `_redact()` a logger.dart**
2. **Reemplazar logs en firebase_service.dart**
3. **Revisar analytics events**
4. **Configurar data retention en Firestore**

---

**Status**: ⚠️ **REQUIERE AUDITORÍA** - Revisar todos los logs antes de producción
