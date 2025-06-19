import 'package:json_annotation/json_annotation.dart';
part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final String uuid;
  @JsonKey(name: 'comment_text')
  final String commentText;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'creator_login')
  final String creatorLogin;
  @JsonKey(name: 'creator_avatar')
  final String? creatorAvatar;
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'is_liked')
  final bool isLiked;

  Comment({
    required this.uuid,
    required this.commentText,
    required this.createdAt,
    required this.creatorLogin,
    this.creatorAvatar,
    required this.likesCount,
    required this.isLiked,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
