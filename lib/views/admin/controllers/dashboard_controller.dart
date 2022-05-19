import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/forum.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/report.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/utils/helper.dart';
import 'package:provider/provider.dart';

import 'menu_controller.dart';

enum RequestStatus { LOADING, SUCESS, ERROR }

class DashboardController extends GetxController {
  final DatabaseServices _database =
      DatabaseServices(uid: Helper().getUserId());
  @override
  void onReady() {
    super.onReady();
  }

  void setRequestStatus(RequestStatus _value) => requestStatus.value = _value;

  var postList = <PostModel>[].obs;
  var userList = <UserData>[].obs;
  var reportList = <ReportModel>[].obs;
  var forumList = <ForumModel>[].obs;
  final requestStatus = RequestStatus.LOADING.obs;

  Future getAlLData() async {
    setRequestStatus(RequestStatus.LOADING);
    await getAllPosts();
    await getAllUsers();
    await getAllForums();
    await getAllReports();
    setRequestStatus(RequestStatus.SUCESS);
  }

  Future getAllPosts() async {
    var response = await _database.getTimelinePosts();
    response.fold((left) {
      postList.assignAll(left.docs
          .map((post) => PostModel.fromDocumentSnapshot(post))
          .toList());
    }, (right) {
      setRequestStatus(RequestStatus.ERROR);
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
  }

  Future getAllForums() async {
    var response = await _database.getForums();
    forumList.assignAll(
        response.docs.map((post) => ForumModel.fromDocument(post)).toList());
  }

  Future getAllUsers() async {
    var response = await _database.getAllUsers();
    response.fold((left) {
      userList.assignAll(left.docs
          .map((user) => UserData.fromDocumentSnapshot(user))
          .toList());
    }, (right) {
      setRequestStatus(RequestStatus.ERROR);
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
  }

  Future getAllReports() async {
    var response = await _database.getAllReports();
    response.fold((left) {
      reportList.assignAll(left.docs
          .map((report) => ReportModel.fromDocumentSnapshot(report))
          .toList());
    }, (right) {
      setRequestStatus(RequestStatus.ERROR);
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
  }

  Future<Either<bool, FirebaseException>> addPost(
      {required PostModel post}) async {
    return await _database.createPost(post);
  }

  Future<Either<bool, FirebaseException>> deletePost(
      {required String postId, required userId}) async {
    return await _database.deletePost(postId, userId);
  }

  Future<Either<bool, FirebaseException>> reportPost(
      {required PostModel post, required String reason}) async {
    return await _database.reportPost(post, reason);
  }

  Future<Either<bool, FirebaseException>> validateReport(
      {required ReportModel report, required String status}) async {
    return await _database.validateReport(report, status);
  }

  Future searchPost(String query) async {
    setRequestStatus(RequestStatus.LOADING);
    var response = await _database.searchPost(query);
    response.fold((left) {
      postList.value = [];
      postList.assignAll(left.docs
          .map((post) => PostModel.fromDocumentSnapshot(post))
          .toList());
      setRequestStatus(RequestStatus.SUCESS);
    }, (right) {
      setRequestStatus(RequestStatus.ERROR);
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
  }

  disableUser({required BuildContext context, required String userId}) async {
    setRequestStatus(RequestStatus.LOADING);
    var response = await _database.disableUser(userId: userId);
    setRequestStatus(RequestStatus.SUCESS);
    response.fold((left) {
      Get.showSnackbar(const GetSnackBar(
        title: "Thành công",
        message: "Khóa người dùng thành công",
        snackPosition: SnackPosition.BOTTOM,
      ));
    }, (right) {
      setRequestStatus(RequestStatus.ERROR);
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
    getAllUsers();
  }

  enableUser({required BuildContext context, required String userId}) async {
    setRequestStatus(RequestStatus.LOADING);
    var response = await _database.enableUser(userId: userId);
    setRequestStatus(RequestStatus.SUCESS);
    response.fold((left) {
      Get.showSnackbar(const GetSnackBar(
        title: "Thành công",
        message: "Mở khóa người dùng thành công",
        snackPosition: SnackPosition.BOTTOM,
      ));
    }, (right) {
      setRequestStatus(RequestStatus.ERROR);
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
    getAllUsers();
  }

  deleteUser({required BuildContext context, required String userId}) async {
    setRequestStatus(RequestStatus.LOADING);
    var response = await _database.deleteUserData(userId: userId);
    setRequestStatus(RequestStatus.SUCESS);
    response.fold((left) {
      Get.showSnackbar(const GetSnackBar(
        title: "Thành công",
        message: "Xóa người dùng thành công",
        snackPosition: SnackPosition.BOTTOM,
      ));
    }, (right) {
      setRequestStatus(RequestStatus.ERROR);
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
    getAllUsers();
  }
}
