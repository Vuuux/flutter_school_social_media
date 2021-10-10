import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/components/text_field_container.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final FormFieldValidator validator;
  final String hintText;
  const RoundedPasswordField({
    Key? key,
    required this.onChanged,
    required this.validator, required this.hintText,
  }) : super(key: key);

  @override
  State<RoundedPasswordField> createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        validator: widget.validator,
        obscureText: !_passwordVisible,
        onChanged: widget.onChanged,
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
            icon:
            Icon(
              !_passwordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            color: kPrimaryColor,

          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

}
