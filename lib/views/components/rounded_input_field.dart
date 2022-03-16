import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/components/text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String title;
  final String initialValue;
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final FormFieldValidator validator;
  const RoundedInputField({
    Key? key,
    required this.initialValue,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    required this.validator,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
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
            initialValue: initialValue,
            autofocus: false,
            validator: validator,
            onChanged: onChanged,
            cursorColor: kPrimaryColor,
            decoration: InputDecoration(
              hintStyle: const TextStyle(color: Colors.black45),
              icon: Icon(
                icon,
                color: kPrimaryColor,
              ),
              hintText: hintText,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
