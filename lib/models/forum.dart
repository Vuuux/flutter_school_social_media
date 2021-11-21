import 'package:cloud_firestore/cloud_firestore.dart';

class ForumModel{
  final String forumId;
  final String ownerId;
  final String username;
  final String description;
  final String category;
  final Timestamp timestamp;
  final String url;
  final Map<String, dynamic> upVotes;
  final Map<String, dynamic> downVotes;

  ForumModel({
    required this.forumId,
    required this.ownerId,
    required this.username,
    required this.description,
    required this.category,
    required this.url,
    required this.upVotes,
    required this.downVotes,
    required this.timestamp
  });

  factory ForumModel.fromDocument(DocumentSnapshot doc) {
    return ForumModel(
      forumId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      description: doc['description'],
      category: doc['category'],
      url: doc['url'],
      upVotes: doc['upVotes'],
      downVotes: doc['downVotes'],
      timestamp: doc['timestamp'],
    );
  }

  int getUpvoteCount() {
    if (upVotes == null) {
      return 0;
    }

    int count = 0;
    for (var val in upVotes.values) {
      if (val == true) {
        count += 1;
      }
    }
    return count;
  }

  int getDownVoteCount() {
    if (downVotes == null) {
      return 0;
    }

    int count = 0;
    for (var val in downVotes.values) {
      if (val == true) {
        count += 1;
      }
    }
    return count;
  }


}