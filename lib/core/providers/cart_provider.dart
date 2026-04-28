import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/firebase/firestore_service.dart';
import 'package:electromart_pro/core/models/cart_model.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final cartProvider = StateNotifierProvider.family<CartNotifier,
    AsyncValue<List<CartItemModel>>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return CartNotifier(firestoreService, userId);
});

class CartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>> {
  final FirestoreService _firestoreService;
  final String _userId;

  CartNotifier(this._firestoreService, this._userId)
      : super(const AsyncValue.loading()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    state = const AsyncValue.loading();
    try {
      final cartStream = _firestoreService.getCartStream(_userId);
      cartStream.listen(
        (cartItems) {
          state = AsyncValue.data(cartItems);
        },
        onError: (error) {
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> addToCart(CartItemModel item) async {
    try {
      await _firestoreService.addToCart(_userId, item);
      // Optimistic update
      state.whenData((cartItems) {
        final existingIndex =
            cartItems.indexWhere((i) => i.productId == item.productId);
        if (existingIndex != -1) {
          cartItems[existingIndex] = item;
        } else {
          cartItems.add(item);
        }
        state = AsyncValue.data(List.from(cartItems));
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      await _firestoreService.removeFromCart(_userId, productId);
      // Optimistic update
      state.whenData((cartItems) {
        cartItems.removeWhere((item) => item.productId == productId);
        state = AsyncValue.data(List.from(cartItems));
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    try {
      state.whenData((cartItems) async {
        final itemIndex =
            cartItems.indexWhere((item) => item.productId == productId);
        if (itemIndex != -1) {
          final updatedItem = cartItems[itemIndex].copyWith(quantity: quantity);
          await _firestoreService.addToCart(_userId, updatedItem);
          cartItems[itemIndex] = updatedItem;
          state = AsyncValue.data(List.from(cartItems));
        }
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> clearCart() async {
    try {
      state.whenData((cartItems) {
        for (final item in cartItems) {
          _firestoreService.removeFromCart(_userId, item.productId);
        }
        state = AsyncValue.data([]);
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}
