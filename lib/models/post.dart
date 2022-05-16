import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final Timestamp timestamp;
  final List<String> url;
  final Map<String, dynamic> likes;

  PostModel(
      {required this.postId,
      required this.ownerId,
      required this.username,
      required this.location,
      required this.description,
      required this.url,
      required this.likes,
      required this.timestamp});

  factory PostModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return PostModel(
      postId: doc['postId'] ?? "",
      ownerId: doc['ownerId'] ?? "",
      username: doc['username'] ?? "",
      location: doc['location'] ?? "",
      description: doc['description'] ?? "",
      url: doc['url'] ?? "",
      likes: doc['likes'] ?? "",
      timestamp: doc['timestamp'],
    );
  }

  int getLikeCount() {
    if (likes == null) {
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
