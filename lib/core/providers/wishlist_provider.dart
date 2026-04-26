import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/firebase/firestore_service.dart';
import 'package:electromart_pro/core/providers/banner_provider.dart';

final wishlistProvider = StateNotifierProvider.family<WishlistNotifier,
    AsyncValue<List<String>>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return WishlistNotifier(firestoreService, userId);
});

class WishlistNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final FirestoreService _firestoreService;
  final String _userId;

  WishlistNotifier(this._firestoreService, this._userId)
      : super(const AsyncValue.loading()) {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    state = const AsyncValue.loading();
    try {
      final wishlistStream = _firestoreService.getWishlistStream(_userId);
      wishlistStream.listen(
        (productIds) {
          state = AsyncValue.data(productIds);
        },
        onError: (error) {
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> addToWishlist(String productId) async {
    try {
      await _firestoreService.addToWishlist(_userId, productId);
      // Optimistic update
      state.whenData((wishlist) {
        if (!wishlist.contains(productId)) {
          state = AsyncValue.data([...wishlist, productId]);
        }
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      await _firestoreService.removeFromWishlist(_userId, productId);
      // Optimistic update
      state.whenData((wishlist) {
        state =
            AsyncValue.data(wishlist.where((id) => id != productId).toList());
      });
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> toggleWishlist(String productId) async {
    state.whenData((wishlist) {
      if (wishlist.contains(productId)) {
        removeFromWishlist(productId);
      } else {
        addToWishlist(productId);
      }
    });
  }

  bool isInWishlist(String productId) {
    return state.maybeWhen(
      data: (wishlist) => wishlist.contains(productId),
      orElse: () => false,
    );
  }
}
