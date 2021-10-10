import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:luanvanflutter/models/user.dart';

//class dùng để lắng nghe sự thay đổi của data,
// giúp render lại màn hình hiển thị khi dữ liệu user thay đổi
class ProfileNotifier with ChangeNotifier {
  List<UserData>_profileList = []; //khoi tao danh sach profile
  late UserData _currentProfile;

  List<UserData> get profileList => _profileList;

  set profileList(List<UserData> value) {
    _profileList = value;
  }

  UserData get currentProfile => _currentProfile;

  set currentProfile(UserData value) {
    _currentProfile = value;
  } //profile hien tai


}