import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/firebase/firestore_service.dart';
import 'package:electromart_pro/core/models/cart_model.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final cartProvider =
    StateNotifierProvider.family<CartNotifier, AsyncValue<CartModel?>, String>(
        (ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return CartNotifier(firestoreService, userId);
});

class CartNotifier extends StateNotifier<AsyncValue<CartModel?>> {
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
        (cart) {
          state = AsyncValue.data(cart);
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
      state.whenData((cart) {
        if (cart != null) {
          final existingIndex =
              cart.items.indexWhere((i) => i.productId == item.productId);
          if (existingIndex != -1) {
            cart.items[existingIndex] = item;
          } else {
            cart.items.add(item);
          }
          state = AsyncValue.data(cart.copyWith(updatedAt: DateTime.now()));
        }
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      await _firestoreService.removeFromCart(_userId, productId);
      // Optimistic update
      state.whenData((cart) {
        if (cart != null) {
          cart.items.removeWhere((item) => item.productId == productId);
          state = AsyncValue.data(cart.copyWith(updatedAt: DateTime.now()));
        }
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
      state.whenData((cart) async {
        if (cart != null) {
          final itemIndex =
              cart.items.indexWhere((item) => item.productId == productId);
          if (itemIndex != -1) {
            final updatedItem =
                cart.items[itemIndex].copyWith(quantity: quantity);
            await _firestoreService.addToCart(_userId, updatedItem);
            cart.items[itemIndex] = updatedItem;
            state = AsyncValue.data(cart.copyWith(updatedAt: DateTime.now()));
          }
        }
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> applyCoupon(String couponCode) async {
    try {
      state.whenData((cart) {
        if (cart != null) {
          state = AsyncValue.data(
              cart.copyWith(couponCode: couponCode, updatedAt: DateTime.now()));
        }
      });
      // In a real app, validate coupon with backend
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> clearCart() async {
    try {
      state.whenData((cart) {
        if (cart != null) {
          for (final item in cart.items) {
            _firestoreService.removeFromCart(_userId, item.productId);
          }
          state = AsyncValue.data(
              cart.copyWith(items: [], updatedAt: DateTime.now()));
        }
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}
