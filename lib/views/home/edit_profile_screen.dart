import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:luanvanflutter/views/components/circle_avatar.dart';
import 'package:luanvanflutter/views/components/rounded_dropdown.dart';
import 'package:luanvanflutter/views/components/rounded_input_field.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvanflutter/views/home/profile.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/views/authenticate/helper.dart';
import 'package:luanvanflutter/style/decoration.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:provider/provider.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/views/home/home.dart';
import '../../controller/controller.dart';
import 'package:luanvanflutter/style/constants.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  File? _image;
  String y = "";
  String x = "";
  final List<String> _genderType = <String>[
    'Male',
    'Female',
  ];

  Future getImage() async {
    var image =
        await ImagePicker.platform.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
  }

  final List<String> _majorsType = <String>[
    'Công nghệ thông tin',
    'Tin học ứng dụng',
    'Công nghệ phần mềm',
    'Khoa học máy tính',
    'Hệ thống thông tin',
    'Mạng máy tính và truyền thông',
  ];

  updateUser(BuildContext context) {
    final user = context.watch<CurrentUser>();

    Future uploadPic() async {
      Reference firebaseStorageReference =
          FirebaseStorage.instance.ref().child(_image!.path);

      UploadTask uploadTask = firebaseStorageReference.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      x = (await taskSnapshot.ref.getDownloadURL()).toString();
      //TODO: CATCH ERROR HERE
      DatabaseServices(uid: user.uid).updateUserData(
          email,
          name,
          nickname,
          selectedGenderType,
          selectedMajorType,
          bio,
          x,
          false,
          media,
          playlist,
          selectedcourse,
          home);
    }

    if (_image != null) {
      uploadPic();
      setState(() {
        loading = false;
      });
    } else {
      print(y);

      DatabaseServices(uid: user.uid).updateUserData(
          email,
          name,
          nickname,
          selectedGenderType,
          selectedMajorType,
          bio,
          y,
          false,
          media,
          playlist,
          selectedcourse,
          home);
      DatabaseServices(uid: user.uid).uploadWhoData(
          email: email,
          name: name,
          avatar: y,
          gender: selectedGenderType,
          score: 0,
          nickname: nickname,
          isAnon: false);
      setState(() {
        loading = false;
      });
    }
    Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));

    Helper.saveUserEmailSharedPreference(email);
    Helper.saveUserNameSharedPreference(name);

    Helper.saveUserLoggedInSharedPreference(true);
  }

  String email = '';
  String error = '';
  String name = '';
  String nickname = '';
  String bio = '';
  String media = '';
  String playlist = '';
  late String selectedGenderType, selectedcourse, home;
  late String selectedMajorType;
  final List<String> _courses = <String>['46', '45', '44', '43', '52'];
  final List<String> _homeArea = <String>[
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
    'Vĩnh Long'
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        const BoxConstraints(
          maxWidth: 414,
          maxHeight: 869,
        ),
        designSize: const Size(360, 690),
        orientation: Orientation.portrait);
    final user = context.watch<CurrentUser?>();
    return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                    icon: const Icon(LineAwesomeIcons.home),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          FadeRoute(page: Wrapper()),
                          ModalRoute.withName('Wrapper'));
                    }),
                title: const Text("S Ử A   T H Ô N G   T I N",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
              ),
              body: StreamBuilder<UserData>(
                  stream: DatabaseServices(uid: user!.uid).userData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      UserData? userData = snapshot.data;
                      return GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: Scaffold(
                          body: Stack(
                            children: <Widget>[
                              SingleChildScrollView(
                                child: Container(
                                  decoration: BoxDecoration(
                                    //color: Color(0xFF505050),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  alignment: Alignment.center,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          children: <Widget>[
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                const SizedBox(width: 50),
                                                Align(
                                                    alignment: Alignment.center,
                                                    child: CustomCircleAvatar(
                                                      image: (_image != null)
                                                          ? Image.file(
                                                        _image!,
                                                        fit: BoxFit.fill,
                                                      )
                                                          : Image.network(
                                                        userData!.avatar,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    )),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 60),
                                                  child: IconButton(
                                                    color:
                                                    Colors.deepPurpleAccent,
                                                    icon: const Icon(
                                                        Icons.camera_alt,
                                                        size: 30),
                                                    onPressed: () {
                                                      getImage();
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
                                                    initialValue: userData!.name,
                                                    validator: (val) {
                                                      return val!.isEmpty
                                                          ? 'Vui lòng cung cấp tên của bạn'
                                                          : null;
                                                    },
                                                    onChanged: (val) {
                                                      setState(() => name = val);
                                                    },
                                                    hintText: 'Tên của bạn',
                                                    icon: Icons.face,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                              child: RoundedDropDown(
                                                value: userData.gender,
                                                validator: (val) {
                                                  return val.isEmpty
                                                      ? 'Vui lòng cung cấp giới tính chính xác'
                                                      : null;
                                                },
                                                items: _genderType
                                                    .map((value) => DropdownMenuItem(
                                                  child: Text(
                                                    value,
                                                  ),
                                                  value: value,
                                                ))
                                                    .toList(),
                                                onChanged: (selectedGender) {
                                                  setState(() {
                                                    selectedGenderType =
                                                        selectedGender;
                                                  });
                                                },
                                                isExpanded: false,
                                                hintText: 'Chọn giới tính',
                                                icon:
                                                userData.gender == _genderType[0]
                                                    ? Icons.male
                                                    : Icons.female,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: RoundedDropDown(
                                              value: userData.major,
                                              validator: (val) {
                                                return val!.isEmpty
                                                    ? 'Vui lòng cung cấp ngành học'
                                                    : null;
                                              },
                                              items: _majorsType
                                                  .map(
                                                      (value) => DropdownMenuItem(
                                                    child: Text(
                                                      value,
                                                    ),
                                                    value: value,
                                                  ))
                                                  .toList(),
                                              onChanged: (selectedBlock) {
                                                setState(() {
                                                  selectedMajorType =
                                                      selectedBlock;
                                                });
                                              },
                                              isExpanded: false,
                                              hintText: 'Chọn ngành học',
                                              icon: Icons.work,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: RoundedInputField(
                                              // maxLines: 3,
                                              initialValue: userData.bio,
                                              onChanged: (val) {
                                                setState(() => bio = val);
                                              },
                                              validator: (value) {},
                                              icon: Icons.favorite,
                                              hintText: 'Bio',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                              child: RoundedDropDown(
                                                value: userData.course == ""
                                                    ? null
                                                    : userData.course,
                                                validator: (val) {
                                                  return val == null
                                                      ? 'Vui lòng cung cấp khóa học'
                                                      : null;
                                                },
                                                items: _courses
                                                    .map((value) => DropdownMenuItem(
                                                  child: Text(
                                                    value,
                                                  ),
                                                  value: value,
                                                ))
                                                    .toList(),
                                                onChanged: (val) {
                                                  setState(() {
                                                    selectedcourse = val;
                                                  });
                                                },
                                                isExpanded: false,
                                                hintText: 'Chọn khóa',
                                                icon: Icons.school,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                              child: RoundedInputField(
                                                initialValue: userData.media,
                                                validator: (val) {
                                                  return val.isEmpty
                                                      ? 'Vui lòng cung cấp playlist'
                                                      : null;
                                                },
                                                onChanged: (val) {
                                                  setState(() => media = val);
                                                },
                                                icon: Icons.playlist_play_outlined,
                                                hintText: 'Instagram',
                                              )),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: RoundedInputField(
                                              initialValue: userData.playlist,
                                              validator: (val) {
                                                return val.isEmpty
                                                    ? 'Nghệ sĩ ưa thích của bạn là?'
                                                    : null;
                                              },
                                              onChanged: (val) {
                                                setState(() => playlist = val);
                                              },
                                              hintText: 'Nghệ sĩ ưa thích',
                                              icon: FontAwesomeIcons.music,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: RoundedDropDown(
                                              value: userData.address == ""
                                                  ? null
                                                  : userData.address,
                                              validator: (val) {
                                                return val == null
                                                    ? 'Vui lòng cung cấp khóa hợp lệ'
                                                    : null;
                                              },
                                              items: _homeArea
                                                  .map(
                                                      (value) => DropdownMenuItem(
                                                      child: Text(
                                                        value,
                                                        style: const TextStyle(
                                                            color:
                                                            kPrimaryLightColor),
                                                      ),
                                                      value: value))
                                                  .toList(),
                                              onChanged: (selectedhome) {
                                                setState(() {
                                                  home = selectedhome;
                                                });
                                              },
                                              isExpanded: false,
                                              hintText: 'Tôi đến từ...',
                                              icon: FontAwesomeIcons.home,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      GestureDetector(
                                        onTap: () async {
                                          if (_formKey.currentState!.validate()) {
                                            setState(() {
                                              loading = true;
                                            });
                                            if (email == '') {
                                              email = userData.email;
                                            }
                                            if (name == '') {
                                              name = userData.name;
                                            }
                                            if (bio == '') {
                                              bio = userData.bio;
                                            }
                                            selectedGenderType = userData.gender;
                                            selectedMajorType = userData.major;
                                            if (_image == null) {
                                              y = userData.avatar;
                                            }
                                            media = userData.media;
                                            playlist = userData.playlist;
                                            selectedcourse = userData.course;
                                            home = userData.address;
                                            dynamic result =
                                            await updateUser(context);
                                          }
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
                                              color: const Color(0xFF373737)),
                                          child: Text('Xác nhận',
                                              style: simpleTextStyle()),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                    ],
                                  ),
                                ),
                              ),
                              loading
                                  ? Loading() : const Center()
                            ]

                          ),
                        ),
                      );
                    } else {
                      return Loading();
                    }
                  }),
            ),
          );
  }
}
