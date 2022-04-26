import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationItemModel {
  final String message;
  final String senderName;
  final String senderId;
  final String? triviaRoomId;
  final String type;
  final Timestamp timestamp;
  //local data
  final bool isSendByMe;

  ConversationItemModel(
      {required this.message,
      required this.senderName,
      required this.senderId,
      this.triviaRoomId,
      required this.type,
      required this.timestamp,
      this.isSendByMe = false});

  static ConversationItemModel fromJson(Map<String, dynamic> json) {
    return ConversationItemModel(
      triviaRoomId: json["triviaRoomId"] ?? "",
      message: json["message"] ?? "",
      senderName: json["sendBy"] ?? "",
      senderId: json["senderId"] ?? "",
      type: json["type"] ?? "",
      timestamp: json["timestamp"] ?? Timestamp.now(),
    );
  }

  static ConversationItemModel fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return ConversationItemModel(
      triviaRoomId: snapshot.data().toString().contains("triviaRoomId")
          ? snapshot.get("triviaRoomId")
          : "",
      message: snapshot["message"] ?? "",
      senderName: snapshot["sendBy"] ?? "",
      senderId: snapshot["senderId"] ?? "",
      type: snapshot["type"] ?? "",
      timestamp: snapshot["timestamp"] ?? Timestamp.now(),
    );
  }
}
