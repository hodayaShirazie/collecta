import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService().notificationsStream,
      initialData: NotificationService().notifications,
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return GestureDetector(
          onTap: () => _showNotificationList(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF1E5DAA),
                    size: 24,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationList(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _NotificationListDialog(),
    );
  }
}

class _NotificationListDialog extends StatefulWidget {
  const _NotificationListDialog();

  @override
  State<_NotificationListDialog> createState() =>
      _NotificationListDialogState();
}

class _NotificationListDialogState extends State<_NotificationListDialog> {
  late StreamSubscription<List<NotificationModel>> _sub;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _notifications = List.of(NotificationService().notifications);
    _sub = NotificationService().notificationsStream.listen((data) {
      if (mounted) setState(() => _notifications = List.of(data));
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              Flexible(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Color(0xFF1E5DAA), size: 22),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'התראות',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E5DAA),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_notifications.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'אין התראות',
          style: TextStyle(color: Colors.black38, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          _NotificationItem(notification: _notifications[index]),
    );
  }
}

class _NotificationItem extends StatefulWidget {
  final NotificationModel notification;
  const _NotificationItem({required this.notification});

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _markingRead = false;

  Future<void> _onTap() async {
    if (!widget.notification.isRead && !_markingRead) {
      setState(() => _markingRead = true);
      await NotificationService().markAsRead(widget.notification.id);
    }
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) =>
            _NotificationDetailsDialog(notification: widget.notification),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !widget.notification.isRead;
    final textColor = isUnread ? Colors.black87 : Colors.grey;
    final subColor = isUnread ? Colors.black54 : Colors.grey;

    return InkWell(
      onTap: _onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Icon(
                Icons.circle,
                size: 8,
                color: isUnread ? const Color(0xFF1E5DAA) : Colors.grey[300],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.notification.businessName.isNotEmpty
                        ? widget.notification.businessName
                        : 'תרומה בוטלה',
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.notification.cancelingReason.isNotEmpty
                        ? widget.notification.cancelingReason
                        : 'ביטול תרומה',
                    style: TextStyle(color: subColor, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(widget.notification.createdAt),
              style: TextStyle(
                color: subColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} ימים';
    if (diff.inHours > 0) return "${diff.inHours} שע'";
    if (diff.inMinutes > 0) return "${diff.inMinutes} דק'";
    return 'עכשיו';
  }
}

class _NotificationDetailsDialog extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationDetailsDialog({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cancel_outlined,
                        color: Colors.red, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'פרטי ביטול תרומה',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                _DetailRow(
                    label: 'שם עסק',
                    value: notification.businessName),
                const SizedBox(height: 8),
                _DetailRow(
                    label: 'איש קשר',
                    value: notification.contactName),
                const SizedBox(height: 8),
                _DetailRow(
                    label: 'טלפון', value: notification.contactPhone),
                const SizedBox(height: 8),
                _DetailRow(
                    label: 'סיבת ביטול',
                    value: notification.cancelingReason),
                const SizedBox(height: 8),
                _DetailRow(
                    label: 'תאריך',
                    value: _formatDate(notification.createdAt)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
