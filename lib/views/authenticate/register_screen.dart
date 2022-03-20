import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/utils/image_utils.dart';
import 'package:luanvanflutter/utils/helper.dart';
import 'package:luanvanflutter/views/authenticate/intro/on_boarding.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/style/decoration.dart';
import 'package:luanvanflutter/views/authenticate/login_screen.dart';
import 'package:luanvanflutter/views/components/circle_avatar.dart';
import 'package:luanvanflutter/views/components/rounded_dropdown.dart';
import 'package:luanvanflutter/views/components/rounded_input_field.dart';
import 'package:luanvanflutter/views/components/rounded_password_field.dart';
import 'package:provider/src/provider.dart';

//class đăng ký tài khoản
class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker(); //Module chọn hình ảnh
  bool loading = false;
  var seletedGendertype, selectedMajorType, selectedCoursetype, selectedHome;
  File? _image;
  late PickedFile pickedFile;
  String email = '';
  String password = '';
  String error = '';
  String name = '';
  String bio = '';
  String nickname = '';
  String media = '';
  String playlist = '';

  final _genderType = <String>['Nam', 'Nữ'];

  final _courseType = <String>['42', '43', '44', '45', '46'];
  final _majorsType = <String>[
    'Công nghệ thông tin',
    'Tin học ứng dụng',
    'Công nghệ phần mềm',
    'Khoa học máy tính',
    'Hệ thống thông tin',
    'Mạng máy tính và truyền thông',
  ];

  @override
  void initState() {
    setFileToImage();
    seletedGendertype = _genderType[0];
    // selectedMajorType = _majorsType[0];
    // selectedCoursetype = _courseType[0];
    // selectedHome = _homeAreaType[0];
  }

  setFileToImage() async {
    _image =
        await ImageUtils.imageToFile(imageName: "student_avatar", ext: "png");
  }

  final List<String> _homeAreaType = <String>[
    'An Giang',
    'Bạc Liêu',
    'Bến Tre',
    'Cà Mau',
    'Cần Thơ',
    'Đồng Tháp',
    'Hậu Giang',
    'Kiên Giang',
    'Long An',
    'Sóc Trăng',
    'Tiền Giang',
    'Trà Vinh',
    'Vĩnh Long',
  ];

  Future<bool> signUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      var response = await context.read<AuthService>().signUp(
          email,
          password,
          name,
          nickname,
          seletedGendertype == "Nam" ? "Male" : "Female",
          selectedMajorType,
          bio,
          "",
          false,
          _image!,
          playlist,
          selectedCoursetype,
          selectedHome);
      setState(() {
        loading = false;
      });

      response.fold((isSuccess) async {
        return isSuccess;
      }, (error) {
        String err = '';
        switch (error.code) {
          case 'email-already-in-use':
            err = "Người dùng này đã tồn tại!";
            break;
          case 'invalid-email':
            err = "Email không hợp lệ!";
            break;
          case 'operation-not-allowed':
            err = "Tài khoản này vẫn chưa được mở khóa!";
            break;
          case 'weak-password':
            err = "Mật khẩu quá yếu. Vui lòng thử lại!";
            break;
          default:
            err = "Lỗi không rõ, xin vui lòng thử lại: " + error.code;
            break;
        }

        final SnackBar snackBar = SnackBar(content: Text(err));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
      });
    }
    return false;
  }

  pickImageFromGallery(context) async {
    Navigator.pop(context);
    pickedFile = (await picker.getImage(source: ImageSource.gallery))!;

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  captureImageFromCamera(context) async {
    Navigator.pop(context);
    pickedFile = (await picker.getImage(
        source: ImageSource.camera, maxHeight: 680, maxWidth: 970))!;

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  takeImage(nContext) {
    return showDialog(
        context: nContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Bài viết mới"),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text(
                  "Chụp bằng Camera",
                ),
                onPressed: () => captureImageFromCamera(context),
              ),
              SimpleDialogOption(
                child: const Text(
                  "Chọn ảnh từ thư viện",
                ),
                onPressed: () => pickImageFromGallery(nContext),
              ),
              SimpleDialogOption(
                child: const Text(
                  "Đóng",
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //Default image

    return Stack(children: [
      GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            'ĐĂNG KÝ',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: RoundedInputField(
                                      initialValue: email,
                                      hintText: "example@student.ctu.edu.vn",
                                      icon: Icons.alternate_email,
                                      onChanged: (val) {
                                        setState(() {
                                          email = val;
                                        });
                                      },
                                      validator: (val) {
                                        return RegExp(
                                                    r"(\w{1,}[b]\d{1,7})@(\w+\.||)+(ctu.edu.vn)")
                                                .hasMatch(val!)
                                            ? null
                                            : "Xin nhập đúng định dạng email trường cấp!";
                                      },
                                      title: 'Email',
                                    ),
                                  )
                                ],
                              ),
                              Row(children: <Widget>[
                                const SizedBox(width: 3),
                                Expanded(
                                    child: RoundedPasswordField(
                                  title: "Mật khẩu",
                                  onChanged: (val) {
                                    setState(() => password = val);
                                  },
                                  validator: (val) {
                                    return val!.isEmpty || val.length <= 6
                                        ? 'Xin cung cấp mật khẩu chính xác'
                                        : null;
                                  },
                                  hintText: 'Mật khẩu',
                                )),
                              ]),
                              Row(children: <Widget>[
                                const SizedBox(width: 3),
                                Expanded(
                                    child: RoundedPasswordField(
                                  title: "Nhập lại mật khẩu",
                                  onChanged: (val) {},
                                  validator: (val) {
                                    return val != password
                                        ? 'Mật khẩu không trùng khớp'
                                        : null;
                                  },
                                  hintText: 'Nhập lại mật khẩu',
                                )),
                              ]),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const SizedBox(width: 50),
                                  Align(
                                      alignment: Alignment.center,
                                      child: CustomCircleAvatar(
                                        image: (_image != null)
                                            ? Image.file(
                                                _image!,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/student_avatar.png',
                                                fit: BoxFit.cover,
                                              ),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 60),
                                    child: IconButton(
                                      color: kPrimaryColor,
                                      icon: const Icon(Icons.camera_alt,
                                          size: 30),
                                      onPressed: () {
                                        takeImage(context);
                                      },
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: RoundedInputField(
                                      initialValue: name,
                                      validator: (val) {
                                        return val!.isEmpty
                                            ? 'Tên của bạn'
                                            : null;
                                      },
                                      onChanged: (val) {
                                        setState(() => name = val);
                                      },
                                      icon: Icons.face,
                                      hintText: 'Tên của bạn',
                                      title: 'Tên hiển thị',
                                    ),
                                  ),
                                ],
                              ),
                              Row(children: <Widget>[
                                const SizedBox(width: 3),
                                Expanded(
                                  child: RoundedInputField(
                                    title: 'Biệt danh',
                                    initialValue: nickname,
                                    validator: (val) {
                                      return val!.isEmpty
                                          ? 'Nickname của bạn'
                                          : null;
                                    },
                                    onChanged: (val) {
                                      setState(() => nickname = val);
                                    },
                                    hintText: 'Tên ẩn danh của bạn',
                                    icon: Icons.masks,
                                  ),
                                ),
                              ]),
                              Row(
                                children: <Widget>[
                                  const SizedBox(height: 3),
                                  Expanded(
                                    child: RoundedDropDown(
                                      title: "Giới tính",
                                      validator: (val) {
                                        return val == null
                                            ? 'Vui lòng cung cấp giới tính hợp lệ'
                                            : null;
                                      },
                                      items: _genderType
                                          .map((String value) =>
                                              DropdownMenuItem<String>(
                                                child: Text(
                                                  value,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                value: value,
                                              ))
                                          .toList(),
                                      onChanged: (selectedGender) {
                                        setState(() {
                                          seletedGendertype = selectedGender;
                                        });
                                      },
                                      value: seletedGendertype,
                                      isExpanded: false,
                                      icon: seletedGendertype == _genderType[0]
                                          ? Icons.male
                                          : Icons.female,
                                      hintText: 'Giới tính của bạn',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: RoundedDropDown(
                                      title: "Quê quán",
                                      validator: (val) {
                                        return val == null
                                            ? 'Xin cung cấp quê quán của bạn'
                                            : null;
                                      },
                                      items: _homeAreaType
                                          .map((value) =>
                                              DropdownMenuItem<String>(
                                                child: Text(
                                                  value,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                value: value,
                                              ))
                                          .toList(),
                                      onChanged: (selectedArea) {
                                        setState(() {
                                          selectedHome = selectedArea;
                                        });
                                      },
                                      value: selectedHome,
                                      isExpanded: false,
                                      icon: Icons.home,
                                      hintText: 'Bạn đến từ',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: RoundedDropDown(
                                      title: "Khóa",
                                      validator: (val) {
                                        return val == null
                                            ? 'Xin cung cấp khóa của bạn'
                                            : null;
                                      },
                                      items: _courseType
                                          .map((value) => DropdownMenuItem(
                                                child: Text(
                                                  value,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                value: value,
                                              ))
                                          .toList(),
                                      onChanged: (selectedCourse) {
                                        setState(() {
                                          selectedCoursetype = selectedCourse;
                                        });
                                      },
                                      value: selectedCoursetype,
                                      isExpanded: false,
                                      icon: Icons.school,
                                      hintText: 'Bạn là sinh viên khóa mấy?',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: RoundedDropDown(
                                    title: "Ngành học",
                                    validator: (val) {
                                      return val == null
                                          ? "Vui lòng cung cấp thông tin này"
                                          : null;
                                    },
                                    items: _majorsType
                                        .map((value) => DropdownMenuItem(
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              value: value,
                                            ))
                                        .toList(),
                                    onChanged: (selectedMajor) {
                                      setState(() {
                                        selectedMajorType = selectedMajor;
                                      });
                                    },
                                    value: selectedMajorType,
                                    isExpanded: false,
                                    icon: Icons.work,
                                    hintText: 'Ngành học của bạn',
                                  ))
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                        maxLines: 5,
                                        onChanged: (val) {
                                          setState(() => bio = val);
                                        },
                                        decoration: const InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            hintText: ' Bio',
                                            hintStyle: TextStyle(
                                              color: Colors.black54,
                                            ),
                                            filled: true,
                                            fillColor: kPrimaryLightColor,
                                            border: OutlineInputBorder())),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              GestureDetector(
                                onTap: () async {
                                  await signUp(context);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: kPrimaryColor),
                                  child: const Text('TẠO TÀI KHOẢN',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Đã có tài khoản? "),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const LoginScreen();
                                      }));
                                    },
                                    child: const Text("Đăng nhập",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            decoration:
                                                TextDecoration.underline)),
                                  ),
                                  const SizedBox(
                                    height: 50,
                                  )
                                ],
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      loading ? Loading() : const Center()
    ]);
  }
}
