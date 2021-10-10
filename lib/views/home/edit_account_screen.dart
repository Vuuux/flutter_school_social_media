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
import 'package:luanvanflutter/views/home/home.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';

class EditAccount extends StatefulWidget {
  @override
  _EditAccountState createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  bool loading = false;

  bool checkCurrentPasswordValid = true;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser>(context);
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
                  stream: DatabaseServices(uid: user.uid).userData,
                  builder: (context, snapshot) {
                    UserData userData = snapshot.data!;
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
                                            const Icon(
                                              Icons.lock,
                                              color: Colors.deepPurpleAccent,
                                            ),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: RoundedPasswordField(
                                                validator: (val) {
                                                  return checkCurrentPasswordValid
                                                      ? null
                                                      : 'Sai mật khẩu!';
                                                },
                                                onChanged: (val) {
                                                  setState(
                                                      () => oldPassword = val);
                                                },
                                                hintText: 'Mật khẩu hiện tại',
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            SizedBox(width: 3),
                                            Expanded(
                                              child: RoundedPasswordField(
                                                validator: (val) {
                                                  return val.isEmpty ||
                                                          val.length <= 6
                                                      ? 'Hãy cung cấp mật khẩu hợp lệ!'
                                                      : null;
                                                },
                                                onChanged: (val) {
                                                  setState(
                                                      () => newPassword = val);
                                                },
                                                hintText: 'Mật khẩu mới',
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.lock,
                                              color: Colors.deepPurpleAccent,
                                            ),
                                            Expanded(
                                              child: RoundedPasswordField(
                                                validator: (val) {
                                                  return newPassword == val
                                                      ? null
                                                      : 'Mật khẩu không trùng khớp!';
                                                },
                                                onChanged: (val) {
                                                  setState(() =>
                                                      confirmPassword = val);
                                                },
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
                                                        oldPassword);

                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                loading = false;
                                              });
                                              context
                                                  .read<AuthService>()
                                                  .updatePassword(newPassword);

                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      FadeRoute(
                                                          page: Wrapper()),
                                                      ModalRoute.withName(
                                                          'Wrapper'));
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
                                                color: Color(0xFF373737)),
                                            child: Text('Xác nhận mật khẩu mới',
                                                style: simpleTextStyle()),
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
