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

  // Enable offline persistence
  Future<void> enablePersistence() async {
    await _firestore.enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    );
  }

  // Users
  Future<void> createUserProfile(UserModel user) async {
    await _firestore
        .collection(FirebaseConstants.users)
        .doc(user.id)
        .set(user.toFirestore());
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final doc =
        await _firestore.collection(FirebaseConstants.users).doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
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

  // Products
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

    if (inStock != null && inStock) {
      query = query.where('stock', isGreaterThan: 0);
    }

    if (sortBy != null) {
      query = query.orderBy(sortBy, descending: descending ?? false);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.products)
        .doc(productId)
        .get();
    if (doc.exists) {
      return ProductModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<ProductModel?> getProductStream(String productId) {
    return _firestore
        .collection(FirebaseConstants.products)
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists ? ProductModel.fromFirestore(doc) : null);
  }

  // Cart
  Future<void> addToCart(String userId, CartItemModel item) async {
    final cartRef = _firestore.collection(FirebaseConstants.carts).doc(userId);
    final cartDoc = await cartRef.get();

    if (cartDoc.exists) {
      final cart = CartModel.fromFirestore(cartDoc);
      final existingIndex =
          cart.items.indexWhere((i) => i.productId == item.productId);

      if (existingIndex != -1) {
        cart.items[existingIndex] = item;
      } else {
        cart.items.add(item);
      }

      await cartRef.update({
        'items': cart.items.map((i) => i.toFirestore()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      final cart = CartModel(
        userId: userId,
        items: [item],
        updatedAt: DateTime.now(),
      );
      await cartRef.set(cart.toFirestore());
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    final cartRef = _firestore.collection(FirebaseConstants.carts).doc(userId);
    final cartDoc = await cartRef.get();

    if (cartDoc.exists) {
      final cart = CartModel.fromFirestore(cartDoc);
      cart.items.removeWhere((item) => item.productId == productId);

      if (cart.items.isEmpty) {
        await cartRef.delete();
      } else {
        await cartRef.update({
          'items': cart.items.map((i) => i.toFirestore()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Stream<CartModel?> getCartStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.carts)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? CartModel.fromFirestore(doc) : null);
  }

  // Wishlist
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

  Stream<List<String>> getWishlistStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.wishlists)
        .doc(userId)
        .collection(FirebaseConstants.productsSub)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // Orders
  Future<String> createOrder(OrderModel order) async {
    final docRef = _firestore.collection(FirebaseConstants.orders).doc();
    final orderWithId = order.copyWith(id: docRef.id);
    await docRef.set(orderWithId.toFirestore());
    return docRef.id;
  }

  Future<List<OrderModel>> getUserOrders(String userId,
      {DocumentSnapshot? startAfter, int limit = 10}) async {
    Query query = _firestore
        .collection(FirebaseConstants.orders)
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
  }

  Stream<OrderModel?> getOrderStream(String orderId) {
    return _firestore
        .collection(FirebaseConstants.orders)
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? OrderModel.fromFirestore(doc) : null);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection(FirebaseConstants.orders).doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Coupons
  Future<CouponModel?> getCoupon(String code) async {
    final doc =
        await _firestore.collection(FirebaseConstants.coupons).doc(code).get();
    if (doc.exists) {
      return CouponModel.fromFirestore(doc);
    }
    return null;
  }

  // Banners
  Future<List<BannerModel>> getActiveBanners() async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.banners)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => BannerModel.fromFirestore(doc)).toList();
  }

  // Reviews
  Future<List<ReviewModel>> getProductReviews(String productId,
      {DocumentSnapshot? startAfter, int limit = 10}) async {
    Query query = _firestore
        .collection(FirebaseConstants.reviews)
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }

  Future<void> addReview(ReviewModel review) async {
    await _firestore
        .collection(FirebaseConstants.reviews)
        .doc(review.id)
        .set(review.toFirestore());
  }

  // Notifications
  Future<void> addNotification(
      String userId, NotificationModel notification) async {
    await _firestore
        .collection(FirebaseConstants.notifications)
        .doc(userId)
        .collection(FirebaseConstants.notificationsSub)
        .doc(notification.id)
        .set(notification.toFirestore());
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId,
      {int limit = 20}) {
    return _firestore
        .collection(FirebaseConstants.notifications)
        .doc(userId)
        .collection(FirebaseConstants.notificationsSub)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
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

  // Analytics
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
