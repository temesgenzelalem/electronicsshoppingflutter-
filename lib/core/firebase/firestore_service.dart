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

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.users)
        .doc(userId)
        .update(data);
  }

  // PRODUCTS
  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.products)
        .doc(productId)
        .get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? searchQuery,
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
    Query query = _firestore.collection(FirebaseConstants.products).limit(limit);

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Note: This is a simple search, for full-text search you'd need Algolia or similar
      query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
                   .where('name', isLessThan: searchQuery + '\uf8ff');
    }

    // Add other filters if needed, but Firestore has limitations on multiple where clauses

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((e) => ProductModel.fromFirestore(e)).toList();
  }

  // WISHLIST
  Stream<List<String>> getWishlistStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.wishlists)
        .doc(userId)
        .collection(FirebaseConstants.productsSub)
        .snapshots()
        .map((snap) => snap.docs.map((e) => e.id).toList());
  }

  Future<void> addToWishlist(String userId, String productId) async {
    await _firestore
        .collection(FirebaseConstants.wishlists)
        .doc(userId)
        .collection(FirebaseConstants.productsSub)
        .doc(productId)
        .set({'addedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    await _firestore
        .collection(FirebaseConstants.wishlists)
        .doc(userId)
        .collection(FirebaseConstants.productsSub)
        .doc(productId)
        .delete();
  }

  Stream<OrderModel?> getOrder(String orderId) {
    return _firestore.collection(FirebaseConstants.orders).doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OrderModel.fromFirestore(doc);
    });
  }
  Future<List<BannerModel>> getActiveBanners() async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.banners)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs.map((e) => BannerModel.fromFirestore(e)).toList();
  }
  Stream<List<CartItemModel>> getCartStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.carts)
        .doc(userId)
        .collection(FirebaseConstants.items)
        .snapshots()
        .map((snap) => snap.docs.map((e) => CartItemModel.fromFirestore(e)).toList());
  }

  Future<void> addToCart(String userId, CartItemModel item) async {
    await _firestore
        .collection(FirebaseConstants.carts)
        .doc(userId)
        .collection(FirebaseConstants.items)
        .doc(item.productId)
        .set(item.toFirestore());
  }

  Future<void> removeFromCart(String userId, String productId) async {
    await _firestore
        .collection(FirebaseConstants.carts)
        .doc(userId)
        .collection(FirebaseConstants.items)
        .doc(productId)
        .delete();
  }
  Future<String> createOrder(OrderModel order) async {
    final ref = _firestore.collection(FirebaseConstants.orders).doc();
    final newOrder = order.copyWith(id: ref.id);
    await ref.set(newOrder.toFirestore());
    return ref.id;
  }

  Future<List<OrderModel>> getUserOrders(
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
    return snapshot.docs.map((e) => OrderModel.fromFirestore(e)).toList();
  }

  Stream<List<OrderModel>> getOrderStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.orders)
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((e) => OrderModel.fromFirestore(e)).toList());
  }

  // NOTIFICATIONS
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.notifications)
        .doc(userId)
        .collection(FirebaseConstants.notificationsSub)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((e) => NotificationModel.fromFirestore(e)).toList();
  }

  Future<void> markNotificationAsRead(
      String userId, String notificationId) async {
    await _firestore
        .collection(FirebaseConstants.notifications)
        .doc(userId)
        .collection(FirebaseConstants.notificationsSub)
        .doc(notificationId)
        .update({'isRead': true});
  }
}
