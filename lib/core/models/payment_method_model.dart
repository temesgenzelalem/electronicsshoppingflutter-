import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethodType {
  card,
  upi,
  netBanking,
  wallet,
  cod,
}

class PaymentMethodModel {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String provider; // Visa, Mastercard, Paytm, etc.
  final String last4; // Last 4 digits for cards
  final String? cardHolderName;
  final String? expiryMonth;
  final String? expiryYear;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.provider,
    required this.last4,
    this.cardHolderName,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentMethodModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PaymentMethodType.card,
      ),
      provider: data['provider'] ?? '',
      last4: data['last4'] ?? '',
      cardHolderName: data['cardHolderName'],
      expiryMonth: data['expiryMonth'],
      expiryYear: data['expiryYear'],
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'provider': provider,
      'last4': last4,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PaymentMethodModel copyWith({
    String? id,
    String? userId,
    PaymentMethodType? type,
    String? provider,
    String? last4,
    String? cardHolderName,
    String? expiryMonth,
    String? expiryYear,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      last4: last4 ?? this.last4,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName {
    switch (type) {
      case PaymentMethodType.card:
        return '$provider **** $last4';
      case PaymentMethodType.upi:
        return '$provider UPI';
      case PaymentMethodType.netBanking:
        return '$provider Net Banking';
      case PaymentMethodType.wallet:
        return '$provider Wallet';
      case PaymentMethodType.cod:
        return 'Cash on Delivery';
    }
  }

  bool get isExpired {
    if (expiryMonth == null || expiryYear == null) return false;
    final now = DateTime.now();
    final expiry = DateTime(int.parse(expiryYear!), int.parse(expiryMonth!));
    return expiry.isBefore(now);
  }

  @override
  String toString() {
    return 'PaymentMethodModel(id: $id, type: $type, provider: $provider, last4: $last4)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethodModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
