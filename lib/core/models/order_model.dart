import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:electromart_pro/core/models/user_model.dart';

part 'order_model.g.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

@JsonSerializable()
class OrderModel {
  final String? id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double tax;
  final double deliveryCharge;
  final double discount;
  final double totalAmount;
  final String paymentMethod;
  final String? paymentId;
  final OrderStatus status;
  final AddressModel shippingAddress;
  final String? trackingId;
  final DateTime? estimatedDelivery;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final bool reviewSubmitted;

  OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryCharge,
    required this.discount,
    required this.totalAmount,
    required this.paymentMethod,
    this.paymentId,
    required this.status,
    required this.shippingAddress,
    this.trackingId,
    this.estimatedDelivery,
    required this.orderDate,
    this.deliveryDate,
    this.reviewSubmitted = false,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromJson(data).copyWith(id: doc.id);
  }

  Map<String, dynamic> toFirestore() => toJson();

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItemModel>? items,
    double? subtotal,
    double? tax,
    double? deliveryCharge,
    double? discount,
    double? totalAmount,
    String? paymentMethod,
    String? paymentId,
    OrderStatus? status,
    AddressModel? shippingAddress,
    String? trackingId,
    DateTime? estimatedDelivery,
    DateTime? orderDate,
    DateTime? deliveryDate,
    bool? reviewSubmitted,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingId: trackingId ?? this.trackingId,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      reviewSubmitted: reviewSubmitted ?? this.reviewSubmitted,
    );
  }
}

@JsonSerializable()
class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final Map<String, String> selectedVariants;
  final String? reviewId;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.selectedVariants,
    this.reviewId,
  });

  double get totalPrice => price * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}
