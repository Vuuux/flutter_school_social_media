import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/style/text_style.dart';

class BottomSheetButton extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final Function() onTap;
  final bool isClose;

  const BottomSheetButton({
    Key? key,
    required this.label,
    required this.color,
    required this.onTap,
    this.isClose = false,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 55,
          width: Get.width * 0.9,
          decoration: BoxDecoration(
              color: color ?? Colors.white,
              border: Border.all(
                width: 2,
                color: isClose ? Colors.grey[400]! : color!,
              ),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
              child: Text(
            label,
            style: titleStyle.copyWith(
                color: isClose ? Colors.red : textColor ?? Colors.white),
          )),
        ));
  }
}
