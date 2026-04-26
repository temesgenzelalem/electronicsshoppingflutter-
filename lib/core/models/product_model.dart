import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double? discountPrice;
  final double rating;
  final int stock;
  final String description;
  final List<String> images;
  final List<ProductVariant> variants;
  final Map<String, dynamic> specifications;
  final String categoryId;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.discountPrice,
    required this.rating,
    required this.stock,
    required this.description,
    required this.images,
    required this.variants,
    required this.specifications,
    required this.categoryId,
    this.isFeatured = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  double get discountPercentage {
    if (discountPrice != null && discountPrice! < price) {
      return ((price - discountPrice!) / price) * 100;
    }
    return 0;
  }

  double get currentPrice => discountPrice ?? price;

  bool get isOnSale => discountPrice != null && discountPrice! < price;

  bool get isInStock => stock > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromJson(data).copyWith(id: doc.id);
  }

  Map<String, dynamic> toFirestore() => toJson();

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    double? discountPrice,
    double? rating,
    int? stock,
    String? description,
    List<String>? images,
    List<ProductVariant>? variants,
    Map<String, dynamic>? specifications,
    String? categoryId,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      images: images ?? this.images,
      variants: variants ?? this.variants,
      specifications: specifications ?? this.specifications,
      categoryId: categoryId ?? this.categoryId,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class ProductVariant {
  final String id;
  final String name; // e.g., "Color", "Storage"
  final String value; // e.g., "Red", "128GB"
  final double? priceModifier; // additional price for this variant
  final int? stock; // stock for this specific variant

  ProductVariant({
    required this.id,
    required this.name,
    required this.value,
    this.priceModifier,
    this.stock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(json);

  Map<String, dynamic> toJson() => _$ProductVariantToJson(this);
}
