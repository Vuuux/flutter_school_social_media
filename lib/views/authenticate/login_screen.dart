import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/floating_image.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/authenticate/forgot_password_screen.dart';
import 'package:luanvanflutter/views/authenticate/register_screen.dart';
import 'package:luanvanflutter/views/components/already_have_an_account_acheck.dart';
import 'package:luanvanflutter/views/components/forgot_password_check.dart';
import 'package:luanvanflutter/views/components/rounded_button.dart';
import 'package:luanvanflutter/views/components/rounded_input_field.dart';
import 'package:luanvanflutter/views/components/rounded_password_field.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:provider/src/provider.dart';

import '../../utils/helper.dart';
import 'intro/on_boarding.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  late QuerySnapshot snapshotUserinfo;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late String email;
  late String password;
  String error = '';

  @override
  void initState() {
    super.initState();
    email = "";
    password = "";
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  final _formKey = GlobalKey<FormState>();
  _validateInput() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      email = _emailController.text.trim();
      password = _passwordController.text.trim();
      await _signIn(context);
    } else if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Get.snackbar("Bắt buộc", "Tất cả các ô cần được nhập",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          icon: const Icon(Icons.warning_amber_rounded));
    } else if (!RegExp(r"(\w{1,}[b]\d{1,7})@(\w+\.||)+(ctu.edu.vn)")
        .hasMatch(_emailController.text)) {
      Get.snackbar("Bắt buộc", "Xin nhập đúng định dạng email trường cấp!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          icon: const Icon(Icons.warning_amber_rounded));
    }
  }

  _signIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      //Lưu username vào database
      DatabaseServices(uid: '')
          .getUserByEmail(email.toString())
          .then((value) async {
        snapshotUserinfo = value;
      });
      setState(() {
        loading = true;
      });
      var response = await context.read<AuthService>().signIn(email, password);
      setState(() {
        loading = false;
      });
      response.fold((result) async {
        Fluttertoast.showToast(
            msg: "Đăng nhập thành công",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1);
        Get.back();
      }, (error) {
        String err = "";
        switch (error.code) {
          case "invalid-email":
            {
              err = "Sai tài khoản hoặc mật khẩu!";
              break;
            }
          case "wrong-password":
            {
              err = "Sai tài khoản hoặc mật khẩu!";
              break;
            }
          case "user-not-found":
            {
              err = "Người dùng này không tồn tại";
              break;
            }
        }
        Get.snackbar("Lỗi", err, snackPosition: SnackPosition.BOTTOM);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: 0,
                  left: 0,
                  child: Image.asset(
                    "assets/images/main_top.png",
                    width: size.width * 0.35,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(
                    "assets/images/login_bottom.png",
                    width: size.width * 0.4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: size.height * 0.1),
                      const Text(
                        "ĐĂNG NHẬP",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              FloatingImage(
                                  image: SvgPicture.asset(
                                "assets/icons/login.svg",
                                height: size.height * 0.3,
                              )),
                              SizedBox(height: size.height * 0.03),
                              RoundedInputField(
                                isTitleCenter: true,
                                title: "Email",
                                controller: _emailController,
                                hintText: "Email của bạn",
                                icon: Icons.person,
                              ),
                              RoundedPasswordField(
                                controller: _passwordController,
                                isTitleCenter: true,
                                title: "Mật khẩu",
                                hintText: 'Mật khẩu',
                              ),
                              // CustomPasswordField(
                              //   isTitleCenter: true,
                              //   title: "Mật khẩu",
                              //   onChanged: (value) {
                              //     setState(() {
                              //       password = value;
                              //     });
                              //   },
                              //   hintText: 'Mật khẩu',
                              // ),
                              ForgotPasswordCheck(
                                key: UniqueKey(),
                                press: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const ForgotPassword();
                                      },
                                    ),
                                  );
                                },
                              )
                            ],
                          )),
                      RoundedButton(
                        text: "ĐĂNG NHẬP",
                        press: () async {
                          await _validateInput();
                        },
                      ),
                      Expanded(
                        child: AlreadyHaveAnAccountCheck(
                          press: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Register();
                                },
                              ),
                            );
                          },
                          key: UniqueKey(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "Lưu ý ứng dụng này không phải ứng dụng được "
                          "phát hành chính thức bởi nhà trường",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 1.0,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w100,
                              color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        loading ? Loading() : const Center()
      ],
    );
  }
}
