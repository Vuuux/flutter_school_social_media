import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String postId;
  final String reason;
  final Timestamp timestamp;

  Report({required this.postId, required this.reason, required this.timestamp});

  static Report fromDocumentSnapshot(DocumentSnapshot doc) {
    return Report(
        postId: doc["postId"],
        reason: doc["reason"],
        timestamp: doc["timestamp"]);
  }
}
