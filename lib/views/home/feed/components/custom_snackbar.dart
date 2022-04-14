import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomSnackBar {
  final String title;
  final String text;
  final bool isWarning;
  final bool isInfo;

  CustomBottomSnackBar({
    required this.title,
    required this.text,
    this.isWarning = false,
    this.isInfo = true,
  });

  void createSnackBar() {
    Get.snackbar(title, text,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        icon: isWarning
            ? const Icon(Icons.warning_amber_rounded)
            : isInfo
                ? const Icon(Icons.info)
                : const Icon(Icons.error));
  }
}
