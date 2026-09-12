# 🔔 Push Notifications

AutoCare soporta **Push Notifications** a través de Firebase Cloud Messaging (FCM).

## Características

✅ Notificaciones remotas vía Firebase
✅ Notificaciones locales en el dispositivo
✅ Permisos automáticos en iOS/Android
✅ Tópicos de suscripción personalizados
✅ Manejo de mensajes en foreground/background
✅ Alertas de mantenimiento

## Configuración

### Firebase Cloud Messaging Setup

1. **En Firebase Console:**
   - Ir a Cloud Messaging en el proyecto
   - Copiar Server Key (para enviar notificaciones)
   - Activar Cloud Messaging API

2. **En el Proyecto:**
   - Las configuraciones de FCM ya están en `android/app/build.gradle`
   - Las configuraciones de iOS están en `ios/Podfile`

### Permisos Requeridos

**Android (AndroidManifest.xml):**
```xml
<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

**iOS (Info.plist):**
```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

## Uso

### Inicialización

Las notificaciones se inicializan automáticamente en `main.dart`:

```dart
void main() async {
  // ...
  await NotificationService().init();
  // ...
}
```

### Suscribirse a Alertas

```dart
// Suscribirse a alertas de mantenimiento para un vehículo
await firebaseService.subscribeToMaintenanceAlerts('vehicle_id_123');

// Suscribirse a alertas del usuario
await firebaseService.subscribeToUserAlerts('user_id_456');
```

### Desuscribirse

```dart
await firebaseService.unsubscribeFromMaintenanceAlerts('vehicle_id_123');
```

### Obtener FCM Token

```dart
final token = await NotificationService().getFCMToken();
print('FCM Token: $token');
```

## Tipos de Notificaciones

### 1. Alertas de Mantenimiento

Se envían cuando:
- Próximo mantenimiento vence
- Mantenimiento está en riesgo
- Licencia del conductor vence

**Tema:** `maintenance_alerts_{vehicleId}`

### 2. Notificaciones del Usuario

Recordatorios generales y actualizaciones.

**Tema:** `user_alerts_{userId}`

### 3. Notificaciones de Sistema

Actualizaciones y mantenimiento de la app.

**Tema:** `system_notifications`

## Envío de Notificaciones

### Desde Firebase Console

1. Cloud Messaging → Send first message
2. Título y cuerpo del mensaje
3. Seleccionar dispositivos o tópicos
4. Enviar

### Desde Backend (cURL)

```bash
curl -X POST \
  https://fcm.googleapis.com/v1/projects/autocare-xxx/messages:send \
  -H 'Authorization: Bearer $(gcloud auth print-access-token)' \
  -H 'Content-Type: application/json' \
  -d '{
    "message": {
      "topic": "maintenance_alerts_vehicle_123",
      "notification": {
        "title": "Mantenimiento Próximo",
        "body": "El cambio de aceite vence en 500km"
      },
      "data": {
        "vehicleId": "vehicle_123",
        "maintenanceType": "oil"
      }
    }
  }'
```

## Estructura de Archivos

```
lib/services/
└── notification_service.dart    # Gestión de notificaciones

lib/main.dart                    # Inicialización
```

## Manejo de Notificaciones

### Foreground (App Abierta)

```dart
// Escuchador automático
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Se muestra notificación local automáticamente
  print('Notificación recibida: ${message.notification?.title}');
});
```

### Background (App Cerrada)

```dart
// Handler automático
static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Mensaje en background: ${message.notification?.title}');
}
```

### Cuando se Toca la Notificación

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Navegar a pantalla correspondiente
  print('Usuario tocó notificación: ${message.data}');
});
```

## Permisos en iOS

El usuario verá un diálogo pidiendo permiso:
- "Allow notifications?"
- "Allow sound?"
- "Allow badge?"

Todos son necesarios para funcionalidad completa.

## Permisos en Android

Android 12+: Se solicita automáticamente
Android 11 y anteriores: Se asume permitido

## Testing

### Emuladores

1. **Android Emulator:**
   - Requiere Google Play Services
   - FCM funciona completamente

2. **iOS Simulator:**
   - Notificaciones locales: ✅ Funciona
   - FCM remoto: ❌ No funciona en simulator
   - Probar en dispositivo real

### Prueba Local

```dart
// Mostrar notificación local de prueba
await NotificationService()._showLocalNotification(
  'Prueba',
  'Esto es una notificación de prueba',
  {},
);
```

## Troubleshooting

| Problema | Solución |
|----------|----------|
| No recibe notificaciones | Verificar permisos en Settings |
| Token no se obtiene | Verificar Firebase setup en console |
| Notificaciones van a spam | Verificar canal de notificación en Android |
| No funciona en simulator iOS | Necesario dispositivo real |

## Seguridad

✅ Tokens encriptados
✅ Validación de permisos
✅ Tópicos por usuario/vehículo
✅ Payloads validados

## Próximas Mejoras

- [ ] Notificaciones inteligentes por hora del día
- [ ] Preferencias de notificación por usuario
- [ ] Estadísticas de apertura de notificaciones
- [ ] Notificaciones con acciones (snooze, etc.)
- [ ] Deep linking a pantallas específicas

EOF
