import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvanflutter/models/profile_notifier.dart';

//class User đăng nhập
class CurrentUser {
  final String uid;

  CurrentUser({required this.uid});
}

//dữ liệu User chi tiết
class UserData {
  late String email;
  late String name;
  late String nickname;
  late String gender;
  late String major;
  late String bio;
  late String avatar;
  late bool isAnon;
  late String anonBio;
  late String anonInterest;
  late String anonAvatar;
  late int fame;
  late String media;
  late String course;
  late String playlist;
  late String address; //chỗ ở

  UserData(
      {this.email = "",
      this.name = "",
      this.nickname = "",
      this.gender = "",
      this.major = "",
      this.bio = "",
      this.avatar = "",
      this.isAnon = false,
      this.anonBio = "",
      this.anonInterest = "",
      this.anonAvatar = "",
      this.fame = 0,
      this.media = "",
      this.course = "",
      this.playlist = "",
      this.address = ""
      });

  UserData.fromMap(Map<String, dynamic> data) {
    email = data['email'];
    name = data['name'];
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
  }

  getUserData(ProfileNotifier profileNotifier) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").get();
    List<UserData> _profileList = [];
    snapshot.docs.forEach((doc) {
      UserData data = UserData.fromMap(doc.data() as Map<String, dynamic>);
      _profileList.add(data);
    });

    profileNotifier.profileList = _profileList;
  }
}
