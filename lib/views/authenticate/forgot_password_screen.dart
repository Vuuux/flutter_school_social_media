import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/style/decoration.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/components/rounded_input_field.dart';
import 'package:luanvanflutter/views/components/rounded_password_field.dart';
import 'package:provider/provider.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/home.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  bool loading = false;

  bool checkCurrentPasswordValid = true;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Bạn chắc muốn dừng chỉnh sửa chứ?'),
            content: Text('Bạn chắc chưa?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Chưa'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Rồi!'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : WillPopScope(
            onWillPop: _onWillPop,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    elevation: 0,
                    leading: IconButton(
                        icon: const Icon(LineAwesomeIcons.home),
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              FadeRoute(page: Wrapper()),
                              ModalRoute.withName('Wrapper'));
                        }),
                    title: const Text("Q U Ê N    M Ậ T    K H Ẩ U",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w100)),
                  ),
                  body: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Scaffold(
                      body: SingleChildScrollView(
                        child: Container(
                          height: MediaQuery.of(context).size.height - 50,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: RoundedInputField(
                                              initialValue: email,
                                              hintText:
                                                  "Email tài khoản đã đăng ký của bạn",
                                              icon: Icons.person,
                                              onChanged: (value) {
                                                setState(() {
                                                  email = value;
                                                });
                                              },
                                              validator: (val) => val.isEmpty
                                                  ? 'Nhập email'
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      GestureDetector(
                                        onTap: () async {
                                          context.read<AuthService>().sendEmailResetPassword(email);
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  FadeRoute(page: Wrapper()),
                                                  ModalRoute.withName(
                                                      'Wrapper'));
                                          //}
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              color: kPrimaryColor),
                                          child: const Text(
                                              'XÁC NHẬN',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      ),
                                      const SizedBox(height: 50,),
                                      const Center(
                                        child: Text("Đường dẫn khôi phục mật khẩu sẽ được gửi đến email của bạn sau khi nhấn XÁC NHẬN"),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
            ),
          );
  }
}
