import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/style/text_style.dart';
import 'package:luanvanflutter/utils/dimen.dart';

class CustomInputField extends StatelessWidget {
  final String title;
  final String content;
  final TextEditingController? controller;
  final Widget? widget;

  const CustomInputField({
    Key? key,
    required this.title,
    required this.content,
    this.controller,
    this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Dimen.paddingCommon15),
      padding: EdgeInsets.symmetric(horizontal: Dimen.paddingCommon15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Container(
            height: 52,
            margin: const EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: widget == null ? false : true,
                    autofocus: false,
                    cursorColor:
                        Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
                    controller: controller,
                    style: subTitleStyle,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Dimen.paddingCommon15),
                        hintText: content,
                        hintStyle: subTitleStyle,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.backgroundColor,
                                width: 0)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.backgroundColor,
                                width: 0))),
                  ),
                ),
                widget ?? const SizedBox.shrink()
              ],
            ),
          )
        ],
      ),
    );
  }
}
