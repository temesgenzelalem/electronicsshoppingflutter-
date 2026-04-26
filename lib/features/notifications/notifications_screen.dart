import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';
import 'package:electromart_pro/core/providers/notification_provider.dart';
import 'package:electromart_pro/core/models/notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync =
        ref.watch(notificationsProvider('test_user')); // TODO: Get user ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Mark all as read
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(notificationsProvider('test_user'));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyNotifications();
          }
          return _buildNotificationsList(notifications);
        },
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Text(
            'No notifications yet',
            style: AppConstants.headline2,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'You\'ll see your order updates and offers here',
            style: AppConstants.bodyText2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.createdAt),
              style: AppConstants.bodyText2,
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!notification.isRead) {
            // TODO: Mark as read
            // ref.read(notificationsProvider('test_user').notifier).markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return Colors.green;
      case NotificationType.priceDrop:
        return Colors.orange;
      case NotificationType.backInStock:
        return Colors.blue;
      case NotificationType.flashSale:
        return Colors.red;
      case NotificationType.abandonedCart:
        return Colors.yellow;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return Icons.shopping_bag;
      case NotificationType.priceDrop:
        return Icons.price_check;
      case NotificationType.backInStock:
        return Icons.inventory;
      case NotificationType.flashSale:
        return Icons.flash_on;
      case NotificationType.abandonedCart:
        return Icons.shopping_cart;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // TODO: Handle different notification types
    switch (notification.type) {
      case NotificationType.orderUpdate:
        // Navigate to order tracking
        if (notification.data?['orderId'] != null) {
          Navigator.of(context).pushNamed(
            '/order-tracking',
            arguments: notification.data!['orderId'],
          );
        }
        break;
      case NotificationType.priceDrop:
      case NotificationType.backInStock:
        // Navigate to product detail
        if (notification.data?['productId'] != null) {
          Navigator.of(context).pushNamed(
            '/product-detail',
            arguments: notification.data!['productId'],
          );
        }
        break;
      case NotificationType.flashSale:
        // Navigate to relevant screen
        break;
      case NotificationType.abandonedCart:
        // Navigate to cart
        Navigator.of(context).pushNamed('/cart');
        break;
      case NotificationType.general:
        // Do nothing
        break;
    }
  }
}
