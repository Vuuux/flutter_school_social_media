import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/profile_notifier.dart';

//class User đăng nhập
class CurrentUser {
  final String uid;
  CurrentUser({required this.uid});
}

//dữ liệu User chi tiết
class UserData {
  late final String id;
  late final String email;
  late final String username;
  late final String nickname;
  late final String gender;
  late final String major;
  late final String bio;
  late final String avatar;
  late final bool isAnon;
  late final String anonBio;
  late final String anonInterest;
  late final String anonAvatar;
  late final int fame;
  late final String media;
  late final String course;
  late final String playlist;
  late final String address; //chỗ ở

  UserData(
      {required this.id,
      required this.email,
      required this.username,
      required this.nickname,
      required this.gender,
      required this.major,
      required this.bio,
      required this.avatar,
      required this.isAnon,
      required this.anonBio,
      required this.anonInterest,
      required this.anonAvatar,
      required this.fame,
      required this.media,
      required this.course,
      required this.playlist,
      required this.address});

  UserData.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    email = data['email'];
    username = data['name'];
    nickname = data['nickname'];
    gender = data['gender'];
    major = data['major'];
    bio = data['bio'];
    avatar = data['pPic'];
    isAnon = data['isAnon'];
    anonBio = data['anonBio'];
    anonInterest = data['anonInterest'];
    anonAvatar = data['anonAvatar'];
    fame = data['fame'];
    playlist = data['playlist'];
    course = data['course'];
    media = data['media'];
    address = data['address'];
  }


  factory UserData.fromDocumentSnapshot(DocumentSnapshot? data) {
    return UserData(
        email: data!['email'],
        username: data['username'],
        nickname: data['nickname'],
        gender: data['gender'],
        major: data['major'],
        bio: data['bio'],
        avatar: data['avatar'],
        isAnon: data['isAnon'],
        anonBio: data['anonBio'],
        anonInterest: data['anonInterest'],
        anonAvatar: data['anonAvatar'],
        fame: data['fame'],
        playlist: data['playlist'],
        course: data['course'],
        media: data['media'],
        address: data['address'],
        id: data['id']);
  }

  getUserData(ProfileNotifier profileNotifier, String uid) async {
    DocumentSnapshot snapshot = await DatabaseServices(uid: uid).getUserByUserId();
    UserData data = UserData.fromDocumentSnapshot(snapshot);
    profileNotifier.currentProfile = data;
  }
}
