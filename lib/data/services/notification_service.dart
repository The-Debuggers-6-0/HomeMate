import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class AppLocalNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  bool isRead;
  final String type;

  AppLocalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'date': date.toIso8601String(),
    'isRead': isRead,
    'type': type,
  };

  factory AppLocalNotification.fromJson(Map<String, dynamic> json) => AppLocalNotification(
    id: json['id'].toString(),
    title: json['title'],
    body: json['body'],
    date: DateTime.parse(json['date']),
    isRead: json['isRead'] ?? false,
    type: json['type'] ?? 'general',
  );
}

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
  
  // Notifier per il numero di notifiche non lette
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

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

    await _loadUnreadCount();

    _initialized = true;
    debugPrint('[NotificationService] Inizializzato con successo');
  }

  Future<void> _loadUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('notifications_history') ?? [];
    int unread = 0;
    for (final jsonStr in historyJson) {
      final notif = AppLocalNotification.fromJson(jsonDecode(jsonStr));
      if (!notif.isRead) unread++;
    }
    unreadCountNotifier.value = unread;
  }

  Future<void> _saveToHistory(AppLocalNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('notifications_history') ?? [];
    
    historyJson.insert(0, jsonEncode(notification.toJson()));
    
    // mantieni solo le ultime 50
    if (historyJson.length > 50) historyJson.removeLast();
    
    await prefs.setStringList('notifications_history', historyJson);
    await _loadUnreadCount();
  }

  /// Recupera tutte le notifiche salvate
  Future<List<AppLocalNotification>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('notifications_history') ?? [];
    return historyJson.map((str) => AppLocalNotification.fromJson(jsonDecode(str))).toList();
  }

  /// Segna tutte come lette
  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('notifications_history') ?? [];
    
    final updatedJson = historyJson.map((str) {
      final notif = AppLocalNotification.fromJson(jsonDecode(str));
      notif.isRead = true;
      return jsonEncode(notif.toJson());
    }).toList();
    
    await prefs.setStringList('notifications_history', updatedJson);
    await _loadUnreadCount();
  }

  /// Pulisce tutto lo storico (ad es. al logout)
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications_history');
    await _loadUnreadCount();
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
        
    await _saveToHistory(AppLocalNotification(
      id: id.toString(),
      title: title,
      body: body,
      date: DateTime.now(),
      type: 'payment'
    ));
        
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
    
    await _saveToHistory(AppLocalNotification(
      id: id.toString(),
      title: title,
      body: body,
      date: DateTime.now(),
      type: 'event'
    ));
    
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
    
    await _saveToHistory(AppLocalNotification(
      id: id.toString(),
      title: title,
      body: body,
      date: DateTime.now(),
      type: 'chore'
    ));
    
    await show(id: id, title: title, body: body, payload: 'chore_$id');
  }

  /// Genera un ID numerico stabile da una stringa (es. document ID di Firestore).
  /// Usa hashCode, che è deterministico per la stessa stringa nella stessa sessione.
  static int generateId(String documentId) => documentId.hashCode.abs() % 100000;
}
