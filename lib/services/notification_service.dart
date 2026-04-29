import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _subscription;

  final _listController =
      StreamController<List<NotificationModel>>.broadcast();
  final _newNotifController =
      StreamController<NotificationModel>.broadcast();

  List<NotificationModel> _notifications = [];
  final Set<String> _seenIds = {};
  bool _initialLoadDone = false;
  bool _started = false;

  Stream<List<NotificationModel>> get notificationsStream =>
      _listController.stream;

  Stream<NotificationModel> get newNotifications => _newNotifController.stream;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void start(String orgId) {
    if (_started) return;
    _started = true;

    _subscription = _firestore
        .collection('notifications')
        .where('organizationId', isEqualTo: orgId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(_handleSnapshot, onError: (e) {
          // ignore: avoid_print
          print('[NotificationService] Firestore error: $e');
        });
  }

  void _handleSnapshot(QuerySnapshot snapshot) {
    final notifications = snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();

    if (!_initialLoadDone) {
      _seenIds.addAll(notifications.map((n) => n.id));
      _initialLoadDone = true;
    } else {
      for (final n in notifications) {
        if (!_seenIds.contains(n.id)) {
          _seenIds.add(n.id);
          if (!_newNotifController.isClosed) {
            _newNotifController.add(n);
          }
        }
      }
    }

    _notifications = notifications;
    if (!_listController.isClosed) {
      _listController.add(List.unmodifiable(notifications));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _started = false;
    _initialLoadDone = false;
    _seenIds.clear();
    _notifications = [];
  }
}
