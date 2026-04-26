import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'banner_model.g.dart';

enum LinkType {
  product,
  category,
  url,
  none,
}

@JsonSerializable()
class BannerModel {
  final String id;
  final String imageUrl;
  final LinkType linkType;
  final String? linkId;
  final int order;
  final bool isActive;
  final String? title;
  final String? subtitle;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.linkType,
    this.linkId,
    required this.order,
    this.isActive = true,
    this.title,
    this.subtitle,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel.fromJson(data).copyWith(id: doc.id);
  }

  Map<String, dynamic> toFirestore() => toJson();

  BannerModel copyWith({
    String? id,
    String? imageUrl,
    LinkType? linkType,
    String? linkId,
    int? order,
    bool? isActive,
    String? title,
    String? subtitle,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      linkType: linkType ?? this.linkType,
      linkId: linkId ?? this.linkId,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
