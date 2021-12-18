import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/style/floating_image.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/authenticate/forgot_password_screen.dart';
import 'package:luanvanflutter/views/authenticate/register_screen.dart';
import 'package:luanvanflutter/views/authenticate/signup_screen.dart';
import 'package:luanvanflutter/views/components/already_have_an_account_acheck.dart';
import 'package:luanvanflutter/views/components/forgot_password_check.dart';
import 'package:luanvanflutter/views/components/rounded_button.dart';
import 'package:luanvanflutter/views/components/rounded_input_field.dart';
import 'package:luanvanflutter/views/components/rounded_password_field.dart';
import 'package:luanvanflutter/home.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:provider/src/provider.dart';

import 'helper.dart';
import 'intro/on_boarding.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  late QuerySnapshot snapshotUserinfo;

  String email = '';
  String password = '';
  String error = '';

  final _formKey = GlobalKey<FormState>();

  signIn(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      //lưu email vào sharedPreferences
      Helper.saveUserEmailSharedPreference(email.toString());
      //Lưu username vào database
      //TODO: ADD UID
      DatabaseServices(uid: '')
          .getUserByEmail(email.toString())
          .then((value) async {
        snapshotUserinfo = value;
        await Helper.saveUserIdSharedPreference(
            snapshotUserinfo.docs[0].get('id'));

        Helper.getUserIdSharedPreference()
            .then((value) => print("USERNAME:" + value.toString()));
        Helper.getUserEmailSharedPreference()
            .then((value) => print("EMAIL:" + value.toString()));
      });

      //setStateLoading
      setState(() {
        loading = true;
      });

      context.read<AuthService>().signIn(email, password).then((value) {
        String err = "";
        if (value == "OK") {
          Helper.saveUserLoggedInSharedPreference(true);
          Fluttertoast.showToast(
              msg: "Đăng nhập thành công",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1);
          setState(() {
            error = err;
            loading = false;
          });
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Wrapper()));
        } else {
          switch (value) {
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
          setState(() {
            error = err;
            loading = false;
          });
          final SnackBar snackBar = SnackBar(content: Text(error));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
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
                SizedBox(
                  height: h,
                  width: w,
                  child: Column(
                    children: [
                      SingleChildScrollView(
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
                                      height: size.height * 0.35,
                                    )),
                                    SizedBox(height: size.height * 0.03),
                                    RoundedInputField(
                                        initialValue: email,
                                        hintText: "Email của bạn",
                                        icon: Icons.person,
                                        onChanged: (value) {
                                          setState(() {
                                            email = value;
                                          });
                                        },
                                        validator: (val) {
                                          return RegExp(
                                                      r"(\w{1,}[b]\d{1,7})@(\w+\.||)+(ctu.edu.vn)")
                                                  .hasMatch(val!)
                                              ? null
                                              : "Xin nhập đúng định dạng email trường cấp!";
                                        }),
                                    RoundedPasswordField(
                                      validator: (val) => val.length < 6
                                          ? 'Điền mật khẩu dưới 6 ký tự'
                                          : null,
                                      onChanged: (value) {
                                        setState(() {
                                          password = value;
                                        });
                                      },
                                      hintText: 'Mật khẩu',
                                    ),
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
                                signIn(context);
                              },
                            ),
                            SizedBox(height: size.height * 0.03),
                            AlreadyHaveAnAccountCheck(
                              press: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const Register();
                                    },
                                  ),
                                );
                              },
                              key: UniqueKey(),
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
              ],
            ),
          ),
        ),
        loading ? Loading() : const Center()
      ],
    );
  }
}
