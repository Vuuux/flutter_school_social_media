import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:luanvanflutter/models/notification.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/task.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/views/home/notifications_page.dart';

//class xác thực đăng nhập
//Class dịch vụ từ database
class DatabaseServices {
  //uid toàn cục
  String? uid;

  DatabaseServices({this.uid});

  Future<DocumentSnapshot<Object?>> getUserByUserId() async {
    return await userReference.doc(uid).get();
  }

  getUserByUsername(String username) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where("username", isGreaterThanOrEqualTo: username)
        .get();
  }

  getUserByUserEmail(String email) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where("email", isEqualTo: email)
        .get();
  }

  //Lấy dữ liệu từ server truyền vào Collection Reference
  final CollectionReference userReference =
      FirebaseFirestore.instance.collection('users');
  final postReference = FirebaseFirestore.instance.collection('posts');
  final timelineReference = FirebaseFirestore.instance.collection('timeline');
  final forumReference = FirebaseFirestore.instance.collection('forums');
  final commentReference = FirebaseFirestore.instance.collection('comments');
  final forumCommentReference =
      FirebaseFirestore.instance.collection('forumComments');
  final chatReference = FirebaseFirestore.instance.collection('chats');
  final anonChatReference =
      FirebaseFirestore.instance.collection('anonChatRooms');
  final cloudReference = FirebaseFirestore.instance.collection('cloud');
  final feedReference = FirebaseFirestore.instance.collection('feeds');
  final followerReference = FirebaseFirestore.instance.collection('followers');
  final followingReference =
      FirebaseFirestore.instance.collection('followings');
  final gameReference = FirebaseFirestore.instance.collection('games');
  final triviaReference = FirebaseFirestore.instance.collection('trivias');
  final maleReference = FirebaseFirestore.instance.collection('male');
  final femaleReference = FirebaseFirestore.instance.collection('female');
  final qaGameReference = FirebaseFirestore.instance.collection('qaGames');
  final bondReference = FirebaseFirestore.instance.collection('bonds');
  final taskReference = FirebaseFirestore.instance.collection('tasks');

  Future uploadWhoData(
      {required String email,
      required String username,
      required String nickname,
      required bool isAnon,
      required String avatar,
      required String gender,
      required int score}) async {
    gender == 'Male'
        ? maleReference.doc(email).set({
            "username": username,
            "email": email,
            "nickname": nickname,
            "isAnon": isAnon,
            "avatar": avatar,
            "score": score,
          })
        : femaleReference.doc(email).set({
            "username": username,
            "email": email,
            "nickname": nickname,
            "isAnon": isAnon,
            "avatar": avatar,
            "score": score,
          });
  }

  Future<bool> uploadUserData({
    required String email,
    required String username,
    required String nickname,
    required String gender,
    required String major,
    required String bio,
    required String avatar,
    required bool isAnon,
    required String media,
    required String playlist,
    required String course,
    required String address,
  }) async {
    try {
      await userReference.doc(uid).set({
        'id': uid,
        "email": email,
        "username": username,
        "nickname": nickname,
        "isAnon": isAnon,
        "avatar": avatar,
        "gender": gender,
        "major": major,
        "bio": bio,
        "isAnon": isAnon,
        'anonBio': '',
        'anonInterest': '',
        'anonAvatar':
            "https://firebasestorage.googleapis.com/v0/b/god-project-ctu.appspot.com/o/Profile%20Pictures?alt=media&token=128aa6d4-42ec-40f5-b3db-3371e85ca126",
        'followers': {},
        'followings': {},
        'fame': 0,
        "media": '',
        "playlist": playlist,
        "course": course,
        "address": address,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserData>> getFollowers() async {
    List<UserData> ctuers = [];
    var snapshot = await followerReference.doc(uid).get();
    Map<String, DocumentReference> data =
        Map<String, DocumentReference>.from(snapshot['followers']);

    for (var value in data.values) {
      await value.get().then((val) {
        Map<String, dynamic> ctuer = val.data() as Map<String, dynamic>;
        ctuers.add(UserData.fromMap(ctuer));
      });
    }

    // for(int i = 0; i < values.length ; i++){
    //   ctuers.add(UserData.fromJson(values[i]));
    // }
    return ctuers;
  }

  Future<List<UserData>> getFollowings() async {
    List<UserData> ctuers = [];
    var snapshot = await followingReference.doc(uid).get();
    Map<String, DocumentReference> data =
        Map<String, DocumentReference>.from(snapshot['userFollowings']);

    for (var value in data.values) {
      await value.get().then((val) {
        Map<String, dynamic> ctuer = val.data() as Map<String, dynamic>;
        ctuers.add(UserData.fromMap(ctuer));
      });
    }

    // for(int i = 0; i < values.length ; i++){
    //   ctuers.add(UserData.fromJson(values[i]));
    // }
    return ctuers;
  }

  //TODO: EDIT ADD FOLLOWING METHOD
  Future addFollowing(String currentUserId, String targetId, dynamic data) {
    return followingReference
        .doc(targetId)
        .collection('userFollowings')
        .doc(currentUserId)
        .set(data);
  }

  Future addFollower(String currentUserId, String targetId, dynamic data) {
    return followerReference
        .doc(currentUserId)
        .collection('userFollowers')
        .doc(targetId)
        .set(data);
  }

  unfollowUser(String currentUserId, String targetId, dynamic data) async {
    followerReference
        .doc(targetId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  removeFollowing(String currentUserId, String targetId, dynamic data) async {
    followerReference
        .doc(currentUserId)
        .collection('userFollowings')
        .doc(targetId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  //trả về User bằng user username
  Future getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where("username", isGreaterThanOrEqualTo: username)
        .get();
  }

  //tương tự như trên nhưng bằng email
  Future getUserByEmail(String email) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
  }

  Future updateGame(String gameRoomID, String player1, String player2) async {
    return gameReference
        .doc(gameRoomID)
        .set({'player1': player1, 'player2': player2});
  }

  //cập nhật token cho user
  uploadToken(String fcmToken) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tokens')
        .doc(uid)
        .set({
      'token': fcmToken,
      'createAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
    });
  }

  //cập nhật đố vui
  Future updateTrivia({
    required String triviaRoomID,
    required String question,
    required String? answer1,
    required String? answer2,
  }) async {
    return triviaReference
        .doc(triviaRoomID)
        .collection('questionsDetail ')
        .doc(question)
        .set({
      'answer1': answer1,
      'answer2': answer2,
    });
  }

  Future createTriviaRoom(
    String triviaRoomID,
    String player1,
    String player2,
  ) async {
    return triviaReference.doc(triviaRoomID).set({
      'player1': player1,
      'player2': player2,
    });
  }

  Future acceptRequest(String ownerID, String userId) async {
    await feedReference
        .doc(ownerID)
        .collection('feedItems')
        .doc(userId)
        .update({
      'timestamp': DateTime.now(),
      'status': 'accepted',
    });
  }

  Future declineRequest(String ownerID, String userId) async {
    return await feedReference
        .doc(ownerID)
        .collection('feedItems')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future addLikeNotifications(
      String ownerId,
      String username,
      String userId,
      String avatar,
      String postId,
      String mediaUrl,
      Timestamp timestamp) async {
    return await feedReference
        .doc(ownerId)
        .collection('feedItems')
        .doc(postId)
        .set({
      "type": "like",
      "username": username,
      "userId": userId,
      "avatar": avatar,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": timestamp,
      "status": "unseen",
      "isAnon": false
    });
  }

  Future removeLikeNotifications(String ownerId, String postId) async {
    return await feedReference
        .doc(ownerId)
        .collection('feedItems')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  //lấy về request
  //check this
  getRequestStatus(String ownerId, String userId) async {
    return feedReference
        .doc(ownerId)
        .collection('feedItems')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'request')
        .snapshots();
  }

  Future uploadBondData(
      {required UserData userData,
      required bool myAnon,
      required UserData ctuer,
      required bool friendAnon,
      required String chatRoomID}) async {
    return bondReference.doc(chatRoomID).set({
      '${userData.username} Email': userData.email,
      '${userData.username} Anon': myAnon,
      '${ctuer.username} Email': ctuer.email,
      '${ctuer.username} Anon': friendAnon,
    });
  }

  getBond(String chatRoomId) async {
    return bondReference.doc(chatRoomId).snapshots();
  }

  Future uploadPhotos(Map<String, dynamic> photo) async {
    return await userReference
        .doc(uid)
        .collection('photos')
        .doc()
        .set(photo, SetOptions(merge: true));
  }

  getPhotos() {
    return userReference.doc(uid).collection('photos').snapshots();
  }

  Future changeAnonymousMode(bool isAnon) async {
    return await userReference.doc(uid).update({"isAnon": isAnon});
  }

  Future updateAnonData(String anonBio, String anonInterest, String anonAvatar,
      String nickname) async {
    return await userReference.doc(uid).update({
      'anonBio': anonBio,
      'anonInterest': anonInterest,
      'anonAvatar': anonAvatar,
      'nickname': nickname,
    });
  }

  Future<String> updateUserData(
    String email,
    String username,
    String nickname,
    String gender,
    String major,
    String bio,
    String avatar,
    bool isAnon,
    String media,
    String playlist,
    String course,
    String address,
  ) async {
    try {
      await userReference.doc(uid).update({
        "email": email,
        "username": username,
        "nickname": nickname,
        "gender": gender,
        "major": major,
        "bio": bio,
        "avatar": avatar,
        "isAnonymous": isAnon,
        'id': uid,
        'media': media,
        'course': course,
        'playlist': playlist,
        'address': address,
      });

      return "OK";
    } catch (err) {
      print(err);
      return err.toString();
    }
  }

  //tăng điểm danh tiếng
  Future increaseFame(
      int initialValue, String raterEmail, bool isAdditional) async {
    if (isAdditional) {
      await userReference
          .doc(uid)
          .collection('likes')
          .doc(raterEmail)
          .set({'like': raterEmail});
    }
    return await userReference.doc(uid).update({
      'fame': initialValue + 1,
    });
  }

  Future decreaseFame(
      int initialValue, String raterEmail, bool isAdditional) async {
    if (isAdditional) {
      await userReference
          .doc(uid)
          .collection('dislikes')
          .doc(raterEmail)
          .set({'dislike': raterEmail});

      return await userReference.doc(uid).update({
        'fame': initialValue - 1,
      });
    }
  }

  //--------------- POST ------------------//
  Future likePost(String likerId, String ownerId, String postId) async {
    await timelineReference
        // .doc(ownerId)
        // .collection('userPosts')
        .doc(postId)
        .update({'likes.$likerId': true});
  }

  Future unlikePost(String unlikerId, String ownerId, String postId) async {
    await timelineReference
        // .doc(ownerId)
        // .collection('userPosts')
        .doc(postId)
        .update({'likes.$unlikerId': false});
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTimelinePosts(
      String ownerId) async {
    //NEW WAY
    // return timelineReference
    //     .doc(ownerId)
    //     .collection('timelinePosts')
    //     .orderBy("timestamp", descending: true)
    //     .get();

    return timelineReference.orderBy("timestamp", descending: true).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostById(
      String ownerId, String postId) {
    return postReference
        .doc(ownerId)
        .collection('userPosts')
        .where('postId', isEqualTo: postId)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMyPosts() async {
    return postReference
        .doc(uid)
        .collection('userPosts')
        .orderBy("timestamp", descending: true)
        .get();
  }

  Future<Either<bool, FirebaseException>> deletePost(
      String userId, String postId) async {
    try {
      await postReference
          // .doc(userId)
          // .collection('userPosts')
          .doc(postId)
          .get()
          .then((value) {
        if (value.exists) {
          value.reference.delete();
        }
      });

      await deleteTimelinePost(postId);
      return const Left(true);
    } on FirebaseException catch (error) {
      return Right(error);
    }
  }

  Future<Either<bool, FirebaseException>> createPost(PostModel post) async {
    try {
      await postReference
          .doc(post.ownerId)
          .collection('userPosts')
          .doc(post.postId)
          .set({
        "postId": post.postId,
        "username": post.username,
        "timestamp": Timestamp.now(),
        "ownerId": post.ownerId,
        "description": post.description,
        "location": post.location,
        "likes": post.likes,
        "url": post.url
      });

      await addPostToTimeline(post);

      return const Left(true);
    } on FirebaseException catch (error) {
      return Right(error);
    }
  }

  Future addPostToTimeline(PostModel post) async {
    // await timelineReference
    //     //     .doc(post.ownerId)
    //     //     .collection('timelinePosts')
    //     //     .doc(post.postId)
    //     //     .set({
    //     //   "postId": post.postId,
    //     //   "username": post.username,
    //     //   "timestamp": Timestamp.now(),
    //     //   "ownerId": post.ownerId,
    //     //   "description": post.description,
    //     //   "location": post.location,
    //     //   "likes": post.likes,
    //     //   "url": post.url
    //     // });

    await timelineReference.doc(post.postId).set({
      "postId": post.postId,
      "username": post.username,
      "timestamp": Timestamp.now(),
      "ownerId": post.ownerId,
      "description": post.description,
      "location": post.location,
      "likes": post.likes,
      "url": post.url
    });
  }

  Future deleteTimelinePost(String postId) async {
    await timelineReference.doc(postId).get().then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  Future postComment(
      String postId,
      String userId,
      String commentId,
      String username,
      String comment,
      Timestamp timestamp,
      String avatar,
      String replyTo,
      String tagId) async {
    return await commentReference
        .doc(postId)
        .collection('userComments')
        .doc(commentId)
        .set({
      "userId": userId,
      "commentId": commentId,
      "username": username,
      "comment": comment,
      "timestamp": timestamp,
      "avatar": avatar,
      "replyTo": replyTo,
      "tagId": tagId,
      "likes": {},
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getComments(String postId) async {
    return await commentReference
        .doc(postId)
        .collection('userComments')
        .where('replyTo', isEqualTo: "")
        .orderBy('timestamp', descending: true)
        .get();
  }

  likeComment(String postId, String commentId) async {
    return await commentReference
        .doc(postId)
        .collection('userComments')
        .doc(commentId)
        .update({'likes.$uid': true});
  }

  unlikeComment(String postId, String commentId) async {
    return await commentReference
        .doc(postId)
        .collection('userComments')
        .doc(commentId)
        .update({'likes.$uid': false});
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getReplyComments(
      String postId, String commentId) async {
    return await commentReference
        .doc(postId)
        .collection('userComments')
        .where('replyTo', isEqualTo: commentId)
        .orderBy('timestamp', descending: true)
        .get();
  }

  Future addCommentNotifications(
      {required String postOwnerId,
      required String comment,
      required String postId,
      required String uid,
      required String username,
      required String avatar,
      required String url,
      required Timestamp timestamp}) async {
    return await feedReference.doc(postOwnerId).collection('feedItems').add({
      "type": "comment",
      "commentData": comment,
      "postId": postId,
      "userId": uid,
      "username": username,
      "avatar": avatar,
      "mediaUrl": url,
      "timestamp": timestamp,
      "status": "unseen",
      "isAnon": false
    });
  }

  List<UserData> _ctuerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserData(
          email:
              doc.data().toString().contains('email') ? doc.get('email') : '',
          avatar:
              doc.data().toString().contains('avatar') ? doc.get('avatar') : '',
          username: doc.data().toString().contains('username')
              ? doc.get('username')
              : '',
          bio: doc.data().toString().contains('bio') ? doc.get('bio') : '',
          gender:
              doc.data().toString().contains('gender') ? doc.get('gender') : '',
          major:
              doc.data().toString().contains('major') ? doc.get('major') : '',
          nickname: doc.data().toString().contains('nickname')
              ? doc.get('nickname')
              : '',
          isAnon: doc.data().toString().contains('isAnon')
              ? doc.get('isAnon')
              : false,
          anonBio: doc.data().toString().contains('anonBio')
              ? doc.get('anonBio')
              : '',
          anonInterest: doc.data().toString().contains('anonInterest')
              ? doc.get('anonInterest')
              : '',
          anonAvatar: doc.data().toString().contains('anonAvatar')
              ? doc.get('anonAvatar')
              : '',
          fame: doc.data().toString().contains('fame') ? doc.get('fame') : 0,
          media:
              doc.data().toString().contains('media') ? doc.get('media') : '',
          course:
              doc.data().toString().contains('course') ? doc.get('course') : '',
          playlist: doc.data().toString().contains('playlist')
              ? doc.get('playlist')
              : '',
          address: doc.data().toString().contains('address')
              ? doc.get('address')
              : '',
          id: doc.data().toString().contains('id') ? doc.get('id') : '');
      //   id: doc.get('id') ?? '',
      //   email: doc.get('email') ?? '',
      //   avatar: doc.get('avatar') ?? '',
      //   username: doc.get('username') ?? '',
      //   bio: doc.get('bio') ?? '',
      //   community: doc.get('community') ?? '',
      //   gender: doc.get('gender') ?? '',
      //   major: doc.get('major') ?? '',
      //   nickname: doc.get('nickname') ?? '',
      //   isAnon: doc.get('isAnon') ?? false,
      //   anonBio: doc.get('anonBio') ?? '',
      //   anonInterest: doc.get('anonInterest') ?? '',
      //   anonAvatar: doc.get('anonAvatar') ?? '',
      //   fame: doc.get('fame') ?? 0,
      //   media: doc.get('media') ?? '',
      //   course: doc.get('course') ?? '',
      //   playlist: doc.get('playlist') ?? '',
      //   address: doc.get('address') ?? '');
    }).toList();
  }

  //userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot doc) {
    return UserData(
        email: doc.data().toString().contains('email') ? doc.get('email') : '',
        avatar:
            doc.data().toString().contains('avatar') ? doc.get('avatar') : '',
        username: doc.data().toString().contains('username')
            ? doc.get('username')
            : '',
        bio: doc.data().toString().contains('bio') ? doc.get('bio') : '',
        gender:
            doc.data().toString().contains('gender') ? doc.get('gender') : '',
        major: doc.data().toString().contains('major') ? doc.get('major') : '',
        nickname: doc.data().toString().contains('nickname')
            ? doc.get('nickname')
            : '',
        isAnon: doc.data().toString().contains('isAnon')
            ? doc.get('isAnon')
            : false,
        anonBio:
            doc.data().toString().contains('anonBio') ? doc.get('anonBio') : '',
        anonInterest: doc.data().toString().contains('anonInterest')
            ? doc.get('anonInterest')
            : '',
        anonAvatar: doc.data().toString().contains('anonAvatar')
            ? doc.get('anonAvatar')
            : '',
        fame: doc.data().toString().contains('fame') ? doc.get('fame') : 0,
        media: doc.data().toString().contains('media') ? doc.get('media') : '',
        course:
            doc.data().toString().contains('course') ? doc.get('course') : '',
        playlist: doc.data().toString().contains('playlist')
            ? doc.get('playlist')
            : '',
        address:
            doc.data().toString().contains('address') ? doc.get('address') : '',
        id: doc.data().toString().contains('id') ? doc.get('id') : '');
  }

  //lấy danh sách ctuer stream
  Stream<List<UserData>> get ctuerList {
    return userReference.snapshots().map(_ctuerListFromSnapshot);
  }

  //check this
  Stream<UserData> get userData {
    return userReference.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  createChatRoom(String chatRoomId, Map<String, dynamic> data) async {
    chatReference.doc(chatRoomId).set(data).catchError((e) {
      print(e.toString());
    });
  }

  addConversationMessages(String chatRoomId, messageMap) async {
    chatReference
        .doc(chatRoomId)
        .collection('conversation')
        .doc(messageMap['timestamp'].toString())
        .set(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addAnonConversationMessages(String chatRoomID, messageMap) async {
    anonChatReference
        .doc(chatRoomID)
        .collection('chatDetail')
        .doc(messageMap['timestamp'].toString())
        .set(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getConversationMessages(
      String chatRoomId) {
    return chatReference
        .doc(chatRoomId)
        .collection('conversation')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      getSusConversationMessages(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection('susChatRoom')
        .doc(chatRoomId)
        .collection('chatDetail')
        .orderBy('time', descending: false)
        .snapshots();
  }

  deletePhotos(String uid, int index) async {
    return await userReference.doc().collection('photos').get().then((doc) {
      if (doc.docs[index].exists) {
        doc.docs[index].reference.delete();
      }
    });
  }

  //cập nhật câu trả lời của trò chơi

  Future<Future<QuerySnapshot<Map<String, dynamic>>>> getWho(
      String gender) async {
    return gender == "Female"
        ? maleReference.orderBy("score", descending: true).get()
        : femaleReference.orderBy("score", descending: true).get();
  }

  //check this below
  Future<Future<QuerySnapshot<Map<String, dynamic>>>> getReceiverToken(
      String email) async {
    return userReference.doc(uid).collection('tokens').get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatRooms(String userId) {
    return chatReference.where("users", arrayContains: userId).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllNotifications() async {
    return await feedReference
        .doc(uid)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .where('isAnon', isEqualTo: false)
        .limit(60)
        .get();

    // List<NotificationModel> notificationsItems = [];

    //return notificationsItems;
  }

  Future deleteAllNotifications() async {
    var snapshots = await feedReference.doc(uid).collection('feedItems').get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    // List<NotificationModel> notificationsItems = [];

    //return notificationsItems;
  }

  Future addNotifiCation(String ownerId, String userId, dynamic data) async {
    return await feedReference
        .doc(ownerId)
        .collection('feedItems')
        .doc(userId)
        .set(data);
  }

  Future updateNotification(String ownerId, String userId, dynamic data) async {
    return await feedReference
        .doc(ownerId)
        .collection('feedItems')
        .doc(userId)
        .update(data);
  }

  Future deleteNotification(String ownerId, String userId) async {
    return await feedReference
        .doc(ownerId)
        .collection('feedItems')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future getRequestNotification(String ownerId, String userId) async {
    return await feedReference
        .doc(ownerId)
        .collection('feedItems')
        .doc(userId)
        .get();
  }

  Future getSpecificNotifications(String ownerId, String uid) async {
    return await feedReference
        .doc(ownerId)
        .collection('feedItems')
        .doc(uid)
        .get();
  }

  Future getSpecificFollower(String ownerId, String uid) async {
    return await followerReference
        .doc(ownerId)
        .collection('userFollowers')
        .doc(uid)
        .get();
  }

  //ANONYMOUS MODE
  Future updateAnon(bool isAnon) async {
    return await userReference.doc(uid).update({"isAnon": isAnon});
  }

  //thêm blog data
  Future<void> addForumData(blogData, String description) async {
    return await forumReference
        .doc('$description')
        .set(blogData)
        .catchError((e) {
      print(e);
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getForums() async {
    return forumReference.orderBy('timestamp', descending: true).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getForumsByCategory(
      String category) async {
    return forumReference
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .get();
  }

  Future createForum(
    String forumId,
    String username,
    Timestamp timestamp,
    String ownerId,
    String title,
    String description,
    Map<String, dynamic> upVotes,
    Map<String, dynamic> downVotes,
    String category,
    String url,
  ) async {
    await forumReference.doc(forumId).set({
      "forumId": forumId,
      "username": username,
      "timestamp": Timestamp.now(),
      "ownerId": ownerId,
      "title": title,
      "description": description,
      "upVotes": upVotes,
      "downVotes": downVotes,
      "category": category,
      "mediaUrl": url
    });
  }

  Future updateVoteForum(
      String voterId, String forumId, bool upVote, bool downVote) async {
    await forumReference.doc(forumId).update({'upVotes.$voterId': upVote});
    await forumReference.doc(forumId).update({'downVotes.$voterId': downVote});
  }

  Future upVoteForum(String voterId, String forumId) async {
    await forumReference.doc(forumId).update({'upVotes.$voterId': true});
    await forumReference.doc(forumId).update({'downVotes.$voterId': false});
  }

  Future downVoteForum(String voterId, String forumId) async {
    await forumReference.doc(forumId).update({'upVotes.$voterId': false});
    await forumReference.doc(forumId).update({'downVotes.$voterId': true});
  }

  Future removeVoteNotifications(String ownerId, String forumId) async {
    return await feedReference
        .doc(ownerId)
        .collection('anonFeedItems')
        .doc(forumId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future addVoteNotifications(
      String ownerId,
      String nickname,
      String userId,
      String avatar,
      String forumId,
      String mediaUrl,
      Timestamp timestamp) async {
    return await feedReference
        .doc(ownerId)
        .collection('anonFeedItems')
        .doc(forumId)
        .set({
      "type": "vote",
      "username": nickname,
      "userId": userId,
      "avatar": avatar,
      "forumId": forumId,
      "mediaUrl": mediaUrl,
      "timestamp": timestamp,
      "status": "unseen",
      "isAnon": true
    });
  }

  Future postForumComment(
      String forumId,
      String userId,
      String commentId,
      String nickname,
      String comment,
      Timestamp timestamp,
      String avatar,
      String replyTo,
      String tagId) async {
    return await forumCommentReference
        .doc(forumId)
        .collection('userComments')
        .doc(commentId)
        .set({
      "userId": userId,
      "commentId": commentId,
      "nickname": nickname,
      "comment": comment,
      "timestamp": timestamp,
      "avatar": avatar,
      "replyTo": replyTo,
      "tagId": tagId,
      "likes": {},
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getForumReplyComments(
      String forumId, String commentId) async {
    return await forumCommentReference
        .doc(forumId)
        .collection('userComments')
        .where('replyTo', isEqualTo: commentId)
        .orderBy('timestamp', descending: true)
        .get();
  }

  Future addForumCommentNotifications(
      {required String postOwnerId,
      required String comment,
      required String forumId,
      required String uid,
      required String nickname,
      required String avatar,
      required String url,
      required Timestamp timestamp}) async {
    return await feedReference
        .doc(postOwnerId)
        .collection('anonFeedItems')
        .add({
      "type": "forum-comment",
      "commentData": comment,
      "forumId": forumId,
      "userId": uid,
      "username": nickname,
      "avatar": avatar,
      "mediaUrl": url,
      "timestamp": timestamp,
      "status": "unseen",
      "isAnon": true
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getForumComments(
      String forumId) async {
    return await forumCommentReference
        .doc(forumId)
        .collection('userComments')
        .where('replyTo', isEqualTo: "")
        .orderBy('timestamp', descending: true)
        .get();
  }

  likeForumComment(String forumId, String commentId) async {
    return await forumCommentReference
        .doc(forumId)
        .collection('userComments')
        .doc(commentId)
        .update({'likes.$uid': true});
  }

  unlikeForumComment(String forumId, String commentId) async {
    return await forumCommentReference
        .doc(forumId)
        .collection('userComments')
        .doc(commentId)
        .update({'likes.$uid': false});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAnonChatRooms(String userId) {
    return anonChatReference.where("users", arrayContains: userId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAnonConversationMessages(
      String chatRoomId) {
    return anonChatReference
        .doc(chatRoomId)
        .collection('conversation')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  createAnonChatRoom(String chatRoomId, String userId, String ctuerId,
      Map<String, dynamic> data) async {
    anonChatReference.doc(chatRoomId).set(data).catchError((e) {
      print(e.toString());
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllAnonNotifications() async {
    return await feedReference
        .doc(uid)
        .collection('anonFeedItems')
        .orderBy('timestamp', descending: true)
        .where('isAnon', isEqualTo: true)
        .limit(60)
        .get();
  }

  Future addQAGameRequestNotifiCation(
      String ownerId, String gameRoomId, dynamic data) async {
    return await feedReference
        .doc(ownerId)
        .collection('anonFeedItems')
        .doc(gameRoomId)
        .set(data);
  }

  Future createQAGameRoom(
      {required String gameRoomId,
      required String player1,
      required String player2}) async {
    return qaGameReference.doc(gameRoomId).set({
      'players': [player1, player2]
    });
  }

  Future updateMyQAAnswers(
      {required String uid,
      required String gameRoomId,
      required List<String> answers}) async {
    return qaGameReference
        .doc(gameRoomId)
        .collection('userAnswers')
        .doc(uid)
        .set({'answers': answers});
  }

  Future updateFriendQAAnswers(
      {required String ctuerId,
      required String gameRoomId,
      required List<String> answer}) async {
    return qaGameReference
        .doc(gameRoomId)
        .collection('userAnswers')
        .doc(ctuerId)
        .set({
      'answers': answer,
    });
  }

  Future uploadQAGameQuestions({
    required String gameRoomId,
    required List<String> questions,
  }) async {
    return qaGameReference
        .doc(gameRoomId)
        .collection('questions')
        .doc(gameRoomId)
        .set({
      'questions': questions,
    });
  }

  Future uploadAnswersQAGame({
    required String uid,
    required String gameRoomId,
    required List<String> myAnswers,
  }) async {
    return qaGameReference
        .doc(gameRoomId)
        .collection('userAnswers')
        .doc(uid)
        .set({
      'answers': myAnswers,
    });
  }

  Future uploadFriendAnswersQAGame({
    required String ctuerId,
    required String gameRoomId,
    required List<String> myAnswers,
  }) async {
    return await qaGameReference
        .doc(gameRoomId)
        .collection('userAnswers')
        .doc(ctuerId)
        .set({
      'answers': myAnswers,
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getMyQAGameResults(
      String uid, String gameRoomId) {
    return qaGameReference
        .doc(gameRoomId)
        .collection('userAnswers')
        .doc(uid)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getFriendCompResults(
      String ctuerId, String gameRoomId) {
    return qaGameReference
        .doc(gameRoomId)
        .collection('userAnswers')
        .doc(ctuerId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCompQuestions(
      String gameRoomId) {
    return qaGameReference.doc(gameRoomId).collection('questions').snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDocCompQuestions(
      String gameRoomId) async {
    return await qaGameReference.doc(gameRoomId).collection('questions').get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocMyCompatibilityAnswers(
      String uid, String gameRoomId) async {
    return await qaGameReference
        .doc(gameRoomId)
        .collection("userAnswers")
        .doc(uid)
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>>
      getDocFriendCompatibilityAnswers(
          String ctuerId, String gameRoomId) async {
    return await qaGameReference
        .doc(gameRoomId)
        .collection("userAnswers")
        .doc(ctuerId)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getQAGameRoomId(
      String ctuerId, String uid) async {
    return await qaGameReference.where('players', arrayContains: uid).get();
  }

  //TASK

  Future<Either<bool, FirebaseException>> createTask(TaskSchedule task) async {
    Map<String, dynamic> json = task.toJson();
    try {
      await taskReference
          .doc(uid)
          .collection("userTasks")
          .doc(task.taskId)
          .set(json);
      return const Left(true);
    } on FirebaseException catch (error) {
      return Right(error);
    }
  }

  Future<Either<QuerySnapshot, FirebaseException>> getTasks() async {
    try {
      var snapshot = await taskReference.doc(uid).collection("userTasks").get();
      return Left(snapshot);
    } on FirebaseException catch (error) {
      return Right(error);
    }
  }

  Future<Either<bool, FirebaseException>> deleteTask(String taskId) async {
    try {
      await taskReference
          .doc(uid)
          .collection("userTasks")
          .doc(taskId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      return const Left(true);
    } on FirebaseException catch (error) {
      return Right(error);
    }
  }

  Future<Either<bool, FirebaseException>> updateCompleteStatusTask(
      String taskId, bool isCompleted) async {
    try {
      await taskReference
          .doc(uid)
          .collection("userTasks")
          .doc(taskId)
          .update({'isCompleted': isCompleted});
      return const Left(true);
    } on FirebaseException catch (error) {
      return Right(error);
    }
  }
}
