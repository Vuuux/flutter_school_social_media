import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/views/components/circle_avatar.dart';
import 'package:provider/provider.dart';
import '../../style/constants.dart';
import '../../models/user.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import 'edit_account_screen.dart';
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
  var personalEmail;
  late Stream photoStream;

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await DatabaseServices(uid: '')
        .followingRef
        .doc(personalEmail)
        .collection('userFollowing')
        .get();
    if (mounted) {
      setState(() {
        countTotalFollowings = querySnapshot.docs.length;
      });
    }
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await DatabaseServices(uid: '')
        .followerRef
        .doc(personalEmail)
        .collection('userFollowers')
        .get();
    if (mounted) {
      setState(() {
        countTotalFollowers = querySnapshot.docs.length;
      });
    }
  }

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
            title: 'Chỉnh sửa', performFunction: editUserProfile),
        createButtonTitleAndFunction(
            title: 'Đổi mật khẩu', performFunction: editUserPassword),
      ],
    );
  }

  Container createButtonTitleAndFunction(
      {required String title, required VoidCallback performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 0.5),
      child: FlatButton(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onPressed: performFunction,
        child: Container(
          width: MediaQuery.of(context).size.width / 2.5,
          height: 26.0,
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w300, fontSize: 12)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kPrimaryLightColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  editUserPassword() {
    Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: EditAccount()), ModalRoute.withName('EditAccount'));
  }

  editUserProfile() {
    Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: EditProfileScreen()),
        ModalRoute.withName('EditProfileScreen'));
  }


  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUser?>();
    //final hmmies = Provider.of<List<Ctuer>>(context);
    ScreenUtil.init(const BoxConstraints(
      maxWidth: 414,
      maxHeight: 869,
    ),
    designSize: const Size(360,690),
      orientation: Orientation.portrait
    );

    getAllFollowers();
    getAllFollowings();
    return StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user!.uid).userData,
        builder: (context, snapshot) {
          UserData? userData = snapshot.data;
          if (userData != null) {
            personalEmail = userData.email;
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                actions: <Widget>[
                  IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(
                      LineAwesomeIcons.alternate_sign_out,
                    ),
                    onPressed: () async {
                      await context.read<AuthService>().signOut();
                    },
                  ),
                ],
              ),
              body: Stack(
                  children: <Widget>[
                SingleChildScrollView(
                    child: Container(
                        decoration: BoxDecoration(
                          //color: Color(0xFF505050),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height),
                        child: Column(
                            children: <Widget>[
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
                                      const SizedBox(height: 10,),
                                      CustomCircleAvatar(image: Image.network(
                                        userData.avatar,
                                        fit: BoxFit.fill,
                                      )),
                                      const SizedBox(height: 15),
                                      Text(userData.name,
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
                            Container(
                              width:
                                  MediaQuery.of(context).size.width / 1.17,
                              padding: const EdgeInsets.only(top: 3, bottom: 3),
                              decoration: const BoxDecoration(
                                  color: kPrimaryLightColor ,
                                  borderRadius: BorderRadius.all(
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
                                        'Người theo dõi', countTotalFollowers),
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
                                        'Đang theo dõi', countTotalFollowings),
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
                                        'Fame', userData.fame),
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
                              const Text('C Ộ N G    Đ Ồ N G',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      color: kPrimaryColor)),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                  "Đại học Cần Thơ, " + "ngành " +
                                      userData.major
                                      ,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  )),
                              const SizedBox(height: 15),
                              const Text('S O C I A L   M E D I A ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      color: kPrimaryColor)),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(userData.media== ''
                                      ? 'Thêm thông tin bằng việc nhấp vào profile của bạn'
                                      :userData.media,
                                  style: userData.media== ''
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
                              Text(userData.course== ''
                                      ? 'Thêm thông tin cá nhân bằng cách click Edit icon'
                                      :userData.course,
                                  style: userData.course== ''
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
                              Text(userData.playlist== ''
                                      ? 'Thêm thông tin cá nhân bằng cách click vào nút Chỉnh sửa'
                                      :userData.playlist,
                                  style: userData.playlist== ''
                                      ? const TextStyle(
                                          fontSize: 10, color: Colors.grey)
                                      : const TextStyle(
                                    fontSize: 15,
                                  )),
                              SizedBox(
                                height: kSpacingUnit.w,
                              ),
                              const Text('Q U Ê  Q U Á N',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      color: kPrimaryColor)),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(userData.address== ''
                                      ? 'Thêm thông tin cá nhân bằng cách click vào nút Chỉnh sửa'
                                      :userData.address,
                                  style:userData.address== ''
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
                            StreamBuilder<QuerySnapshot>(
                            stream:
                                DatabaseServices(uid: user.uid).getPhotos(),
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
                                            itemCount: snapshot
                                                    .data!.docs.length +
                                                1,
                                            itemBuilder: (context, index) {
                                              if (index ==
                                                  snapshot.data!.docs.length) {
                                                return Column(
                                                  children: <Widget>[
                                                    const Text(
                                                        'Thêm ảnh vào profile của bạn'),
                                                    IconButton(
                                                      icon: const Icon(
                                                          LineAwesomeIcons
                                                              .plus_circle),
                                                      onPressed: () {
                                                        Navigator.of(
                                                                context)
                                                            .pushAndRemoveUntil(
                                                          FadeRoute(
                                                              page:
                                                                  addPictures()),
                                                          ModalRoute.withName(
                                                              'Addpicture'),
                                                        );
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
                                                onPressed: () {},
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
                                                      trailingIcon: const Icon(
                                                          Icons.delete),
                                                      onPressed: () {
                                                        DatabaseServices(uid: '')
                                                            .ctuerRef
                                                            .doc(
                                                                user.uid)
                                                            .collection(
                                                                'photos')
                                                            .get()
                                                            .then((doc) {
                                                          if (doc
                                                              .docs[
                                                                  index]
                                                              .exists) {
                                                            doc
                                                                .docs[
                                                                    index]
                                                                .reference
                                                                .delete();
                                                          }
                                                        });
                                                      },
                                                      backgroundColor:
                                                          Colors.redAccent)
                                                ],
                                                child: Container(
                                                  width: 150,
                                                  margin: const EdgeInsets.only(
                                                      right: 15),
                                                  height:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.30 -
                                                          50,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                20.0)),
                                                    child: Image.network(
                                                          snapshot
                                                              .data!
                                                              .docs[
                                                                  index]
                                                              .get('photo'),
                                                          fit: BoxFit.fill,
                                                        )
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                    )
                                  : Loading();
                            }),
                          ])
                        ])))
              ]),
            );
          } else {
            return Loading();
          }
        });
  }

  addPictures() {}
}


