import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel {
  final String userId;
  final List<CartItemModel> items;
  final String? couponCode;
  final DateTime updatedAt;

  CartModel({
    required this.userId,
    required this.items,
    this.couponCode,
    required this.updatedAt,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  factory CartModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }

  Map<String, dynamic> toFirestore() => toJson();

  CartModel copyWith({
    String? userId,
    List<CartItemModel>? items,
    String? couponCode,
    DateTime? updatedAt,
  }) {
    return CartModel(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class CartItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double? discountPrice;
  final int quantity;
  final Map<String, String>
      selectedVariants; // e.g., {"Color": "Red", "Storage": "128GB"}
  final DateTime addedAt;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.discountPrice,
    required this.quantity,
    required this.selectedVariants,
    required this.addedAt,
  });

  double get currentPrice => discountPrice ?? price;

  double get totalPrice => currentPrice * quantity;

  bool get isOnSale => discountPrice != null && discountPrice! < price;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  Map<String, dynamic> toFirestore() => toJson();

  CartItemModel copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? discountPrice,
    int? quantity,
    Map<String, String>? selectedVariants,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      quantity: quantity ?? this.quantity,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
