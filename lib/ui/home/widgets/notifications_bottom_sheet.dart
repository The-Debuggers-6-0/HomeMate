import 'package:flutter/material.dart';
import '../../../data/services/notification_service.dart';
import '../../core/themes/app_colors.dart';
import 'package:intl/intl.dart';

class NotificationsBottomSheet extends StatefulWidget {
  const NotificationsBottomSheet({super.key});

  @override
  State<NotificationsBottomSheet> createState() => _NotificationsBottomSheetState();
}

class _NotificationsBottomSheetState extends State<NotificationsBottomSheet> {
  List<AppLocalNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final history = await NotificationService().getHistory();
    setState(() {
      _notifications = history;
      _isLoading = false;
    });
    // Appena si apre la tendina, li segniamo come letti
    await NotificationService().markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Centro Notifiche',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_notifications.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    await NotificationService().clearHistory();
                    setState(() {
                      _notifications.clear();
                    });
                  },
                  child: const Text('Cancella tutte', style: TextStyle(color: Colors.redAccent)),
                ),
            ],
          ),
          const Divider(),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _notifications.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            Text('Nessuna notifica', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notif = _notifications[index];
                          return _buildNotificationTile(notif);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(AppLocalNotification notif) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case 'payment':
        icon = Icons.payment;
        iconColor = Colors.orange;
        break;
      case 'event':
        icon = Icons.event;
        iconColor = Colors.blue;
        break;
      case 'chore':
        icon = Icons.cleaning_services;
        iconColor = AppColors.primaryGreen;
        break;
      case 'achievement':
        icon = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.15),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        notif.title,
        style: TextStyle(
          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notif.body, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM HH:mm').format(notif.date),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }
}