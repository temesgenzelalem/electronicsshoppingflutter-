import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String? title;
  final String comment;
  final List<String> images;
  final List<String> likes; // user IDs who liked this review
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerifiedPurchase;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.title,
    required this.comment,
    required this.images,
    required this.likes,
    required this.createdAt,
    this.updatedAt,
    this.isVerifiedPurchase = false,
  });

  bool get isLikedByUser => likes.contains(userId);

  int get likesCount => likes.length;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromJson(data).copyWith(id: doc.id);
  }

  Map<String, dynamic> toFirestore() => toJson();

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? title,
    String? comment,
    List<String>? images,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerifiedPurchase,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
    );
  }
}
