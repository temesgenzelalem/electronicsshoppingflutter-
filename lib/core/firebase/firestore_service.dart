import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electromart_pro/core/constants/firebase_constants.dart';
import 'package:electromart_pro/core/models/user_model.dart';
import 'package:electromart_pro/core/models/product_model.dart';
import 'package:electromart_pro/core/models/cart_model.dart';
import 'package:electromart_pro/core/models/order_model.dart';
import 'package:electromart_pro/core/models/coupon_model.dart';
import 'package:electromart_pro/core/models/banner_model.dart';
import 'package:electromart_pro/core/models/review_model.dart';
import 'package:electromart_pro/core/models/notification_model.dart';

/// ✅ Generic pagination wrapper
class PaginatedResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDoc;

  PaginatedResult({
    required this.items,
    required this.lastDoc,
  });
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enable offline persistence (FIXED)
  Future<void> enablePersistence() async {
    try {
      await _firestore.enablePersistence();
    } catch (_) {
      // already enabled or unsupported
    }
  }

  // USERS
  Future<void> createUserProfile(UserModel user) async {
    await _firestore
        .collection(FirebaseConstants.users)
        .doc(user.id)
        .set(user.toFirestore());
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final doc =
        await _firestore.collection(FirebaseConstants.users).doc(userId).get();

    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  Stream<UserModel?> getUserProfileStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.users)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.users)
        .doc(userId)
        .update(data);
  }

  // PRODUCTS (unchanged but safe)
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
    double? minRating,
    bool? inStock,
    String? sortBy,
    bool? descending,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _firestore.collection(FirebaseConstants.products);

    if (categoryId != null) {
      query = query.where('category', isEqualTo: categoryId);
    }

    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }

    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    if (brands != null && brands.isNotEmpty) {
      query = query.where('brand', whereIn: brands);
    }

    if (minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    if (inStock == true) {
      query = query.where('stock', isGreaterThan: 0);
    }

    if (sortBy != null) {
      query = query.orderBy(sortBy, descending: descending ?? false);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  // CART (unchanged)
  Future<void> addToCart(String userId, CartItemModel item) async {
    final ref = _firestore.collection(FirebaseConstants.carts).doc(userId);
    final doc = await ref.get();

    if (doc.exists) {
      final cart = CartModel.fromFirestore(doc);

      final index = cart.items.indexWhere((i) => i.productId == item.productId);

      if (index != -1) {
        cart.items[index] = item;
      } else {
        cart.items.add(item);
      }

      await ref.update({
        'items': cart.items.map((e) => e.toFirestore()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      final cart = CartModel(
        userId: userId,
        items: [item],
        updatedAt: DateTime.now(),
      );

      await ref.set(cart.toFirestore());
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    final ref = _firestore.collection(FirebaseConstants.carts).doc(userId);
    final doc = await ref.get();

    if (!doc.exists) return;

    final cart = CartModel.fromFirestore(doc);
    cart.items.removeWhere((e) => e.productId == productId);

    if (cart.items.isEmpty) {
      await ref.delete();
    } else {
      await ref.update({
        'items': cart.items.map((e) => e.toFirestore()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<CartModel?> getCartStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.carts)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? CartModel.fromFirestore(doc) : null);
  }

  // WISHLIST (unchanged)
  Future<void> addToWishlist(String userId, String productId) async {
    await _firestore
        .collection(FirebaseConstants.wishlists)
        .doc(userId)
        .collection(FirebaseConstants.productsSub)
        .doc(productId)
        .set({
      'productId': productId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    await _firestore
        .collection(FirebaseConstants.wishlists)
        .doc(userId)
        .collection(FirebaseConstants.productsSub)
        .doc(productId)
        .delete();
  }

  // ORDERS (🔥 FIXED PAGINATION)
  Future<String> createOrder(OrderModel order) async {
    final ref = _firestore.collection(FirebaseConstants.orders).doc();
    final orderWithId = order.copyWith(id: ref.id);

    await ref.set(orderWithId.toFirestore());
    return ref.id;
  }

  Future<PaginatedResult<OrderModel>> getUserOrders(
    String userId, {
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    Query query = _firestore
        .collection(FirebaseConstants.orders)
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    final orders =
        snapshot.docs.map((e) => OrderModel.fromFirestore(e)).toList();

    return PaginatedResult(
      items: orders,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }

  Stream<OrderModel?> getOrderStream(String orderId) {
    return _firestore
        .collection(FirebaseConstants.orders)
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? OrderModel.fromFirestore(doc) : null);
  }

  // COUPONS
  Future<CouponModel?> getCoupon(String code) async {
    final doc =
        await _firestore.collection(FirebaseConstants.coupons).doc(code).get();

    return doc.exists ? CouponModel.fromFirestore(doc) : null;
  }

  // BANNERS
  Future<List<BannerModel>> getActiveBanners() async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.banners)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs.map((e) => BannerModel.fromFirestore(e)).toList();
  }

  // REVIEWS (FIXED PAGINATION)
  Future<PaginatedResult<ReviewModel>> getProductReviews(
    String productId, {
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    Query query = _firestore
        .collection(FirebaseConstants.reviews)
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    final reviews =
        snapshot.docs.map((e) => ReviewModel.fromFirestore(e)).toList();

    return PaginatedResult(
      items: reviews,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }

  // NOTIFICATIONS
  Stream<List<NotificationModel>> getUserNotifications(String userId,
      {int limit = 20}) {
    return _firestore
        .collection(FirebaseConstants.notifications)
        .doc(userId)
        .collection(FirebaseConstants.notificationsSub)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((e) => NotificationModel.fromFirestore(e)).toList());
  }

  // ANALYTICS
  Future<void> logEvent(
      String userId, String eventType, Map<String, dynamic> data) async {
    await _firestore.collection(FirebaseConstants.analytics).add({
      'userId': userId,
      'eventType': eventType,
      'timestamp': FieldValue.serverTimestamp(),
      'deviceInfo': data,
    });
  }
}
