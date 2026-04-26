import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coupon_model.g.dart';

enum DiscountType {
  percentage,
  fixed,
}

@JsonSerializable()
class CouponModel {
  final String code;
  final DiscountType discountType;
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscount;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;

  CouponModel({
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscount,
    required this.validFrom,
    required this.validUntil,
    this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
  });

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(validFrom) &&
        now.isBefore(validUntil) &&
        (usageLimit == null || usedCount < usageLimit!);
  }

  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0;

    if (minOrderAmount != null && orderAmount < minOrderAmount!) return 0;

    switch (discountType) {
      case DiscountType.percentage:
        final discount = orderAmount * (discountValue / 100);
        return maxDiscount != null ? discount.clamp(0, maxDiscount!) : discount;
      case DiscountType.fixed:
        return discountValue.clamp(0, orderAmount);
    }
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) =>
      _$CouponModelFromJson(json);

  Map<String, dynamic> toJson() => _$CouponModelToJson(this);

  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponModel.fromJson(data);
  }

  Map<String, dynamic> toFirestore() => toJson();

  CouponModel copyWith({
    String? code,
    DiscountType? discountType,
    double? discountValue,
    double? minOrderAmount,
    double? maxDiscount,
    DateTime? validFrom,
    DateTime? validUntil,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
  }) {
    return CouponModel(
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
