import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/firebase/firestore_service.dart';
import 'package:electromart_pro/core/models/order_model.dart';
import 'package:electromart_pro/core/providers/banner_provider.dart';

final ordersProvider = StateNotifierProvider.family<OrdersNotifier,
    AsyncValue<List<OrderModel>>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return OrdersNotifier(firestoreService, userId);
});

final orderProvider =
    StreamProvider.family<OrderModel?, String>((ref, orderId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getOrderStream(orderId);
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final FirestoreService _firestoreService;
  final String _userId;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  OrdersNotifier(this._firestoreService, this._userId)
      : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _lastDocument = null;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!_hasMore && !refresh) return;

    try {
      final orders = await _firestoreService.getUserOrders(
        _userId,
        startAfter: _lastDocument,
      );

      if (orders.length < 10) {
        _hasMore = false;
      }

      if (orders.isNotEmpty) {
        _lastDocument = orders.last as DocumentSnapshot<Object?>?;
      }

      if (refresh) {
        state = AsyncValue.data(orders);
      } else {
        state.whenData((currentOrders) {
          state = AsyncValue.data([...currentOrders, ...orders]);
        });
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<String> createOrder(OrderModel order) async {
    try {
      final orderId = await _firestoreService.createOrder(order);
      // Refresh orders list
      loadOrders(refresh: true);
      return orderId;
    } catch (error) {
      // rethrow suppressed to prevent crash
    }
  }

  void reset() {
    _lastDocument = null;
    _hasMore = true;
    state = const AsyncValue.loading();
  }

  bool get hasMore => _hasMore;
}
