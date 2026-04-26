// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      paymentId: json['paymentId'] as String?,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      shippingAddress: AddressModel.fromJson(
          json['shippingAddress'] as Map<String, dynamic>),
      trackingId: json['trackingId'] as String?,
      estimatedDelivery: json['estimatedDelivery'] == null
          ? null
          : DateTime.parse(json['estimatedDelivery'] as String),
      orderDate: DateTime.parse(json['orderDate'] as String),
      deliveryDate: json['deliveryDate'] == null
          ? null
          : DateTime.parse(json['deliveryDate'] as String),
      reviewSubmitted: json['reviewSubmitted'] as bool? ?? false,
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'deliveryCharge': instance.deliveryCharge,
      'discount': instance.discount,
      'totalAmount': instance.totalAmount,
      'paymentMethod': instance.paymentMethod,
      'paymentId': instance.paymentId,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'shippingAddress': instance.shippingAddress,
      'trackingId': instance.trackingId,
      'estimatedDelivery': instance.estimatedDelivery?.toIso8601String(),
      'orderDate': instance.orderDate.toIso8601String(),
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'reviewSubmitted': instance.reviewSubmitted,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.processing: 'processing',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.refunded: 'refunded',
};

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      selectedVariants:
          Map<String, String>.from(json['selectedVariants'] as Map),
      reviewId: json['reviewId'] as String?,
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'productImage': instance.productImage,
      'price': instance.price,
      'quantity': instance.quantity,
      'selectedVariants': instance.selectedVariants,
      'reviewId': instance.reviewId,
    };
