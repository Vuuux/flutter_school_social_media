import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/take_images_util.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/components/circle_avatar.dart';
import 'package:luanvanflutter/views/home/feed/post_detail.dart';
import 'package:luanvanflutter/views/home/feed/post_screen.dart';
import 'package:luanvanflutter/views/home/feed/post_review_screen.dart';
import 'package:provider/provider.dart';
import '../../../style/constants.dart';
import '../../../models/user.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import 'edit_password_screen.dart';
import 'edit_profile_screen.dart';

//Class quản lý thông tin user
class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  late String userUid;
  late Stream<UserData?> userStream;

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await DatabaseServices(uid: '')
        .followingReference
        .doc(userUid)
        .collection('userFollowings')
        .get();
    if (mounted) {
      setState(() {
        countTotalFollowings = querySnapshot.docs.length;
      });
    }
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await DatabaseServices(uid: '')
        .followerReference
        .doc(userUid)
        .collection('userFollowers')
        .get();
    if (mounted) {
      setState(() {
        countTotalFollowers = querySnapshot.docs.length;
      });
    }
  }

  Column createColumns(String title, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 15.0, fontWeight: FontWeight.w600, color: color),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 12.0, fontWeight: FontWeight.w200, color: color),
          ),
        )
      ],
    );
  }

  createButton(UserData userData) {
    return Row(
      children: <Widget>[
        createButtonTitleAndFunction(
            title: 'Chỉnh sửa',
            performFunction: () => _editUserProfile(userData)),
        createButtonTitleAndFunction(
            title: 'Đổi mật khẩu', performFunction: _editUserPassword),
      ],
    );
  }

  Container createButtonTitleAndFunction(
      {required String title, required VoidCallback performFunction}) {
    return Container(
      padding: const EdgeInsets.only(top: 0.5),
      child: FlatButton(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onPressed: performFunction,
        child: Container(
          width: MediaQuery.of(context).size.width / 2.5,
          height: 26.0,
          child: Text(title,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 12,
                color: Get.isDarkMode ? Colors.black : Colors.white,
              )),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? kPrimaryDarkColor
                : Get.isDarkMode
                    ? kPrimaryDarkColor
                    : kPrimaryColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  _editUserPassword() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const EditPassword()));
  }

  _editUserProfile(UserData userData) {
    Get.to(() => EditProfileScreen(userData: userData));
  }

  _sendEmailVerification() async {
    var response = await context.read<AuthService>().sendVerificationEmail();
    response.fold((left) {
      if (left) {
        Get.snackbar("Đã gửi",
            "Email xác thực đã được gửi tới hòm thư của bạn. Vui lòng kiểm tra. Sau khi đã xác thực hãy đăng nhập lại ứng dụng",
            snackPosition: SnackPosition.BOTTOM);
      } else
        Get.snackbar("Lỗi", "Không thể gửi email",
            snackPosition: SnackPosition.BOTTOM);
    },
        (right) => Get.snackbar(
            "Lỗi!", "Có lỗi xảy ra trong quá trình xác thực:" + right.code,
            snackPosition: SnackPosition.BOTTOM));
  }

  @override
  void initState() {
    super.initState();
    var data = UserDataService().getUserData();
    userStream = DatabaseServices(uid: data!.id).userData;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    userUid = user!.uid;
    // ScreenUtil.init(
    //     const BoxConstraints(
    //       maxWidth: 414,
    //       maxHeight: 869,
    //     ),
    //     context: context,
    //     designSize: const Size(360, 690),
    //     orientation: Orientation.portrait);

    getAllFollowers();
    getAllFollowings();
    return StreamBuilder<UserData?>(
        stream: userStream,
        builder: (context, snapshot) {
          UserData? userData = snapshot.data;
          if (userData != null) {
            userUid = userData.email;
            return Scaffold(
              appBar: AppBar(
                title: const Text("C Á   N H Â N"),
                centerTitle: true,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15),
                )),
                elevation: 0,
                actions: <Widget>[
                  IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(
                      LineAwesomeIcons.alternate_sign_out,
                    ),
                    onPressed: () async {
                      Get.dialog(
                          AlertDialog(
                            title:
                                const Text('Bạn chắc chắn muốn đăng xuất chứ?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  await context.read<AuthService>().signOut();
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Xác nhận'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                          name: "Đăng xuất :(");
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  userStream = DatabaseServices(uid: user.uid).userData;
                  return;
                },
                child: SingleChildScrollView(
                    child: Container(
                        decoration: BoxDecoration(
                          //color: Color(0xFF505050),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height),
                        child: Column(children: <Widget>[
                          Column(children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          CustomCircleAvatar(
                                              image: Image.network(
                                            userData.avatar,
                                            fit: BoxFit.fill,
                                          )),
                                          SizedBox(
                                              height: Dimen.paddingCommon10),
                                          Text(userData.username,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              )),
                                          GestureDetector(
                                            onTap: !userData.verified
                                                ? _sendEmailVerification
                                                : () {},
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  userData.verified
                                                      ? "assets/images/verified.png"
                                                      : "assets/images/unverified.png",
                                                  height: 32,
                                                  width: 32,
                                                ),
                                                Text(
                                                    userData.verified
                                                        ? "Đã xác thực"
                                                        : "Chưa xác thực",
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: userData.verified
                                                            ? kStudyColor
                                                            : kErrorColor)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.17,
                                  padding:
                                      const EdgeInsets.only(top: 3, bottom: 3),
                                  decoration: BoxDecoration(
                                      color: Get.isDarkMode
                                          ? kPrimaryDarkColor
                                          : Get.isDarkMode
                                              ? kPrimaryDarkColor
                                              : kPrimaryColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(15),
                                      )),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    //crossAxisAlignment: CrossAxisAlignment.baseline,
                                    children: <Widget>[
                                      FlatButton(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          padding: const EdgeInsets.only(
                                              left: 21, right: 21),
                                          child: createColumns(
                                              'Người theo dõi',
                                              countTotalFollowers,
                                              Get.isDarkMode
                                                  ? Colors.black
                                                  : Colors.white),
                                          onPressed: () {}
                                          //TODO: ADD FOLLOWER LIST
                                          // =>
                                          //     Navigator.of(context)
                                          //     .pushAndRemoveUntil(
                                          //   FadeRoute(
                                          //       page: FollowersList(
                                          //           ctuerList: hmmies,
                                          //           userData: userData)),
                                          //   ModalRoute.withName('FollowersList'),
                                          // ),
                                          ),
                                      FlatButton(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          padding: const EdgeInsets.only(
                                              left: 21, right: 21),
                                          child: createColumns(
                                              'Đang theo dõi',
                                              countTotalFollowings,
                                              Get.isDarkMode
                                                  ? Colors.black
                                                  : Colors.white),
                                          onPressed: () {}
                                          // TODO: ADD FOLLOWING LIST
                                          // => Navigator.of(context)
                                          //     .pushAndRemoveUntil(
                                          //   FadeRoute(
                                          //       page: FollowingList(
                                          //           ctuerList: hmmies,
                                          //           userData: userData)),
                                          //   ModalRoute.withName('FollowingList'),
                                          // ),
                                          ),
                                      FlatButton(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        padding: const EdgeInsets.only(
                                            left: 21, right: 21),
                                        child: createColumns(
                                            'Fame',
                                            userData.likes.length,
                                            Get.isDarkMode
                                                ? Colors.black
                                                : Colors.white),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          createButton(userData),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('V Ề  T Ô I',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Get.isDarkMode
                                              ? kPrimaryDarkColor
                                              : kPrimaryColor)),
                                  Text(
                                      userData.bio == ''
                                          ? 'Thêm thông tin bằng cách click vào nút Chỉnh sửa'
                                          : userData.bio,
                                      style: userData.bio == ''
                                          ? const TextStyle(
                                              fontSize: 12, color: Colors.grey)
                                          : const TextStyle(
                                              fontSize: 18,
                                            )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text('C Ộ N G    Đ Ồ N G',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Get.isDarkMode
                                              ? kPrimaryDarkColor
                                              : kPrimaryColor)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      "Đại học Cần Thơ, " +
                                          "ngành " +
                                          userData.major,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      )),
                                  const SizedBox(height: 15),
                                  Text('Y Ê U   T H Í C H ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Get.isDarkMode
                                              ? kPrimaryDarkColor
                                              : kPrimaryColor)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      userData.media == ''
                                          ? 'Thêm thông tin bằng việc nhấp vào profile của bạn'
                                          : userData.media,
                                      style: userData.media == ''
                                          ? const TextStyle(
                                              fontSize: 12, color: Colors.grey)
                                          : const TextStyle(
                                              fontSize: 18,
                                            )),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  Text('K H O Á',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Get.isDarkMode
                                              ? kPrimaryDarkColor
                                              : kPrimaryColor)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      userData.course == ''
                                          ? 'Thêm thông tin cá nhân bằng cách click Edit icon'
                                          : userData.course,
                                      style: userData.course == ''
                                          ? const TextStyle(
                                              fontSize: 10, color: Colors.grey)
                                          : const TextStyle(
                                              fontSize: 15,
                                            )),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  Text('M E D I A',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Get.isDarkMode
                                              ? kPrimaryDarkColor
                                              : kPrimaryColor)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      userData.playlist == ''
                                          ? 'Thêm thông tin cá nhân bằng cách click vào nút Chỉnh sửa'
                                          : userData.playlist,
                                      style: userData.playlist == ''
                                          ? const TextStyle(
                                              fontSize: 10, color: Colors.grey)
                                          : const TextStyle(
                                              fontSize: 15,
                                            )),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  Text('Q U Ê  Q U Á N',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Get.isDarkMode
                                              ? kPrimaryDarkColor
                                              : kPrimaryColor)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      userData.address == ''
                                          ? 'Thêm thông tin cá nhân bằng cách click vào nút Chỉnh sửa'
                                          : userData.address,
                                      style: userData.address == ''
                                          ? const TextStyle(
                                              fontSize: 10, color: Colors.grey)
                                          : const TextStyle(
                                              fontSize: 15,
                                            )),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                ],
                              ),
                            ),
                            //GRID VIEW IMAGE
                            StreamBuilder<QuerySnapshot>(
                                stream: Stream.fromFuture(
                                    DatabaseServices(uid: user.uid)
                                        .getMyPosts()),
                                builder: (context, snapshot) {
                                  return snapshot.hasData
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.30 -
                                                50,
                                            child: ListView.builder(
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) {
                                                  PostModel post = PostModel
                                                      .fromDocumentSnapshot(
                                                    snapshot.data!.docs[index],
                                                  );

                                                  Map<dynamic, dynamic> likes =
                                                      snapshot.data!.docs[index]
                                                          .get('likes');
                                                  if (index ==
                                                      snapshot
                                                          .data!.docs.length) {
                                                    return Column(
                                                      children: <Widget>[
                                                        const Text(
                                                            'Thêm ảnh vào profile của bạn'),
                                                        IconButton(
                                                          icon: const Icon(
                                                              LineAwesomeIcons
                                                                  .plus_circle),
                                                          onPressed: () {
                                                            ChooseImage(
                                                                context:
                                                                    context,
                                                                userData:
                                                                    userData);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                  return FocusedMenuHolder(
                                                    menuWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.36,
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      PostDetail(
                                                                        postId:
                                                                            post.postId,
                                                                        ownerId:
                                                                            user.uid,
                                                                      )));
                                                    },
                                                    menuItems: <
                                                        FocusedMenuItem>[
                                                      FocusedMenuItem(
                                                          title: const Text(
                                                            "Xóa ảnh",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12),
                                                          ),
                                                          trailingIcon:
                                                              const Icon(
                                                                  Icons.delete),
                                                          onPressed: () {
                                                            DatabaseServices(
                                                                    uid: '')
                                                                .deletePhotos(
                                                                    user.uid,
                                                                    index);
                                                          },
                                                          backgroundColor:
                                                              Colors.redAccent)
                                                    ],
                                                    child: Container(
                                                      width: 150,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 15),
                                                      height:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .height *
                                                                  0.30 -
                                                              50,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          20.0)),
                                                          child: post.isVideo
                                                              ? Icon(Icons
                                                                  .play_arrow)
                                                              : Image.network(
                                                                  post.url[0],
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                    ),
                                                  );
                                                }),
                                          ),
                                        )
                                      : Loading();
                                }),
                          ])
                        ]))),
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
