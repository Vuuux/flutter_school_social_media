import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/models/post.dart';

import '../utils/helper.dart';
import 'controller.dart';

enum RequestStatus { LOADING, SUCESS, ERROR }

class PostController extends GetxController {
  final DatabaseServices _database =
      DatabaseServices(uid: Helper().getUserId());
  @override
  void onReady() {
    super.onReady();
  }

  final requestStatus = RequestStatus.LOADING.obs;

  void setRequestStatus(RequestStatus _value) => requestStatus.value = _value;

  var postList = <PostModel>[].obs;

  Future getPosts() async {
    setRequestStatus(RequestStatus.LOADING);
    var response = await _database.getTimelinePosts();
    response.fold((left) {
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

  Future<Either<bool, FirebaseException>> addPost(
      {required PostModel post}) async {
    return await _database.createPost(post);
  }

  Future<Either<bool, FirebaseException>> deletePost(
      {required String postId, required userId}) async {
    return await _database.deletePost(postId, userId);
  }

  Future<Either<bool, FirebaseException>> reportPost(
      {required String taskId, required String reason}) async {
    return await _database.reportPost(taskId, reason);
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
}
