import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/firebase/firestore_service.dart';
import 'package:electromart_pro/core/models/product_model.dart';
import 'package:electromart_pro/core/providers/banner_provider.dart';

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<ProductModel>>>(
        (ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ProductsNotifier(firestoreService);
});

final productProvider =
    FutureProvider.family<ProductModel?, String>((ref, productId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getProduct(productId);
});

final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  // TODO: Implement getFeaturedProducts in FirestoreService
  return Future.value([]); // Placeholder
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final FirestoreService _firestoreService;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  ProductsNotifier(this._firestoreService) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts({
    String? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
    double? minRating,
    bool? inStock,
    String? sortBy,
    bool? descending,
    bool refresh = false,
  }) async {
    if (refresh) {
      _lastDocument = null;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!_hasMore && !refresh) return;

    try {
      final products = await _firestoreService.getProducts(
        categoryId: categoryId,
        searchQuery: searchQuery,
        minPrice: minPrice,
        maxPrice: maxPrice,
        brands: brands,
        minRating: minRating,
        inStock: inStock,
        sortBy: sortBy,
        descending: descending,
        startAfter: _lastDocument,
      );

      if (products.length < 20) {
        _hasMore = false;
      }

      if (products.isNotEmpty) {
        _lastDocument = products.last as DocumentSnapshot<Object?>?;
      }

      if (refresh) {
        state = AsyncValue.data(products);
      } else {
        state.whenData((currentProducts) {
          state = AsyncValue.data([...currentProducts, ...products]);
        });
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  void reset() {
    _lastDocument = null;
    _hasMore = true;
    state = const AsyncValue.loading();
  }

  bool get hasMore => _hasMore;
}
