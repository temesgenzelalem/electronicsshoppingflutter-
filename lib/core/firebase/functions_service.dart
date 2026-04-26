import 'package:cloud_functions/cloud_functions.dart';

class FunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> processPayment(
      Map<String, dynamic> paymentData) async {
    final callable = _functions.httpsCallable('processPayment');
    final result = await callable.call(paymentData);
    return result.data as Map<String, dynamic>;
  }

  Future<void> sendOrderConfirmationEmail(String orderId) async {
    final callable = _functions.httpsCallable('sendOrderConfirmationEmail');
    await callable.call({'orderId': orderId});
  }

  Future<void> generateInvoice(String orderId) async {
    final callable = _functions.httpsCallable('generateInvoice');
    await callable.call({'orderId': orderId});
  }

  Future<void> updateProductStock(String productId, int quantity) async {
    final callable = _functions.httpsCallable('updateProductStock');
    await callable.call({'productId': productId, 'quantity': quantity});
  }

  Future<void> sendPushNotification(String userId, String title, String body,
      Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('sendPushNotification');
    await callable.call({
      'userId': userId,
      'title': title,
      'body': body,
      'data': data,
    });
  }

  Future<void> cleanAbandonedCarts() async {
    final callable = _functions.httpsCallable('cleanAbandonedCarts');
    await callable.call();
  }

  Future<Map<String, dynamic>> generateSalesReport(
      DateTime startDate, DateTime endDate) async {
    final callable = _functions.httpsCallable('generateSalesReport');
    final result = await callable.call({
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    });
    return result.data as Map<String, dynamic>;
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    final callable = _functions.httpsCallable('addProduct');
    await callable.call(productData);
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    final callable = _functions.httpsCallable('updateProduct');
    await callable.call({'productId': productId, ...productData});
  }

  Future<void> deleteProduct(String productId) async {
    final callable = _functions.httpsCallable('deleteProduct');
    await callable.call({'productId': productId});
  }

  Future<void> addBanner(Map<String, dynamic> bannerData) async {
    final callable = _functions.httpsCallable('addBanner');
    await callable.call(bannerData);
  }

  Future<void> createCoupon(Map<String, dynamic> couponData) async {
    final callable = _functions.httpsCallable('createCoupon');
    await callable.call(couponData);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final callable = _functions.httpsCallable('updateOrderStatus');
    await callable.call({'orderId': orderId, 'status': status});
  }
}
