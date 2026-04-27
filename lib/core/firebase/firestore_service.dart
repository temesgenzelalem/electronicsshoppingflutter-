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

  // PRODUCTS
  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.products)
        .doc(productId)
        .get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
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

  // ORDERS
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

  // NOTIFICATIONS
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
