import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String email = '';
  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  bool loading = false;

  bool checkCurrentPasswordValid = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUser?>();
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
              body: StreamBuilder<UserData>(
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
                                                                oldPassword) ==
                                                        'OK'
                                                    ? true
                                                    : false;

                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                loading = false;
                                              });

                                              if (checkCurrentPasswordValid) {
                                                context
                                                    .read<AuthService>()
                                                    .updatePassword(newPassword)
                                                    .then((value) {
                                                  if (value == 'OK') {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Đổi mật khẩu thành công",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1);
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
                                                        .showSnackBar(snackBar);
                                                  }
                                                });
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
                                                color: kPrimaryColor),
                                            child: const Text(
                                                'Xác nhận mật khẩu mới',
                                                style: TextStyle(
                                                    fontSize: 18,
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
