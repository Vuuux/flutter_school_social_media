import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/utils/image_utils.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/authenticate/intro/on_boarding.dart';
import 'package:luanvanflutter/views/authenticate/login_screen.dart';
import 'package:luanvanflutter/views/components/circle_avatar.dart';
import 'package:luanvanflutter/views/components/rounded_dropdown.dart';
import 'package:luanvanflutter/views/components/rounded_input_field.dart';
import 'package:luanvanflutter/views/components/rounded_password_field.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
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
  late String seletedGenderType,
      selectedMajorType,
      selectedCoursetype,
      selectedHome;
  File? _image;
  File? _anonImage;
  PickedFile? pickedFile;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRetypeController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final _genderType = <String>['Nam', 'Nữ', 'Khác'];

  final _courseType = <String>[
    (DateTime.now().year - 2005 + 26).toString(),
    (DateTime.now().year - 2005 + 27).toString(),
    (DateTime.now().year - 2005 + 28).toString(),
    (DateTime.now().year - 2005 + 29).toString(),
    (DateTime.now().year - 2005 + 30).toString(),
    'Khác'
  ];
  final _majorsType = <String>[
    'Công nghệ thông tin',
    'Tin học ứng dụng',
    'Công nghệ phần mềm',
    'Khoa học máy tính',
    'Hệ thống thông tin',
    'Mạng máy tính và truyền thông',
    'Khác'
  ];

  @override
  void initState() {
    super.initState();
    setFileToImage();
    seletedGenderType = _genderType[0];
    selectedMajorType = _majorsType[0];
    selectedCoursetype = _courseType[0];
    selectedHome = _homeAreaType[0];
  }

  setFileToImage() async {
    _image = await ImageUtils.imageToFile(imageName: "appicon", ext: "png");
    _anonImage = await ImageUtils.imageToFile(imageName: "appicon", ext: "png");
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
    'Khác'
  ];

  Future signUp(BuildContext context) async {
    setState(() {
      loading = true;
    });

    var response = await context.read<AuthService>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _usernameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        gender: seletedGenderType == "Nam" ? "Male" : "Female",
        major: selectedMajorType,
        bio: _bioController.text.trim(),
        isAnon: false,
        pickedAvatar: _image!,
        playlist: '',
        course: selectedCoursetype,
        address: selectedHome);

    setState(() {
      loading = false;
    });

    response.fold((isSuccess) {
      Get.snackbar("Thành công",
          "Tạo tài khoản thành công, chuyển hướng tới trang chính",
          snackPosition: SnackPosition.BOTTOM);
      Get.to(() => const OnBoarding());
    }, (error) {
      String err = '';
      switch (error.code) {
        case 'email-already-in-use':
          err =
              "Người dùng này đã tồn tại! Nếu bạn nghĩ ai đó đã sử dụng email của bạn mà không được cho phép, hãy sử dụng chức năng quên mật khẩu để khôi phục tài khoản";
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
      Get.snackbar("Lỗi", err,
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3));
    });
  }

  pickImageFromGallery(context) async {
    Navigator.pop(context);
    pickedFile = (await picker.getImage(source: ImageSource.gallery))!;

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile!.path);
      });
    }
  }

  captureImageFromCamera(context) async {
    Navigator.pop(context);
    pickedFile = (await picker.getImage(
        source: ImageSource.camera, maxHeight: 680, maxWidth: 970))!;

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile!.path);
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

  _validateInput(BuildContext context) async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordRetypeController.text.isEmpty ||
        _nicknameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _bioController.text.isEmpty) {
      Get.snackbar("Bắt buộc!", "Vui lòng nhập tất cả cả trường",
          snackPosition: SnackPosition.BOTTOM);
    } else if (!RegExp(r"(\w{1,}[b]\d{1,7})@(\w+\.||)+(ctu.edu.vn)")
        .hasMatch(_emailController.text.trim())) {
      Get.snackbar(
          "Bắt buộc!", "Xin lòng nhập đúng định dạng email trường cấp cho bạn",
          snackPosition: SnackPosition.BOTTOM);
    } else if (_passwordController.text.length < 6) {
      Get.snackbar("Bắt buộc!", "Xin lòng nhập mật khẩu nhiều hơn 6 ký tự",
          snackPosition: SnackPosition.BOTTOM);
    } else if (_passwordController.text.trim() !=
        _passwordRetypeController.text.trim()) {
      Get.snackbar("Bắt buộc!", "Mật khẩu xác nhận không trùng nhau",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      await signUp(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                      controller: _emailController,
                                      hintText: "example@student.ctu.edu.vn",
                                      icon: Icons.alternate_email,
                                      title: 'Email',
                                    ),
                                  )
                                ],
                              ),
                              Row(children: <Widget>[
                                const SizedBox(width: 3),
                                Expanded(
                                    child: RoundedPasswordField(
                                  controller: _passwordController,
                                  title: "Mật khẩu",
                                  hintText: 'Mật khẩu',
                                )),
                              ]),
                              Row(children: <Widget>[
                                const SizedBox(width: 3),
                                Expanded(
                                    child: RoundedPasswordField(
                                  controller: _passwordRetypeController,
                                  title: "Nhập lại mật khẩu",
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
                                                'assets/appicon.png',
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
                                      controller: _usernameController,
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
                                    controller: _nicknameController,
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
                                          seletedGenderType = selectedGender;
                                        });
                                      },
                                      value: seletedGenderType,
                                      isExpanded: false,
                                      icon: seletedGenderType == _genderType[0]
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
                                        controller: _bioController,
                                        maxLines: 5,
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
                                            border: OutlineInputBorder())),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              GestureDetector(
                                onTap: () {
                                  _validateInput(context);
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
                                          color: Colors.white,
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
