import 'package:flutter/material.dart';
import '../../models/comment.dart';
import '../../core/api/comments_service.dart';
import '../core/utils/utils.dart';

class CommentSection extends StatefulWidget {
  final String targetType;
  final String targetUuid;
  final String? currentUserUuid;
  final String? currentUserRole;

  const CommentSection({
    Key? key,
    required this.targetType,
    required this.targetUuid,
    this.currentUserUuid,
    this.currentUserRole,
  }) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _textCtrl = TextEditingController();
  List<Comment> _comments = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() { _loading = true; _error = null; });
    try {
      final comments = await CommentsService.fetchComments(widget.targetType, widget.targetUuid);
      setState(() => _comments = comments);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await CommentsService.createComment(widget.targetType, widget.targetUuid, text);
      _textCtrl.clear();
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _likeComment(String uuid, bool liked) async {
    setState(() => _loading = true);
    try {
      if (liked) {
        await CommentsService.unlikeComment(uuid);
      } else {
        await CommentsService.likeComment(uuid);
      }
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteComment(String uuid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Удалить комментарий?'),
        content: Text('Действие нельзя будет отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _loading = true);
    try {
      await CommentsService.deleteComment(uuid);
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Комментарии', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textCtrl,
                minLines: 1,
                maxLines: 3,
                enabled: !_loading,
                decoration: const InputDecoration(
                  hintText: 'Напишите комментарий...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _loading ? null : _sendComment,
              child: const Text('Отправить'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loading && _comments.isEmpty) ...[
          const Center(child: CircularProgressIndicator()),
        ] else if (_error != null) ...[
          Text('Ошибка: $_error', style: const TextStyle(color: Colors.red)),
        ] else if (_comments.isEmpty) ...[
          const Text('Пока нет комментариев.'),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final c = _comments[i];
              final canDelete = (widget.currentUserRole == 'admin' || widget.currentUserRole == 'moderator');
              return ListTile(
                leading: c.creatorAvatar != null
                    ? CircleAvatar(backgroundImage: NetworkImage(c.creatorAvatar!))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(c.creatorLogin, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.commentText),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(CoreUtils.formatDate(c.createdAt.toString()), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _loading
                              ? null
                              : () {
                            _likeComment(c.uuid, c.isLiked);
                          },
                          child: Row(
                            children: [
                              Icon(
                                c.isLiked ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red, size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text('${c.likesCount}'),
                            ],
                          ),
                        ),
                        if (canDelete) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _loading ? null : () => _deleteComment(c.uuid),
                            child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          ),
                        ],
                      ],
                    )
                  ],
                ),
              );
            },
          )
        ],
      ],
    );
  }
}
