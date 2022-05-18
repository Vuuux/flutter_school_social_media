import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class ChatRoom {
  String chatRoomId;
  bool isGroup;
  List<String> users;
  Timestamp timestamp;

  ChatRoom(
      {required this.chatRoomId,
      required this.users,
      required this.timestamp,
      required this.isGroup});

  factory ChatRoom.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return ChatRoom(
        chatRoomId: snapshot["chatRoomId"],
        users: List<String>.from(snapshot["users"].map((user) => user)),
        timestamp: snapshot["timestamp"],
        isGroup: snapshot.data().toString().contains('isGroup')
            ? snapshot.get('isGroup')
            : false);
  }
}
