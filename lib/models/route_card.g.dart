// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteCard _$RouteCardFromJson(Map<String, dynamic> json) => RouteCard(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  location: json['location'] as String,
  avgRating: (json['avg_rating'] as num).toDouble(),
  likesCount: (json['likes_count'] as num).toInt(),
  commentsCount: (json['comments_count'] as num).toInt(),
  routeTypeUuid: json['route_type_uuid'] as String?,
  isFavorite: json['is_favorite'] as bool,
  thumbnailUrl: json['thumbnail_url'] as String?,
  routeTypeName: json['route_type_name'] as String?,
);

Map<String, dynamic> _$RouteCardToJson(RouteCard instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'location': instance.location,
  'route_type_uuid': instance.routeTypeUuid,
  'avg_rating': instance.avgRating,
  'likes_count': instance.likesCount,
  'comments_count': instance.commentsCount,
  'is_favorite': instance.isFavorite,
  'thumbnail_url': instance.thumbnailUrl,
  'route_type_name': instance.routeTypeName,
};
