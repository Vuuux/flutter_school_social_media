import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/src/either.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/comment.dart';
import 'package:luanvanflutter/utils/helper.dart';

class CommentController extends GetxController {
  final DatabaseServices _database =
      DatabaseServices(uid: Helper().getUserId());
  @override
  void onReady() {
    super.onReady();
  }

  var commentList = <CommentModel>[].obs;

  Future getComments(String postId) async {
    var response = await _database.getCommentsNew(postId);
    response.fold((left) {
      commentList.assignAll(left.docs
          .map((task) => CommentModel.fromDocumentSnapshot(task))
          .toList());
    }, (right) {
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
  }

  List<CommentModel> getReplyComments(
      Either<QuerySnapshot, FirebaseException> response) {
    List<CommentModel> replyCommentList = [];
    response.fold((left) {
      replyCommentList.assignAll(left.docs
          .map((task) => CommentModel.fromDocumentSnapshot(task))
          .toList());
    }, (right) {
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
    return replyCommentList;
  }

  Future<Either<bool, FirebaseException>> addComment(
      {required CommentModel comment, required String postId}) async {
    return await _database.postComment(postId, comment);
  }

  Future deleteComment({required String taskId, required String postId}) async {
    var response = await _database.deleteComment(postId, taskId);
    response.fold((left) {
      if (left) {
        Get.showSnackbar(const GetSnackBar(
          title: "Thành công",
          message: "Xóa bình luận thành công",
          snackPosition: SnackPosition.BOTTOM,
        ));
      }
    }, (right) {
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
  }

  Future<Either<bool, FirebaseException>> updateComment(
      {required String taskId, bool isCompleted = true}) async {
    return await _database.updateCompleteStatusTask(taskId, isCompleted);
  }
}
