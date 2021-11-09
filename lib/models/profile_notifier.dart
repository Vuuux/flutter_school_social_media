import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:luanvanflutter/models/user.dart';

//class dùng để lắng nghe sự thay đổi của data,
// giúp render lại màn hình hiển thị khi dữ liệu user thay đổi
class ProfileNotifier with ChangeNotifier {
  late UserData _currentProfile;
  UserData get currentProfile => _currentProfile;
  set currentProfile(UserData value) {
    _currentProfile = value;
  } //profile hien tai


}