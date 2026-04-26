import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';
import 'package:electromart_pro/core/providers/order_provider.dart';
import 'package:electromart_pro/core/models/order_model.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(orderProvider(orderId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return _buildOrderTracking(order);
        },
      ),
    );
  }

  Widget _buildOrderTracking(OrderModel order) {
    final steps = [
      {
        'title': 'Order Placed',
        'subtitle': 'Your order has been confirmed',
        'completed': true
      },
      {
        'title': 'Order Confirmed',
        'subtitle': 'Seller has confirmed your order',
        'completed': order.status != OrderStatus.pending
      },
      {
        'title': 'Shipped',
        'subtitle': 'Your order is on the way',
        'completed':
            [OrderStatus.shipped, OrderStatus.delivered].contains(order.status)
      },
      {
        'title': 'Delivered',
        'subtitle': 'Order delivered successfully',
        'completed': order.status == OrderStatus.delivered
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID and Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: AppConstants.headline2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: AppConstants.bodyText1,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.status.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (order.trackingId != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tracking ID: ${order.trackingId}',
                      style: AppConstants.bodyText1,
                    ),
                  ],
                  if (order.estimatedDelivery != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Estimated Delivery: ${order.estimatedDelivery}',
                      style: AppConstants.bodyText1,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Order Progress
          Text(
            'Order Progress',
            style: AppConstants.headline2,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step['completed'] as bool
                            ? AppConstants.primaryColor
                            : Colors.grey,
                      ),
                      child: Icon(
                        step['completed'] as bool ? Icons.check : Icons.circle,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: steps[index + 1]['completed'] as bool
                            ? AppConstants.primaryColor
                            : Colors.grey,
                      ),
                  ],
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: AppConstants.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['subtitle'] as String,
                        style: AppConstants.bodyText2,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: AppConstants.paddingLarge),

          // Order Items
          Text(
            'Order Items',
            style: AppConstants.headline2,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          ...order.items.map((item) => Card(
                child: ListTile(
                  title: Text(item.productName),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                ),
              )),

          const SizedBox(height: AppConstants.paddingLarge),

          // Order Total
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: AppConstants.headline2,
                  ),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: AppConstants.headline2.copyWith(
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Action Buttons
          if (order.status == OrderStatus.pending) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Cancel order
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text(
                  'Cancel Order',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Reorder
              },
              child: const Text('Reorder'),
            ),
          ),

          if (order.status == OrderStatus.delivered &&
              !order.reviewSubmitted) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to review screen
                },
                child: const Text('Leave Review'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.yellow;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }
}
