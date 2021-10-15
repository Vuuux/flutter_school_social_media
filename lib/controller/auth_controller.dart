import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/models/user.dart';

import 'controller.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  //tạo firebaseAuth để kết nối tới server

  //tạo User obj của FirebaseUser nếu chưa có
  CurrentUser? _getFirebaseCurrentUser(User? user) {
    return user != null ? CurrentUser(uid: user.uid) : null;
  }

  //trả về trạng thái có đăng nhập hay chưa
  Stream<CurrentUser?> get user {
    return _auth.authStateChanges().map(_getFirebaseCurrentUser);
  }

  //trả về user hiện tại
  Future getUser() async {
    var firebaseUser = _auth.currentUser;
    return CurrentUser(uid: firebaseUser!.uid);
  }


  //đăng nhập với email và password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return "OK";
    } on FirebaseAuthException catch (e) {
      print("LOGIN ERROR WITH STATUS CODE:" + e.code);
      return e.code;
    }
  }

  //đăng ký với Email và Password
  Future<String?> signUp(
      String email,
      String password,
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
      String address) async {
    try {
      UserCredential credentialResult = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = credentialResult.user;

      await DatabaseServices(uid: user!.uid).uploadUserData(
          email,
          name,
          nickname,
          gender,
          major,
          bio,
          avatar,
          isAnon,
          media,
          playlist,
          course,
          address);

      await DatabaseServices(uid: user.uid).uploadWhoData(
          email: email,
          name: name,
          nickname: nickname,
          isAnon: isAnon,
          avatar: avatar,
          gender: gender,
          score: 0);

      return "OK";
    } on FirebaseAuthException catch (e) {
      print("REGISTER ERROR:" + e.code);
      return e.code;
    }
  }

  //xác thực mật khẩu
  Future<String> validatePassword(String password) async {

    var baseUser = _auth.currentUser;
    try{
      await baseUser!.reauthenticateWithCredential(EmailAuthProvider.credential(
          email: baseUser.email!, password: password));
      return 'OK';
    }
    on FirebaseAuthException catch (er){
      print("ERROR CODE:" + er.code);
      return er.code;
    }
      // var authCredential = await _auth.signInWithEmailAndPassword(email: baseUser.email, password: password);
  }

  Future<String> updatePassword(String newPassword) async {
    var firebaseUser = _auth.currentUser;
      try{
        firebaseUser!.updatePassword(newPassword);
        return 'OK';
      }
      catch (e){
        return e.toString();
      }

  }

  Future updateProfilePicture(String avatar) async {
    //vars
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e);
      return null;
    }
  }
}