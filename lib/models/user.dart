import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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
  late final String role;

  UserData({
    this.id = "",
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
    this.address = "",
    this.role = "user",
  });

  UserData.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    email = data['email'];
    username = data['username'];
    nickname = data['nickname'];
    gender = data['gender'];
    major = data['major'];
    bio = data['bio'];
    avatar = data['avatar'];
    isAnon = data['isAnon'];
    anonBio = data['anonBio'];
    anonInterest = data['anonInterest'];
    anonAvatar = data['anonAvatar'];
    likes = data['likes'].length > 0
        ? List<SubUserData>.from(
            data['likes'].map((x) => SubUserData.fromJson(x)))
        : [];
    playlist = data['playlist'];
    course = data['course'];
    media = data['media'];
    address = data['address'];
    role = data['role'];
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
        likes: data['likes'].length > 0
            ? List<SubUserData>.from(
                data['likes'].map((x) => SubUserData.fromJson(x)).toList())
            : [],
        playlist: data['playlist'],
        course: data['course'],
        media: data['media'],
        address: data['address'],
        id: data['id'],
        role: data['role']);
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

  static Map<String, dynamic> toJson(UserData data) {
    Map<String, dynamic> result = {};
    result['id'] = data.id;
    result['email'] = data.email;
    result['username'] = data.username;
    result['nickname'] = data.nickname;
    result['gender'] = data.gender;
    result['major'] = data.major;
    result['bio'] = data.bio;
    result['avatar'] = data.avatar;
    result['isAnon'] = data.isAnon;
    result['anonBio'] = data.anonBio;
    result['anonInterest'] = data.anonInterest;
    result['anonAvatar'] = data.anonAvatar;
    result['likes'] = data.likes.isNotEmpty
        ? data.likes.map((like) => SubUserData.toJson(like)).toList()
        : [];
    result['playlist'] = data.playlist;
    result['course'] = data.course;
    result['media'] = data.media;
    result['address'] = data.address;
    result['role'] = data.role;
    return result;
  }
}

class SubUserData {
  late String id;
  late String username;
  late String avatar;

  SubUserData({this.id = "", this.username = "", this.avatar = ""});

  static SubUserData fromDocumentSnapshot(DocumentSnapshot json) {
    return SubUserData(
        id: json["id"] ?? "",
        username: json["username"] ?? "",
        avatar: json["avatar"] ?? "");
  }

  static SubUserData fromJson(Map<String, dynamic> json) {
    return SubUserData(
      id: json["id"] ?? "",
      username: json["username"] ?? "",
      avatar: json["avatar"] ?? "",
    );
  }

  static Map<String, dynamic> toJson(SubUserData data) {
    Map<String, dynamic> json = {};
    json["id"] = data.id;
    json["username"] = data.username;
    json["avatar"] = data.avatar;
    return json;
  }
}
