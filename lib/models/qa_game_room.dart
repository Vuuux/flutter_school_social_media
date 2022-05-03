import 'package:cloud_firestore/cloud_firestore.dart';

class QaGameRoom {
  String qaRoomId;
  List<String> players;
  Timestamp timestamp;

  QaGameRoom(
      {required this.qaRoomId, required this.players, required this.timestamp});

  factory QaGameRoom.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return QaGameRoom(
      qaRoomId: snapshot["qaRoomId"],
      players: snapshot["players"].map((user) => user).toList(),
      timestamp: snapshot["timestamp"],
    );
  }
}
