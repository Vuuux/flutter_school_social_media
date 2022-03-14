import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    User? firebaseUser = _auth.currentUser;
    return firebaseUser != null ? CurrentUser(uid: firebaseUser.uid) : null;
  }

  Future signInAnonymous() async {
    return await _auth.signInAnonymously();
  }

  //đăng nhập với email và password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "OK";
    } on FirebaseAuthException catch (e) {
      print("LOGIN ERROR WITH STATUS CODE:" + e.code);
      return e.code;
    }
  }

  //đăng ký với Email và Password
  Future<Either<bool, FirebaseAuthException>> signUp(
      String email,
      String password,
      String name,
      String nickname,
      String gender,
      String major,
      String bio,
      String avatar,
      bool isAnon,
      File media,
      String playlist,
      String course,
      String address) async {
    try {
      UserCredential credentialResult =
          await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      User? user = credentialResult.user;
      bool uploadResult = false;
      final Reference storageReference =
          FirebaseStorage.instance.ref().child("Profile Pictures");
      if (user != null) {
        await _auth.signInWithEmailAndPassword(
            email: email.trim(), password: password.trim());
        UploadTask uploadTask = storageReference.putFile(media);
        TaskSnapshot taskSnapshot = await uploadTask;
        var imgURL = (await taskSnapshot.ref.getDownloadURL()).toString();

        uploadResult = await DatabaseServices(uid: user.uid).uploadUserData(
            email.trim(),
            name,
            nickname,
            gender,
            major,
            bio,
            avatar,
            isAnon,
            imgURL,
            playlist,
            course,
            address);
      }
      return Left(uploadResult);
    } on FirebaseAuthException catch (e) {
      return Right(e);
    }
  }

  //xác thực mật khẩu
  Future<String> validatePassword(String password) async {
    var baseUser = _auth.currentUser;
    try {
      await baseUser!.reauthenticateWithCredential(EmailAuthProvider.credential(
          email: baseUser.email!, password: password));
      return 'OK';
    } on FirebaseAuthException catch (er) {
      print("ERROR CODE:" + er.code);
      return er.code;
    }
    // var authCredential = await _auth.signInWithEmailAndPassword(email: baseUser.email, password: password);
  }

  Future<String> updatePassword(String newPassword) async {
    var firebaseUser = _auth.currentUser;
    try {
      firebaseUser!.updatePassword(newPassword);
      return 'OK';
    } catch (e) {
      return e.toString();
    }
  }

  Future sendEmailResetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
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
