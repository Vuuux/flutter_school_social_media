import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_tree/comment_tree.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';

class CommentModel {
  String commentId;
  String username;
  String userId;
  String avatar;
  String comment;
  String replyTo;
  String tagId;
  Timestamp timestamp;
  Map<String, dynamic> likes;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.comment,
    required this.replyTo,
    required this.tagId,
    required this.timestamp,
    required this.likes,
  });

  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    return CommentModel(
        commentId: doc['commentId'],
        userId: doc['userId'],
        username: doc.data().toString().contains('username')
            ? doc.get('username')
            : doc.data().toString().contains('nickname')
                ? doc.get('nickname')
                : '',
        avatar: doc['avatar'],
        comment: doc['comment'],
        replyTo: doc['replyTo'],
        timestamp: doc['timestamp'],
        likes: doc['likes'],
        tagId: doc['tagId']);
  }

  int getLikeCount() {
    if (likes == {}) {
      return 0;
    }
    int count = 0;
    for (var val in likes.values) {
      if (val == true) {
        count += 1;
      }
    }
    return count;
  }
}
