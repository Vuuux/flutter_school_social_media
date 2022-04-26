import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/profile_notifier.dart';

//class User đăng nhập
class CurrentUserId {
  final String uid;
  CurrentUserId({required this.uid});
}

//dữ liệu User chi tiết
class UserData extends Equatable {
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
  late final List<SubUserData> likes;
  late final String media;
  late final String course;
  late final String playlist;
  late final String address; //chỗ ở

  UserData(
      {this.id = "",
      this.username = "",
      this.nickname = "",
      this.email = "",
      this.bio = "",
      this.gender = "",
      this.major = "",
      this.avatar = "",
      this.isAnon = false,
      this.anonBio = "",
      this.anonInterest = "",
      this.anonAvatar = "",
      this.likes = const [],
      this.media = "",
      this.course = "",
      this.playlist = "",
      this.address = ""});

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
    likes = List<SubUserData>.from(
        data['likes'].map((x) => SubUserData.fromJson(x)));
    playlist = data['playlist'];
    course = data['course'];
    media = data['media'];
    address = data['address'];
  }

  factory UserData.fromDocumentSnapshot(DocumentSnapshot data) {
    return UserData(
        email: data['email'],
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
        likes: List<SubUserData>.from(
            data['likes'].map((x) => SubUserData.fromJson(x))),
        playlist: data['playlist'],
        course: data['course'],
        media: data['media'],
        address: data['address'],
        id: data['id']);
  }

  getUserData(ProfileNotifier profileNotifier, String uid) async {
    DocumentSnapshot snapshot =
        await DatabaseServices(uid: uid).getUserByUserId();
    UserData data = UserData.fromDocumentSnapshot(snapshot);
    profileNotifier.currentProfile = data;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        nickname,
        gender,
        major,
        bio,
        avatar,
        isAnon,
        anonBio,
        anonInterest,
        anonAvatar,
        likes,
        media,
        course,
        playlist,
        address
      ];
}

class SubUserData {
  late String id;
  late String username;
  late String avatar;
  late String bio;

  SubUserData(
      {this.id = "", this.username = "", this.avatar = "", this.bio = ""});

  static SubUserData fromJson(Map<String, dynamic> json) {
    return SubUserData(
        id: json["id"] ?? "",
        username: json["username"] ?? "",
        avatar: json["avatar"] ?? "",
        bio: json["bio"] ?? "");
  }

  static Map<String, dynamic> toJson(SubUserData data) {
    Map<String, dynamic> json = {};
    json["id"] = data.id;
    json["username"] = data.username;
    json["avatar"] = data.avatar;
    json["bio"] = data.bio;
    return json;
  }
}
