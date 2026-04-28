import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/firebase/firestore_service.dart';
import 'package:electromart_pro/core/models/order_model.dart';
import 'package:electromart_pro/core/providers/banner_provider.dart';

final ordersProvider = StateNotifierProvider.family<
    OrdersNotifier,
    AsyncValue<List<OrderModel>>,
    String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return OrdersNotifier(firestoreService, userId);
});

final orderProvider =
    StreamProvider.family<OrderModel?, String>((ref, orderId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getOrder(orderId);
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

      // ⚠️ FIX: don't cast OrderModel to DocumentSnapshot
      // You should handle pagination inside FirestoreService instead
      // So we safely remove wrong casting
      // _lastDocument = orders.last as DocumentSnapshot<Object?>?;

      if (refresh) {
        state = AsyncValue.data(orders);
      } else {
        state = state.whenData((currentOrders) {
          return [...currentOrders, ...orders];
        });
      }

      // OPTIONAL: if you REALLY need pagination cursor,
      // you must return DocumentSnapshot from FirestoreService
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String> createOrder(OrderModel order) async {
    try {
      final orderId = await _firestoreService.createOrder(order);

      // refresh list after creating order
      loadOrders(refresh: true);

      return orderId;
    } catch (error) {
      // IMPORTANT FIX: always return or throw
      throw Exception("Create order failed: $error");
    }
  }

  void reset() {
    _lastDocument = null;
    _hasMore = true;
    state = const AsyncValue.loading();
  }

  bool get hasMore => _hasMore;
}