import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';

class ForgotPasswordCheck extends StatelessWidget {
  final bool login;
  final VoidCallback press;
  const ForgotPasswordCheck({
    required Key key,
    this.login = true,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        GestureDetector(
          onTap: press,
          child: const Text(
            "Quên mật khẩu",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 50),
      ],
    );
  }
}
