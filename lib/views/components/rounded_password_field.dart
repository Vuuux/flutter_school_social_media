import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/components/text_field_container.dart';

class RoundedPasswordField extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isTitleCenter;

  const RoundedPasswordField(
      {Key? key,
      this.controller,
      required this.hintText,
      this.focusNode,
      required this.title,
      this.isTitleCenter = false})
      : super(key: key);

  @override
  State<RoundedPasswordField> createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: widget.isTitleCenter
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        widget.title.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  widget.title + ":",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              )
            : const SizedBox.shrink(),
        TextFieldContainer(
          child: TextFormField(
            focusNode: widget.focusNode,
            controller: widget.controller,
            obscureText: !_passwordVisible,
            cursorColor: kPrimaryColor,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.black45),
              icon: const Icon(
                Icons.lock,
                color: kPrimaryColor,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                icon: Icon(
                  !_passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                color: kPrimaryColor,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
