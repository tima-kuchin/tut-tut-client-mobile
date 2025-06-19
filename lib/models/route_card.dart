import 'package:json_annotation/json_annotation.dart';
part 'route_card.g.dart';

@JsonSerializable()
class RouteCard {
  final String uuid;
  final String name;
  final String location;
  @JsonKey(name: 'route_type_uuid')
  final String? routeTypeUuid;
  @JsonKey(name: 'avg_rating')
  final double avgRating;
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'route_type_name')
  final String? routeTypeName;

  RouteCard({
    required this.uuid,
    required this.name,
    required this.location,
    required this.avgRating,
    required this.likesCount,
    required this.commentsCount,
    required this.routeTypeUuid,
    required this.isFavorite,
    this.thumbnailUrl,
    this.routeTypeName,
  });

  factory RouteCard.fromJson(Map<String, dynamic> json) => _$RouteCardFromJson(json);
  Map<String, dynamic> toJson() => _$RouteCardToJson(this);
}
