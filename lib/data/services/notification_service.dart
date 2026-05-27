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
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
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

  // --- Metodi di utilità per le feature specifiche ---

  /// Notifica per un pagamento che riguarda l'utente (o un rimborso).
  Future<void> showPaymentNotification({
    required int id,
    required String userOrCreatorName,
    required double amount,
    required String description,
    bool isReimbursement = false,
  }) async {
    final title = isReimbursement 
        ? 'Nuovo rimborso da $userOrCreatorName' 
        : 'Nuova spesa aggiunta';
    
    final body = isReimbursement 
        ? '$userOrCreatorName ti ha rimborsato ${amount.toStringAsFixed(2)}€ per "$description"'
        : '$userOrCreatorName ha aggiunto una spesa di ${amount.toStringAsFixed(2)}€ per "$description" che ti riguarda.';
        
    await show(id: id, title: title, body: body, payload: 'payment_$id');
  }

  /// Notifica per un evento aggiunto nel calendario.
  Future<void> showEventNotification({
    required int id,
    required String creatorName,
    required String eventName,
    required DateTime eventDate,
  }) async {
    final title = 'Nuovo evento a calendario';
    final dateStr = '${eventDate.day.toString().padLeft(2, '0')}/${eventDate.month.toString().padLeft(2, '0')}';
    final timeStr = '${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';
    
    final body = '$creatorName ha aggiunto "$eventName" per il $dateStr alle $timeStr.';
    
    await show(id: id, title: title, body: body, payload: 'event_$id');
  }

  /// Notifica per quando tocca pulire o buttare l'immondizia.
  Future<void> showChoreNotification({
    required int id,
    required String choreName,
    required DateTime dueDate,
  }) async {
    final title = 'È il tuo turno!';
    final dateStr = '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}';
    
    final body = 'Tocca a te: "$choreName" entro il $dateStr. Non dimenticare!';
    
    await show(id: id, title: title, body: body, payload: 'chore_$id');
  }

  /// Genera un ID numerico stabile da una stringa (es. document ID di Firestore).
  /// Usa hashCode, che è deterministico per la stessa stringa nella stessa sessione.
  static int generateId(String documentId) => documentId.hashCode.abs() % 100000;
}
