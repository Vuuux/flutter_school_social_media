import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/src/either.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/task.dart';
import 'package:luanvanflutter/utils/helper.dart';

class TaskController extends GetxController {
  final DatabaseServices _database =
      DatabaseServices(uid: Helper().getUserId());
  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <TaskSchedule>[].obs;

  Future getTasks() async {
    var response = await _database.getTasks();
    response.fold((left) {
      taskList.assignAll(left.docs
          .map((task) => TaskSchedule.fromDocumentSnapshot(task))
          .toList());
    }, (right) {
      Get.showSnackbar(GetSnackBar(
        title: "Có lỗi xảy ra",
        message: right.message,
        snackPosition: SnackPosition.BOTTOM,
      ));
    });
  }

  Future<Either<bool, FirebaseException>> addTask(
      {required TaskSchedule task}) async {
    return await _database.createTask(task);
  }

  Future<Either<bool, FirebaseException>> deleteTask(
      {required String taskId}) async {
    return await _database.deleteTask(taskId);
  }

  Future<Either<bool, FirebaseException>> updateTask(
      {required String taskId, bool isCompleted = true}) async {
    return await _database.updateCompleteStatusTask(taskId, isCompleted);
  }
}
