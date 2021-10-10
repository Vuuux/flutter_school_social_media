import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';

class AlreadyHaveAnAccountCheck extends StatelessWidget {
  final bool login;
  final VoidCallback press;
  const AlreadyHaveAnAccountCheck({
    required Key key,
    this.login = true,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? "Chưa có tài khoản? " : "Đã có tài khoản? ",
          style: const TextStyle(color: Colors.black26),
        ),
        GestureDetector(
          onTap: press,
          child: Text(
            login ? "Đăng ký ngay!" : "Đăng nhập thôi!",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
