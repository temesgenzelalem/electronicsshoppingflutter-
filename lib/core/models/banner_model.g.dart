// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      linkType: $enumDecode(_$LinkTypeEnumMap, json['linkType']),
      linkId: json['linkId'] as String?,
      order: (json['order'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'linkType': _$LinkTypeEnumMap[instance.linkType]!,
      'linkId': instance.linkId,
      'order': instance.order,
      'isActive': instance.isActive,
      'title': instance.title,
      'subtitle': instance.subtitle,
    };

const _$LinkTypeEnumMap = {
  LinkType.product: 'product',
  LinkType.category: 'category',
  LinkType.url: 'url',
  LinkType.none: 'none',
};
