import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus { PENDING, APPROVED, DELETED }

class ReportModel {
  final String postId;
  final String reason;
  final Timestamp timestamp;
  final List<String> media;
  final bool isVideo;
  final String ownerId;
  final String ownerName;
  final ReportStatus status;

  ReportModel({
    required this.postId,
    required this.reason,
    required this.timestamp,
    required this.media,
    required this.isVideo,
    required this.ownerId,
    required this.ownerName,
    required this.status,
  });

  static ReportModel fromDocumentSnapshot(DocumentSnapshot doc) {
    return ReportModel(
        postId: doc["postId"],
        ownerId: doc["ownerId"],
        ownerName: doc["ownerName"],
        reason: doc["reason"],
        timestamp: doc["timestamp"],
        media:
            doc['media'].map<String>((link) => link.toString()).toList() ?? [],
        isVideo: doc.data().toString().contains('isVideo')
            ? doc.get('isVideo')
            : false,
        status: ReportModel.getStatus(doc["status"].toString()));
  }

  static ReportStatus getStatus(String status) {
    switch (status) {
      case "approved":
        return ReportStatus.APPROVED;
      case "deleted":
        return ReportStatus.DELETED;
      default:
        return ReportStatus.PENDING;
    }
  }
}
