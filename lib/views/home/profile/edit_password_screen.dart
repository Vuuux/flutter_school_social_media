import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/components/rounded_password_field.dart';
import 'package:provider/provider.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({Key? key}) : super(key: key);

  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmNewPasswordController = TextEditingController();
  bool loading = false;

  bool checkCurrentPasswordValid = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    return loading
        ? Loading()
        : GestureDetector(
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
                title: const Text("Đ Ổ I    M Ậ T    K H Ẩ U",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
              ),
              body: StreamBuilder<UserData?>(
                  stream: DatabaseServices(uid: user!.uid).userData,
                  builder: (context, snapshot) {
                    return GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: Scaffold(
                        body: SingleChildScrollView(
                          child: Container(
                            height: MediaQuery.of(context).size.height - 50,
                            alignment: Alignment.center,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: RoundedPasswordField(
                                                controller: _passwordController,
                                                title: "Mật khẩu hiện tại",
                                                hintText: 'Mật khẩu hiện tại',
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: RoundedPasswordField(
                                                controller:
                                                    _newPasswordController,
                                                title: "Mật khẩu mới",
                                                hintText: 'Mật khẩu mới',
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: RoundedPasswordField(
                                                controller:
                                                    _confirmNewPasswordController,
                                                title: "Nhập lại mật khẩu mới",
                                                hintText:
                                                    'Xác nhận mật khẩu mới',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        GestureDetector(
                                          onTap: () async {
                                            checkCurrentPasswordValid =
                                                await context
                                                            .read<AuthService>()
                                                            .validatePassword(
                                                                _passwordController
                                                                    .text) ==
                                                        'OK'
                                                    ? true
                                                    : false;

                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                loading = false;
                                              });

                                              if (checkCurrentPasswordValid) {
                                                if (_newPasswordController
                                                        .text !=
                                                    _confirmNewPasswordController
                                                        .text) {
                                                  Get.snackbar("Sai thông tin",
                                                      "Mật khẩu xác nhận mới không khớp!",
                                                      snackPosition:
                                                          SnackPosition.BOTTOM);
                                                } else {
                                                  context
                                                      .read<AuthService>()
                                                      .updatePassword(
                                                          _newPasswordController
                                                              .text)
                                                      .then((value) {
                                                    if (value == 'OK') {
                                                      Get.snackbar("Thành công",
                                                          "Đổi mật khẩu thành công",
                                                          snackPosition:
                                                              SnackPosition
                                                                  .BOTTOM);
                                                      // Fluttertoast.showToast(
                                                      //     msg:
                                                      //         "Đổi mật khẩu thành công",
                                                      //     toastLength:
                                                      //         Toast.LENGTH_SHORT,
                                                      //     gravity:
                                                      //         ToastGravity.CENTER,
                                                      //     timeInSecForIosWeb: 1);
                                                      Navigator.of(context)
                                                          .pushAndRemoveUntil(
                                                              FadeRoute(
                                                                  page:
                                                                      Wrapper()),
                                                              ModalRoute.withName(
                                                                  'Wrapper'));
                                                    } else {
                                                      final SnackBar snackBar =
                                                          SnackBar(
                                                              content:
                                                                  Text(value));
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              snackBar);
                                                    }
                                                  });
                                                }
                                              }
                                            }
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                color: Get.isDarkMode
                                                    ? kPrimaryDarkColor
                                                    : kPrimaryColor),
                                            child: Text('Xác nhận mật khẩu mới',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Get.isDarkMode
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          );
  }
}
