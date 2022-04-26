import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/utils/take_images_util.dart';
import 'package:luanvanflutter/views/components/circle_avatar.dart';
import 'package:luanvanflutter/views/home/feed/post_detail.dart';
import 'package:luanvanflutter/views/home/feed/post_screen.dart';
import 'package:luanvanflutter/views/home/feed/upload_image_screen.dart';
import 'package:provider/provider.dart';
import '../../../style/constants.dart';
import '../../../models/user.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'edit_anon_profile_screen.dart';

//Class quản lý thông tin user
class AnonProfile extends StatefulWidget {
  const AnonProfile({Key? key}) : super(key: key);

  @override
  _AnonProfileState createState() => _AnonProfileState();
}

class _AnonProfileState extends State<AnonProfile> {
  late String userUid;

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w200),
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
            performFunction: () => editUserProfile(userData)),
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
              style:
                  const TextStyle(fontWeight: FontWeight.w300, fontSize: 12)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kPrimaryLightColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  editUserProfile(UserData userData) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditProfileScreen(
              userData: userData,
            )));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    userUid = user!.uid;
    ScreenUtil.init(
        const BoxConstraints(
          maxWidth: 414,
          maxHeight: 869,
        ),
        designSize: const Size(360, 690),
        orientation: Orientation.portrait);

    return StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user.uid).userData,
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
              ),
              body: SingleChildScrollView(
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
                                        const SizedBox(height: 15),
                                        Text(userData.nickname,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: kPrimaryColor)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
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
                                const Text('V Ề  T Ô I',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                        color: kPrimaryColor)),
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
                                const Text('S O C I A L   M E D I A ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                        color: kPrimaryColor)),
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
                                  height: kSpacingUnit.w,
                                ),
                                const Text('K H O Á',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                        color: kPrimaryColor)),
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
                                  height: kSpacingUnit.w,
                                ),
                                const Text('P L A Y L I S T',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                        color: kPrimaryColor)),
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
                                  height: kSpacingUnit.w,
                                ),
                              ],
                            ),
                          ),
                          //GRID VIEW IMAGE
                          StreamBuilder<QuerySnapshot>(
                              stream: Stream.fromFuture(
                                  DatabaseServices(uid: user.uid).getMyPosts()),
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
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  snapshot.data!.docs.length,
                                              itemBuilder: (context, index) {
                                                var post = PostItem(
                                                  post: PostModel(
                                                      postId: snapshot
                                                          .data!.docs[index]
                                                          .get('postId'),
                                                      ownerId: snapshot
                                                          .data!.docs[index]
                                                          .get('ownerId'),
                                                      username: snapshot
                                                          .data!.docs[index]
                                                          .get('username'),
                                                      location: snapshot
                                                          .data!.docs[index]
                                                          .get('location'),
                                                      description: snapshot
                                                          .data!.docs[index]
                                                          .get('description'),
                                                      url: snapshot
                                                          .data!.docs[index]
                                                          .get('url'),
                                                      likes: snapshot.data!.docs[index].get('likes'),
                                                      timestamp: snapshot.data!.docs[index].get('timestamp')),
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
                                                              context: context,
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
                                                                      postId: post
                                                                          .post
                                                                          .postId,
                                                                      ownerId:
                                                                          user.uid,
                                                                    )));
                                                  },
                                                  menuItems: <FocusedMenuItem>[
                                                    FocusedMenuItem(
                                                        title: const Text(
                                                          "Xóa ảnh",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
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
                                                                Radius.circular(
                                                                    20.0)),
                                                        child: Image.network(
                                                          post.post.url,
                                                          fit: BoxFit.fill,
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
            );
          } else {
            return Loading();
          }
        });
  }
}
