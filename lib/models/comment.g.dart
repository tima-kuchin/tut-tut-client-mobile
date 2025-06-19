// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  uuid: json['uuid'] as String,
  commentText: json['comment_text'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  creatorLogin: json['creator_login'] as String,
  creatorAvatar: json['creator_avatar'] as String?,
  likesCount: (json['likes_count'] as num).toInt(),
  isLiked: json['is_liked'] as bool,
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'comment_text': instance.commentText,
  'created_at': instance.createdAt.toIso8601String(),
  'creator_login': instance.creatorLogin,
  'creator_avatar': instance.creatorAvatar,
  'likes_count': instance.likesCount,
  'is_liked': instance.isLiked,
};
