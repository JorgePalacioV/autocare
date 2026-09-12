import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    try {
      // Solicitar permisos
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      Logger.info(
        'Notificación permiso: ${settings.authorizationStatus}',
        tag: '[NotificationService]',
      );

      // Obtener token FCM
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        Logger.info('FCM Token obtenido exitosamente', tag: '[NotificationService]');
      }

      // Inicializar notificaciones locales
      await _initLocalNotifications();

      // Handlers de mensajes
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Background message handler
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      Logger.success('Notificaciones inicializadas', tag: '[NotificationService]');
    } catch (e) {
      Logger.error('Error inicializando notificaciones: $e', tag: '[NotificationService]');
    }
  }

  Future<void> _initLocalNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTapped,
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    Logger.info(
      'Notificación en foreground: ${message.notification?.title}',
      tag: '[NotificationService]',
    );

    await _showLocalNotification(
      message.notification?.title ?? 'AutoCare',
      message.notification?.body ?? '',
      message.data,
    );
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    Logger.info(
      'Notificación abierta: ${message.notification?.title}',
      tag: '[NotificationService]',
    );
    // Navegar a la pantalla correspondiente si es necesario
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    Logger.info(
      'Notificación en background: ${message.notification?.title}',
      tag: '[NotificationService]',
    );
  }

  void _handleNotificationTapped(NotificationResponse response) {
    Logger.info(
      'Notificación tocada: ${response.payload}',
      tag: '[NotificationService]',
    );
    // Manejar cuando el usuario toca la notificación
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> payload,
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'autocare_channel',
      'AutoCare Notifications',
      channelDescription: 'Notificaciones de AutoCare',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload.toString(),
    );
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    Logger.info('Suscrito al tópico: $topic', tag: '[NotificationService]');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    Logger.info('Desuscrito del tópico: $topic', tag: '[NotificationService]');
  }
}
