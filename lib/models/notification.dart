import 'package:cloud_firestore/cloud_firestore.dart';

enum FollowStatus { REQUESTING, ACCEPT, ACCEPTED, NONE }

class NotificationModel {
  final String notifId;
  final String type;
  final String userId;
  final String username;
  final Timestamp timestamp;
  final String avatar;
  final String? postId;
  final String? forumId;
  final String? gameRoomId;
  final String? mediaUrl;
  final String? comment;
  final FollowStatus status;
  final String? messageData;
  final String? triviaRoomId;
  final String? chatRoomId;
  final bool isAnon;
  final bool seenStatus;

  NotificationModel({
    required this.notifId,
    required this.type,
    required this.userId,
    required this.username,
    required this.timestamp,
    required this.avatar,
    this.postId,
    this.gameRoomId,
    this.forumId,
    this.mediaUrl,
    required this.status,
    required this.isAnon,
    this.comment,
    this.messageData,
    this.triviaRoomId,
    this.chatRoomId,
    this.seenStatus = false,
  });

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    return NotificationModel(
      notifId:
          doc.data().toString().contains('notifId') ? doc.get('notifId') : '',
      type: doc.data().toString().contains('type') ? doc.get('type') : '',
      userId: doc.data().toString().contains('userId') ? doc.get('userId') : '',
      username:
          doc.data().toString().contains('username') ? doc.get('username') : '',
      timestamp: doc.data().toString().contains('timestamp')
          ? doc.get('timestamp')
          : '',
      avatar: doc.data().toString().contains('avatar') ? doc.get('avatar') : '',
      postId: doc.data().toString().contains('postId') ? doc.get('postId') : '',
      forumId:
          doc.data().toString().contains('forumId') ? doc.get('forumId') : '',
      gameRoomId: doc.data().toString().contains('gameRoomId')
          ? doc.get('gameRoomId')
          : '',
      mediaUrl:
          doc.data().toString().contains('mediaUrl') ? doc.get('mediaUrl') : '',
      status: StatusExtension.getFollowStatus(
          doc.data().toString().contains('status') ? doc.get('status') : ''),
      isAnon:
          doc.data().toString().contains('isAnon') ? doc.get('isAnon') : false,
      comment: doc.data().toString().contains('commentData')
          ? doc.get('commentData')
          : '',
      messageData: doc.data().toString().contains('messageData')
          ? doc.get('messageData')
          : '',
      triviaRoomId: doc.data().toString().contains('triviaRoomId')
          ? doc.get('triviaRoomId')
          : '',
      chatRoomId: doc.data().toString().contains('chatRoomId')
          ? doc.get('chatRoomId')
          : '',
      seenStatus: doc.data().toString().contains('seenStatus')
          ? doc.get('seenStatus')
          : false,
    );
  }
}

extension StatusExtension on NotificationModel {
  static FollowStatus getFollowStatus(String status) {
    switch (status) {
      case "requesting":
        return FollowStatus.REQUESTING;
      case "accepted":
        return FollowStatus.ACCEPTED;
      case "accept":
        return FollowStatus.ACCEPT;
      case "declined":
        return FollowStatus.NONE;
      default:
        return FollowStatus.NONE;
    }
  }
}
