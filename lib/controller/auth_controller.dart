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
  CurrentUserId? _getFirebaseCurrentUser(User? user) {
    return user != null ? CurrentUserId(uid: user.uid) : null;
  }

  //trả về trạng thái có đăng nhập hay chưa
  Stream<CurrentUserId?> get user {
    return _auth.authStateChanges().map(_getFirebaseCurrentUser);
  }

  //trả về user hiện tại
  Future getUser() async {
    User? firebaseUser = _auth.currentUser;
    return firebaseUser != null ? CurrentUserId(uid: firebaseUser.uid) : null;
  }

  Future<bool> deleteUser() async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.delete();
      return true;
    }
    return false;
  }

  Future signInAnonymous() async {
    return await _auth.signInAnonymously();
  }

  //đăng nhập với email và password
  Future<Either<UserCredential, FirebaseAuthException>> signIn(
      String email, String password) async {
    try {
      var response = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return Left(response);
    } on FirebaseAuthException catch (error) {
      print("LOGIN ERROR WITH STATUS CODE:" + error.code);
      return Right(error);
    }
  }

  Future<Either<bool, FirebaseAuthException>> sendVerificationEmail() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        currentUser.sendEmailVerification();
        return const Left(true);
      }
      return const Left(false);
    } on FirebaseAuthException catch (error) {
      return Right(error);
    }
  }

  bool isEmailVerified() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser.emailVerified;
    }
    return false;
  }

  //đăng ký với Email và Password
  Future<Either<bool, FirebaseAuthException>> signUp(
      {required String email,
      required String password,
      required String name,
      required String nickname,
      required String gender,
      required String major,
      required String bio,
      required bool isAnon,
      required File pickedAvatar,
      required String playlist,
      required String course,
      required String address}) async {
    try {
      UserCredential credentialResult =
          await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      User? user = credentialResult.user;
      String uid = user!.uid;
      bool uploadResult = false;
      final Reference storageReference =
          FirebaseStorage.instance.ref().child("profile");
      if (user != null) {
        await _auth.signInWithEmailAndPassword(
            email: email.trim(), password: password.trim());
        UploadTask uploadTask =
            storageReference.child("profile_$uid").putFile(pickedAvatar);
        TaskSnapshot taskSnapshot = await uploadTask;
        var imgURL = (await taskSnapshot.ref.getDownloadURL()).toString();

        uploadResult = await DatabaseServices(uid: user.uid).uploadUserData(
            email: email.trim(),
            username: name,
            nickname: nickname,
            gender: gender,
            major: major,
            bio: bio,
            avatar: imgURL,
            isAnon: isAnon,
            media: '',
            playlist: playlist,
            course: course,
            address: address,
            role: 'user',
            enabled: true,
            verified: false);
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
