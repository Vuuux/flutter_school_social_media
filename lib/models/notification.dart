import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String type;
  final String userId;
  final String username;
  final Timestamp timestamp;
  final String avatar;
  final String postId;
  final String mediaUrl;
  final String? comment;
  final String status;

  NotificationModel({
    required this.type,
    required this.userId,
    required this.username,
    required this.timestamp,
    required this.avatar,
    required this.postId,
    required this.mediaUrl,
    required this.status,
    this.comment = '',
  });

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    return NotificationModel(
        type: doc.data().toString().contains('type') ? doc.get('type') : '',
        userId: doc.data().toString().contains('userId') ? doc.get('userId') : '',
        username: doc.data().toString().contains('username') ? doc.get('username') : '',
        timestamp: doc.data().toString().contains('timestamp') ? doc.get('timestamp') : '',
        avatar: doc.data().toString().contains('avatar') ? doc.get('avatar') : '',
        postId: doc.data().toString().contains('postId') ? doc.get('postId') : '',
        mediaUrl: doc.data().toString().contains('mediaUrl') ? doc.get('mediaUrl') : '',
        status: doc.data().toString().contains('status') ? doc.get('status') : '',
        comment: doc.data().toString().contains('commentData') ? doc.get('commentData') : '',
    );
  }


}