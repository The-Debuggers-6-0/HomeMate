import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Servizio singleton per le notifiche locali.
/// Gestisce sia le notifiche immediate (nuova spesa, nuovo task, ecc.)
/// che le notifiche programmate (reminder scadenze).
class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inizializza il plugin, crea il canale Android e richiede i permessi.
  Future<void> initialize() async {
    if (_initialized) return;

    // Inizializza timezone per le notifiche programmate
    tz_data.initializeTimeZones();

    // Configurazione Android: usa l'icona dell'app
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Crea il canale di notifica per Android 8+
    const channel = AndroidNotificationChannel(
      'homemate_default', // id
      'HomeMate', // nome visibile nelle impostazioni
      description: 'Notifiche di HomeMate',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Richiedi permesso notifiche (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('[NotificationService] Inizializzato con successo');
  }

  /// Callback quando l'utente tocca una notifica.
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[NotificationService] Notifica toccata: ${response.payload}');
    // Per ora non navighiamo, ma il payload è disponibile per uso futuro
  }

  /// Mostra una notifica locale immediata.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'homemate_default',
      'HomeMate',
      channelDescription: 'Notifiche di HomeMate',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Programma una notifica futura (per reminder).
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) return;

    // Non programmare notifiche nel passato
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'homemate_default',
      'HomeMate',
      channelDescription: 'Notifiche di HomeMate',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );

    debugPrint('[NotificationService] Programmata notifica #$id per $scheduledDate');
  }

  /// Cancella una notifica programmata.
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancella tutte le notifiche.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Genera un ID numerico stabile da una stringa (es. document ID di Firestore).
  /// Usa hashCode, che è deterministico per la stessa stringa nella stessa sessione.
  static int generateId(String documentId) => documentId.hashCode.abs() % 100000;
}
