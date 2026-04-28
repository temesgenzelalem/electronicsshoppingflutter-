import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/firebase/firestore_service.dart';
import 'package:electromart_pro/core/models/notification_model.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final notificationsProvider = StateNotifierProvider.family<
    NotificationsNotifier,
    AsyncValue<List<NotificationModel>>,
    String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return NotificationsNotifier(firestoreService, userId);
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final FirestoreService _firestoreService;
  final String _userId;

  NotificationsNotifier(this._firestoreService, this._userId)
      : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _firestoreService.getUserNotifications(_userId);
      state = AsyncValue.data(notifications);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(_userId, notificationId);
      // Optimistic update
      state.whenData((notifications) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          state = AsyncValue.data([...notifications]);
        }
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      state.whenData((notifications) async {
        for (final notification in notifications.where((n) => !n.isRead)) {
          await _firestoreService.markNotificationAsRead(
              _userId, notification.id);
        }
        final updatedNotifications =
            notifications.map((n) => n.copyWith(isRead: true)).toList();
        state = AsyncValue.data(updatedNotifications);
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  int get unreadCount {
    return state.maybeWhen(
      data: (notifications) => notifications.where((n) => !n.isRead).length,
      orElse: () => 0,
    );
  }
}
