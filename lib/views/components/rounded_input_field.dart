import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/components/text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String title;
  final String hintText;
  final IconData? icon;
  final bool isTitleCenter;
  final TextEditingController? controller;

  const RoundedInputField({
    Key? key,
    required this.hintText,
    this.icon,
    this.controller,
    required this.title,
    this.isTitleCenter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          isTitleCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        title.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  title + ":",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              )
            : const SizedBox.shrink(),
        TextFieldContainer(
          child: TextFormField(
            controller: controller,
            autofocus: false,
            decoration: InputDecoration(
              hintStyle: const TextStyle(color: Colors.black45),
              icon: icon != null
                  ? Icon(
                      icon,
                      color: kPrimaryColor,
                    )
                  : null,
              hintText: hintText,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
