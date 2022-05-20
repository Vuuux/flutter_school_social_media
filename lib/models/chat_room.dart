import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class ChatRoom {
  String chatRoomId;
  bool isGroup;
  String ownerId;
  String groupAvatar;
  String groupName;
  List<String> users;
  Timestamp timestamp;

  ChatRoom({
    required this.chatRoomId,
    required this.users,
    required this.timestamp,
    required this.isGroup,
    required this.ownerId,
    required this.groupAvatar,
    required this.groupName,
  });

  factory ChatRoom.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return ChatRoom(
        chatRoomId: snapshot["chatRoomId"],
        users: List<String>.from(snapshot["users"].map((user) => user)),
        timestamp: snapshot["timestamp"],
        isGroup: snapshot.data().toString().contains('isGroup')
            ? snapshot.get('isGroup')
            : false,
        ownerId: snapshot.data().toString().contains('ownerId')
            ? snapshot.get('ownerId')
            : "",
        groupAvatar: snapshot.data().toString().contains('groupAvatar')
            ? snapshot.get('groupAvatar')
            : "",
        groupName: snapshot.data().toString().contains('groupName')
            ? snapshot.get('groupName')
            : "");
  }

  factory ChatRoom.fromMap(Map<String, dynamic> snapshot) {
    return ChatRoom(
        chatRoomId: snapshot["chatRoomId"],
        users: List<String>.from(snapshot["users"].map((user) => user)),
        timestamp: snapshot["timestamp"],
        isGroup: snapshot.containsKey('isGroup') ? snapshot['isGroup'] : false,
        ownerId: snapshot.containsKey('ownerId') ? snapshot['ownerId'] : "",
        groupAvatar:
            snapshot.containsKey('groupAvatar') ? snapshot['groupAvatar'] : "",
        groupName:
            snapshot.containsKey('groupName') ? snapshot['groupName'] : "");
  }
}
