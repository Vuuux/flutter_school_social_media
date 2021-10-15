import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/views/home/notifications_page.dart';

//class xác thực đăng nhập
//Class dịch vụ từ database
class DatabaseServices {
  //uid toàn cục
  final String uid;

  DatabaseServices({required this.uid});

  getUserByUsername(String name) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where("name", isGreaterThanOrEqualTo: name)
        .get();
  }

  getUserByUserEmail(String email) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where("email", isEqualTo: email)
        .get();
  }

  //Lấy dữ liệu từ server truyền vào Collection Reference
  final CollectionReference ctuerRef =
      FirebaseFirestore.instance.collection('users');
  final chatRef = FirebaseFirestore.instance.collection('chatRooms');
  final anonChatRef = FirebaseFirestore.instance.collection('anonChatRooms');
  final cloudRef = FirebaseFirestore.instance.collection('cloud');
  final feedRef = FirebaseFirestore.instance.collection('feeds');
  final followerRef = FirebaseFirestore.instance.collection('followers');
  final followingRef = FirebaseFirestore.instance.collection('followings');
  final gameRef = FirebaseFirestore.instance.collection('games');
  final triviaRef = FirebaseFirestore.instance.collection('trivias');
  final maleRef = FirebaseFirestore.instance.collection('male');
  final femaleRef = FirebaseFirestore.instance.collection('female');
  final compRef = FirebaseFirestore.instance.collection('compability');
  final bondRef = FirebaseFirestore.instance.collection('bonds');
  final postRef = FirebaseFirestore.instance.collection('posts');
  final blogRef = FirebaseFirestore.instance.collection('blogs');

  Future<String> uploadWhoData(
      {required String email,
      required String name,
      required String nickname,
      required bool isAnon,
      required String avatar,
      required String gender,
      required int score}) async {
    try {
      gender == 'Male'
          ? maleRef.doc(email).set({
              "name": name,
              "email": email,
              "nickname": nickname,
              "isAnon": isAnon,
              "avatar": avatar,
              "score": score,
            })
          : femaleRef.doc(email).set({
              "name": name,
              "email": email,
              "nickname": nickname,
              "isAnon": isAnon,
              "avatar": avatar,
              "score": score,
            });

      return 'OK';
    } catch (err) {
      print(err);
      return err.toString();
    }
  }

  Future uploadUserData(
    String email,
    String name,
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
    return await ctuerRef.doc(uid).set({
      'id': uid,
      "email": email,
      "name": name,
      "nickname": nickname,
      "isAnon": isAnon,
      "avatar": avatar,
      "gender": gender,
      "major": major,
      "bio": bio,
      "isAnon": isAnon,
      'anonBio': '',
      'anonInterest': '',
      'anonAvatar': '',
      'followers': {},
      'followings': {},
      'fame': 0,
      "media": media,
      "playlist": playlist,
      "course": course,
      "address": address,
    });
  }

  Future addFollower(List<String> followerEmail, String ownerEmail) {
    return followerRef
        .doc(ownerEmail)
        .update({"list": FieldValue.arrayUnion(followerEmail)});
  }

  Future getFollowers(String email) {
    return followerRef.doc(email).get();
  }

  Future addFollowing(List<String> followingEmail, String ownerEmail) {
    return followingRef
        .doc(ownerEmail)
        .update({"list": FieldValue.arrayUnion(followingEmail)});
  }

  Future getFollowing(String email) {
    return followingRef.doc(email).collection('followers').get();
  }

  //trả về User bằng user name
  Future getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where("name", isGreaterThanOrEqualTo: username)
        .get();
  }

  //tương tự như trên nhưng bằng email
  Future getUserByEmail(String email) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
  }

  //thêm blog data
  Future<void> addBlogData(blogData, String description) async {
    return await blogRef.doc('$description').set(blogData).catchError((e) {
      print(e);
    });
  }

  //trả về blog data
  getBlogData() async {
    return await FirebaseFirestore.instance
        .collection('blogs')
        .orderBy('time', descending: true)
        .snapshots();
  }

  addForumMessages(String des, messageMap) async {
    blogRef
        .doc(des)
        .collection("blogsdetail")
        .doc(messageMap["time"].toString())
        .set(messageMap)
        .catchError((onError) {
      print(onError.toString());
    });
  }

  getForumMessages(String des) async {
    return blogRef
        .doc(des)
        .collection("blogsdetail")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future updateGame(String gameRoomID, String player1, String player2) async {
    return gameRef
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
    return triviaRef
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
    return triviaRef.doc(triviaRoomID).set({
      'player1': player1,
      'player2': player2,
    });
  }

  Future acceptRequest(String ownerID, String ownerName, String useravatar,
      String userID, String senderEmail) {
    return feedRef.doc(ownerID).collection('feedDetail').doc(senderEmail).set({
      'type': 'request',
      'ownerID': ownerID,
      'ownerName': ownerName,
      'timestamp': DateTime.now(),
      'userDp': useravatar,
      'userID': userID,
      'status': 'accepted',
      'senderEmail': senderEmail
    });
  }

  //lấy về request
  //check this
  getRequestStatus(String OwnerID, String ownerName, String useravatar,
      String userID, String senderEmail) async {
    return FirebaseFirestore.instance
        .collection('feeds')
        .doc(OwnerID)
        .collection('feedDetail')
        .where('senderEmail', isEqualTo: senderEmail)
        .where('type', isEqualTo: 'request')
        .snapshots();
  }

  Future uploadBondData(
      {required UserData userData,
      required bool myAnon,
      required Ctuer hmmie,
      required bool friendAnon,
      required String chatRoomID}) async {
    return bondRef.doc(chatRoomID).set({
      '${userData.name} Email': userData.email,
      '${userData.name} Anon': myAnon,
      '${hmmie.name} Email': hmmie.email,
      '${hmmie.name} Anon': friendAnon,
    });
  }

  getBond(String chatRoomId) async {
    return bondRef.doc(chatRoomId).snapshots();
  }

  Future uploadPhotos(String photo) async {
    return await ctuerRef
        .doc(uid)
        .collection('photos')
        .doc()
        .set({'photo': photo});
  }

  getPhotos() {
    return ctuerRef.doc(uid).collection('photos').snapshots();
  }

  Future updateAnon(bool isAnon) async {
    return await ctuerRef.doc(uid).update({"isAnon": isAnon});
  }

  Future updateAnonData(String anonBio, String anonInterest, String anonAvatar,
      String nickname) async {
    return await ctuerRef.doc(uid).update({
      'anonBio': anonBio,
      'anonInterest': anonInterest,
      'anonAvatar': anonAvatar,
      'nickname': nickname,
    });
  }

  Future<String> updateUserData(
    String email,
    String name,
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
      await ctuerRef.doc(uid).update({
        "email": email,
        "name": name,
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
  //check this
  Future increaseFame(
      int initialValue, String raterEmail, bool isAdditional) async {
    if (isAdditional) {
      await ctuerRef
          .doc(uid)
          .collection('likes')
          .doc(raterEmail)
          .set({'like': raterEmail});
    }
    return await ctuerRef.doc(uid).update({
      'fame': initialValue + 1,
    });
  }

  Future decreaseFame(
      int initialValue, String raterEmail, bool isAdditional) async {
    if (isAdditional) {
      await ctuerRef
          .doc(uid)
          .collection('dislikes')
          .doc(raterEmail)
          .set({'dislike': raterEmail});

      return await ctuerRef.doc(uid).update({
        'fame': initialValue - 1,
      });
    }
  }

  Future likePost(int initialValue, String postId, String userEmail) async {
    await postRef.doc(postId).collection('likes').doc(userEmail).set({
      'liked': userEmail,
    });

    return await postRef.doc(postId).update({'likes': initialValue + 1});
  }

  Future unlikePost(int initialValue, String postId, String userEmail) async {
    await postRef.doc(postId).collection('likes').doc(userEmail).delete();

    return await postRef.doc(postId).update({
      'likes': initialValue - 1,
    });
  }

  List<Ctuer> _ctuerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Ctuer(
          // id: doc.data().toString().contains('id') ? doc.get('id') : '',
          // email: doc.data().toString().contains('email') ? doc.get('email') : '',
          // avatar: doc.data().toString().contains('avatar') ? doc.get('avatar') : '',
          // name: doc.data().toString().contains('name') ? doc.get('name') : '',
          // bio: doc.data().toString().contains('bio') ? doc.get('bio') : '',
          // community: doc.data().toString().contains('community') ? doc.get('community') : '',
          // gender: doc.data().toString().contains('gender') ? doc.get('gender') : '',
          // major: doc.data().toString().contains('major') ? doc.get('major') : '',
          // nickname: doc.data().toString().contains('nickname') ? doc.get('nickname') : '',
          // isAnon: doc.data().toString().contains('isAnon') ? doc.get('isAnon') : false,
          // anonBio: doc.data().toString().contains('anonBio') ? doc.get('anonBio') : '',
          // anonInterest: doc.data().toString().contains('anonInterest') ? doc.get('anonInterest') : '',
          // anonAvatar: doc.data().toString().contains('anonAvatar') ? doc.get('anonAvatar') : '',
          // fame: doc.data().toString().contains('fame') ? doc.get('fame') : 0,
          // media: doc.data().toString().contains('media') ? doc.get('media') : '',
          // course: doc.data().toString().contains('course') ? doc.get('course') : '',
          // playlist: doc.data().toString().contains('playlist') ? doc.get('playlist') : '',
          // address: doc.data().toString().contains('address') ? doc.get('address') : '');
          id: doc.get('id') ?? '',
          email: doc.get('email') ?? '',
          avatar: doc.get('avatar') ?? '',
          name: doc.get('name') ?? '',
          bio: doc.get('bio') ?? '',
          community: doc.get('community') ?? '',
          gender: doc.get('gender') ?? '',
          major: doc.get('major') ?? '',
          nickname: doc.get('nickname') ?? '',
          isAnon: doc.get('isAnon') ?? false,
          anonBio: doc.get('anonBio') ?? '',
          anonInterest: doc.get('anonInterest') ?? '',
          anonAvatar: doc.get('anonAvatar') ?? '',
          fame: doc.get('fame') ?? 0,
          media: doc.get('media') ?? '',
          course: doc.get('course') ?? '',
          playlist: doc.get('playlist') ?? '',
          address: doc.get('address') ?? '');
    }).toList();
  }

  //userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        // email: doc.data().toString().contains('email') ? doc.get('email') : '',
        // avatar: doc.data().toString().contains('avatar') ? doc.get('avatar') : '',
        // name: doc.data().toString().contains('name') ? doc.get('name') : '',
        // bio: doc.data().toString().contains('bio') ? doc.get('bio') : '',
        // gender: doc.data().toString().contains('gender') ? doc.get('gender') : '',
        // major: doc.data().toString().contains('major') ? doc.get('major') : '',
        // nickname: doc.data().toString().contains('nickname') ? doc.get('nickname') : '',
        // isAnon: doc.data().toString().contains('isAnon') ? doc.get('isAnon') : false,
        // anonBio: doc.data().toString().contains('anonBio') ? doc.get('anonBio') : '',
        // anonInterest: doc.data().toString().contains('anonInterest') ? doc.get('anonInterest') : '',
        // anonAvatar: doc.data().toString().contains('anonAvatar') ? doc.get('anonAvatar') : '',
        // fame: doc.data().toString().contains('fame') ? doc.get('fame') : 0,
        // media: doc.data().toString().contains('media') ? doc.get('media') : '',
        // course: doc.data().toString().contains('course') ? doc.get('course') : '',
        // playlist: doc.data().toString().contains('playlist') ? doc.get('playlist') : '',
        // address: doc.data().toString().contains('address') ? doc.get('address') : '');
        email: snapshot.get('email'),
        name: snapshot.get('name'),
        nickname: snapshot.get('nickname'),
        gender: snapshot.get('gender'),
        major: snapshot.get('major'),
        bio: snapshot.get('bio'),
        avatar: snapshot.get('avatar'),
        isAnon: snapshot.get('isAnon'),
        anonBio: snapshot.get('anonBio') ?? '',
        anonInterest: snapshot.get('anonInterest') ?? '',
        anonAvatar: snapshot.get('anonAvatar') ?? '',
        fame: snapshot.get('fame') ?? 0,
        media: snapshot.get('media') ?? '',
        course: snapshot.get('course') ?? '',
        playlist: snapshot.get('playlist') ?? '',
        address: snapshot.get('address') ?? '');
  }

  //lấy danh sách ctuer stream
  Stream<List<Ctuer>> get ctuerList {
    return ctuerRef.snapshots().map(_ctuerListFromSnapshot);
  }

  //check this
  Stream<UserData> get userData {
    return ctuerRef.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  createChatRoom(String chatRoomID, dynamic chatRoomMap) async {
    chatRef.doc(chatRoomID).set(chatRoomMap).catchError((e) {
      print(e.toString());
    });
  }

  createAnonChatRoom(String chatRoomID, dynamic chatRoomMap) async {
    return anonChatRef.doc(chatRoomID).set(chatRoomMap).catchError((e) {
      print(e.toString());
    });
  }

  createSusChatRoom(String chatRoomID, dynamic chatRoomMap) async {
    FirebaseFirestore.instance
        .collection('susChatroom')
        .doc(chatRoomID)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addConversationMessages(String chatRoomID, messageMap) async {
    chatRef
        .doc(chatRoomID)
        .collection('chatDetail')
        .doc(messageMap['time'].toString())
        .set(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addAnonConversationMessages(String chatRoomID, messageMap) async {
    anonChatRef
        .doc(chatRoomID)
        .collection('chatDetail')
        .doc(messageMap['time'].toString())
        .set(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getConversationMessages(
      String chatRoomId) async {
    return chatRef
        .doc(chatRoomId)
        .collection('chatDetail')
        .orderBy('time', descending: false)
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

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      getAnonConversationMessages(String chatRoomId) async {
    return anonChatRef
        .doc(chatRoomId)
        .collection('chatDetail')
        .orderBy('time', descending: false)
        .snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getPosts() async {
    return postRef.orderBy("timestamp", descending: true).snapshots();
  }

  //cập nhật câu trả lời của trò chơi
  Future updateCompAnswers(
      {required UserData userData,
      required Ctuer hmmie,
      required String compRoomId,
      required List<String> answers}) async {
    return compRef
        .doc(compRoomId)
        .collection('${userData.name} answers')
        .doc(userData.name)
        .set({'$userData.name answers': answers});
  }

  //cập nhật câu trả lời của Hmmie
  Future updateFriendCompAnswers(
      {required UserData userData,
      required Ctuer hmmie,
      required String compRoomId,
      required List<String> answer}) async {
    return compRef
        .doc(compRoomId)
        .collection('$hmmie.name answers')
        .doc(hmmie.name)
        .set({
      '$hmmie.name answers': answer,
    });
  }

  Future uploadCompQuestions({
    required UserData userData,
    required Ctuer hmmie,
    required String compRoomId,
    required List<String> questions,
  }) async {
    return compRef.doc(compRoomId).collection('questions').doc(compRoomId).set({
      'questions': questions,
    });
  }

  Future uploadCompAnswers({
    required UserData userData,
    required Ctuer hmmie,
    required String compRoomId,
    required List<String> myAnswers,
  }) async {
    return compRef
        .doc(compRoomId)
        .collection('${userData.name} answers')
        .doc(userData.name)
        .set({
      '${userData.name} answers': myAnswers,
    });
  }

  Future uploadFriendCompAnswers({
    required UserData userData,
    required Ctuer hmmie,
    required String compRoomId,
    required List<String> myAnswers,
  }) async {
    return compRef
        .doc(compRoomId)
        .collection('${hmmie.name} answers')
        .doc(hmmie.name)
        .set({
      '${hmmie.name} answers': myAnswers,
    });
  }

  Future createCompRoom(
      {required String compRoomId,
      required String player1,
      required String player2}) async {
    return compRef.doc(compRoomId).set({
      'player1': player1,
      'player2': player2,
    });
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getMyCompResults(
      Ctuer hmmie, UserData userData, String compRoomId) async {
    return await compRef
        .doc(compRoomId)
        .collection('${userData.name} answers')
        .snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getFriendCompResults(
      Ctuer hmmie, UserData userData, String compRoomId) async {
    return await compRef
        .doc(compRoomId)
        .collection('${hmmie.name} answers')
        .snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getCompQuestions(
      Ctuer hmmie, UserData userData, String compRoomId) async {
    return await compRef.doc(compRoomId).collection('questions').snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDocCompQuestions(
      Ctuer hmmie, UserData userData, String compRoomId) async {
    return await compRef.doc(compRoomId).collection('questions').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDocMyCompatibilityAnswers(
      Ctuer hmmie, UserData userData, String compRoomId) async {
    return await compRef
        .doc(compRoomId)
        .collection("${userData.name} answers")
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDocFriendCompatibilityAnswers(
      Ctuer hmmie, UserData userData, String compRoomId) async {
    return await compRef
        .doc(compRoomId)
        .collection("${hmmie.name} answers")
        .get();
  }

  Future<Future<QuerySnapshot<Map<String, dynamic>>>> getWho(
      String gender) async {
    return gender == "Female"
        ? maleRef.orderBy("score", descending: true).get()
        : femaleRef.orderBy("score", descending: true).get();
  }

  //check this below
  Future<Future<QuerySnapshot<Map<String, dynamic>>>> getReceiverToken(
      String email) async {
    return ctuerRef.doc(uid).collection('tokens').get();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getChatRooms(
      String userName) async {
    return chatRef.where("users", arrayContains: userName).snapshots();
  }

  Future<Future<QuerySnapshot<Map<String, dynamic>>>> getNoOfChatRooms(
      String email) async {
    return chatRef.where("users", arrayContains: email).get();
  }

  Future<Future<QuerySnapshot<Map<String, dynamic>>>> getNoOfAnonChatRooms(
      String email) async {
    return anonChatRef.where("users", arrayContains: email).get();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getAnonymousChatRooms(
      String userName) async {
    return anonChatRef.where("users", arrayContains: userName).snapshots();
  }

  Future<List<NotificationsItem>> getNotifications(String email) async {
    QuerySnapshot querySnapshot = await feedRef
        .doc(email)
        .collection('feed')
        .orderBy('timestamp', descending: true)
        .limit(60)
        .get();

    List<NotificationsItem> notificationsItems = [];

    for (var document in querySnapshot.docs) {
      notificationsItems.add(NotificationsItem.fromDocument(document));
    }
    return notificationsItems;
  }

  Future createPost (
    String postId,
    String name,
    Timestamp timestamp,
    String email,
    String description,
    String location,
    Map<String, dynamic> likes,
    String url,
  ) async {
    await postRef.doc(postId).set({
      "postId": postId,
      "name": name,
      "timestamp": Timestamp.now(),
      "email": email,
      "description": description,
      "location": location,
      "likes": likes,
      "url": url
    });
  }
}
