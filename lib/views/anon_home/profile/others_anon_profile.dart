import 'dart:io';

import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/components/circle_avatar.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'anon_follower_list.dart';
import 'anon_following_list.dart';

//Xem profile người khác
class OthersAnonProfile extends StatefulWidget {
  final ctuerId;
  UserData? ctuer;
  CurrentUserId? currentUser;
  Stream<DocumentSnapshot>? userDataStream;
  OthersAnonProfile({Key? key, required this.ctuerId}) : super(key: key);

  @override
  _OthersAnonProfileState createState() => _OthersAnonProfileState();
}

class _OthersAnonProfileState extends State<OthersAnonProfile> {
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  bool following = false;
  late String toggleFollow;
  DatabaseServices dbServer = DatabaseServices(uid: '');
  bool acceptedRequest = false;
  bool sentreRequest = false;

  @override
  void initState() {
    super.initState();
    widget.userDataStream = Stream.fromFuture(
        DatabaseServices(uid: widget.ctuerId).getUserByUserId());
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await dbServer.followingReference
        .doc(widget.ctuerId)
        .collection('userFollowings')
        .get();
    if (mounted) {
      setState(() {
        countTotalFollowings = querySnapshot.docs.length;
      });
    }
  }

  checkIfAlreadyFollowing() async {
    await dbServer.followerReference
        .doc(widget.ctuer!.id)
        .collection('userFollowers')
        .doc(widget.currentUser!.uid)
        .get()
        .then((value) => {
              if (mounted)
                {
                  setState(() {
                    if (value.exists) {
                      following = value.exists;
                      sentreRequest = value.exists;
                      acceptedRequest = value.exists;
                    }
                  })
                }
            });
  }

  //TODO: CHECK IF FOLLOW REQUEST ACCEPTED
  checkIfSentreRequest(UserData currentUser) async {
    await dbServer
        .getSpecificNotifications(widget.ctuer!.id, widget.currentUser!.uid)
        .then((value) => {
              if (value.exists)
                {
                  sentreRequest = value.exists,
                  dbServer
                      .getSpecificFollower(
                          widget.ctuer!.id, widget.currentUser!.uid)
                      .then((val) {
                    if (!(val.exists)
                        //&&
                        //value.data()!['status'] == 'accepted'
                        ) {
                      if (mounted) {
                        setState(() {
                          following = true;
                          sentreRequest = true;
                          acceptedRequest = true;
                          toggleFollow = "Unfollow";

                          getAllFollowers();
                          getAllFollowings();
                          checkIfAlreadyFollowing();
                        });
                        //controlFollowUser(currentUser);
                      }
                    }
                  })
                }
            });
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await dbServer.followerReference
        .doc(widget.ctuerId)
        .collection('userFollowers')
        .get();
    if (mounted) {
      setState(() {
        countTotalFollowers = querySnapshot.docs.length;
      });
    }
  }

  createFollowButton(UserData userData) {
    bool ownProfile = userData.id == widget.ctuer!.id;

    sentreRequest
        ? acceptedRequest
            ? (toggleFollow = 'Bỏ theo dõi')
            : (toggleFollow = 'Đã yêu cầu')
        : (toggleFollow = 'Theo dõi');

    if (ownProfile) {
      return Row(
        children: <Widget>[
          createButtonTitleAndFunction(
              title: 'Sửa Profile',
              performFunction: () {}, //TODO: editUserProfile,
              userData: userData),
          createButtonTitleAndFunction(
              title: 'Đổi mật khẩu',
              performFunction: () {},
              //TODO: editUserPassword,
              userData: userData),
        ],
      );
    } else {
      return createButtonTitle(
          title: toggleFollow, userData: userData, performFunction: () {});
    }
  }

  createButtonTitle(
      {required String title,
      required Function performFunction,
      required UserData userData}) {
    return Container(
      padding: const EdgeInsets.only(top: 0.5),
      child: FlatButton(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onPressed: () => sentreRequest
            ? acceptedRequest
                ? controlUnfollowUser(userData)
                : deleteOldRequest(userData)
            : sendRequest(userData),
        child: Container(
          width: MediaQuery.of(context).size.width / 2.5,
          height: 35.0,
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  //unfollow user
  controlUnfollowUser(UserData userData) {
    dbServer.followerReference
        .doc(widget.ctuer!.id)
        .collection('userFollowers')
        .doc(userData.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
        if (mounted) {
          setState(() {
            following = false;
            sentreRequest = false;
            acceptedRequest = false;
            toggleFollow = "Follow";

            getAllFollowers();
            getAllFollowings();
            checkIfAlreadyFollowing();
          });
        }
      }
    });

    dbServer.followingReference
        .doc(userData.id)
        .collection('userFollowings')
        .doc(widget.ctuer!.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    dbServer.feedReference
        .doc(widget.ctuer!.id)
        .collection('feedItems')
        .doc(userData.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  sendRequest(UserData userData) async {
    print('request');
    if (this.mounted) {
      setState(() {
        sentreRequest = true;
      });
    }
    String notifId = const Uuid().v4();
    dbServer.addNotifiCation(widget.ctuer!.id, userData.id, notifId, {
      'notifId': notifId,
      'type': 'request',
      'timestamp': DateTime.now(),
      'avatar': userData.avatar,
      'username': userData.username,
      'status': 'requesting',
      'seenStatus': false,
      'userId': userData.id
    });

    // Stream<QuerySnapshot> query = await dbServer.getRequestStatus(
    //     widget.ctuer.id,
    //     userData.id);
    //
    // query.forEach((event) {
    //   if (event.docs[0].get('status') == 'accepted') {
    //     controlFollowUser(userData);
    //     print('User accepted follow request');
    //
    //     if (mounted) {
    //       setState(() {
    //         following = true;
    //         sentreRequest = true;
    //         acceptedRequest = true;
    //         toggleFollow = "Unfollow";
    //
    //         getAllFollowers();
    //         getAllFollowings();
    //         checkIfAlreadyFollowing();
    //       });
    //     }
    //   }
    // });
  }

  deleteOldRequest(UserData userData) async {
    print('retracted');
    if (mounted) {
      setState(() {
        following = false;
        sentreRequest = false;
        acceptedRequest = false;
        toggleFollow = "Follow";
      });
    }
    dbServer.deleteNotification(widget.ctuer!.id, userData.id);
  }

  //follow user
  controlFollowUser(UserData userData) {
    dbServer.addFollowing(userData.id, widget.ctuer!.id, {
      'username': widget.ctuer!.username,
      'avatar': widget.ctuer!.avatar,
    });

    dbServer.addFollower(userData.id, widget.ctuer!.id, {
      'username': userData.username,
      'avatar': userData.avatar,
    });
    //ADD NOTIFICATION TO OWNER
  }

  Container createButtonTitleAndFunction(
      {required String title,
      required Function performFunction,
      required UserData userData}) {
    return Container(
      padding: EdgeInsets.only(top: 0.5),
      child: FlatButton(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onPressed: performFunction(),
        child: Container(
          width: MediaQuery.of(context).size.width / 2.5,
          height: 26.0,
          child: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w200, fontSize: 12)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF373737),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.currentUser = context.watch<CurrentUserId?>();
    if (mounted) {}

    ScreenUtil.init(
        const BoxConstraints(
          maxWidth: 414,
          maxHeight: 869,
        ),
        designSize: const Size(360, 690),
        orientation: Orientation.portrait);
    return StreamBuilder<UserData?>(
        stream: DatabaseServices(uid: widget.currentUser!.uid).userData,
        builder: (context, snapshot) {
          UserData? userData = snapshot.data;
          if (userData != null) {
            return StreamBuilder<DocumentSnapshot>(
                stream: widget.userDataStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Loading();
                  } else {
                    if (snapshot.hasData) {
                      widget.ctuer =
                          UserData.fromDocumentSnapshot(snapshot.data!);
                      getAllFollowers();
                      getAllFollowings();
                      checkIfAlreadyFollowing();
                      checkIfSentreRequest(userData);
                    }
                  }
                  return Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: const Icon(LineAwesomeIcons.home),
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            FadeRoute(page: Wrapper()),
                            ModalRoute.withName('Wrapper'),
                          );
                        },
                      ),
                      elevation: 0,
                    ),
                    body: Stack(children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(),
                        ],
                      ),
                      SingleChildScrollView(
                          child: Container(
                              decoration: BoxDecoration(
                                //color: Color(0xFF505050),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height),
                              child: Column(children: <Widget>[
                                Column(children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: <Widget>[
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                CustomCircleAvatar(
                                                    image: Image.network(
                                                  widget.ctuer!.avatar,
                                                  fit: BoxFit.fill,
                                                )),
                                                const SizedBox(height: 15),
                                                Text(
                                                  widget.ctuer!.username,
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: kPrimaryColor),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.17,
                                        padding: const EdgeInsets.only(
                                          top: 3,
                                          bottom: 3,
                                        ),
                                        decoration: const BoxDecoration(
                                            color: kPrimaryColor,
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
                                                highlightColor:
                                                    Colors.transparent,
                                                splashColor: Colors.transparent,
                                                padding: const EdgeInsets.only(
                                                    left: 21, right: 21),
                                                child: createColumns(
                                                    'Followers',
                                                    countTotalFollowers),
                                                onPressed: (widget.currentUser!
                                                                .uid ==
                                                            widget.ctuer!.id ||
                                                        following)
                                                    ?
                                                    //TODO: ADD FOLLOWER LIST VIEW
                                                    //       () => Navigator.of(context)
                                                    //     .pushAndRemoveUntil(
                                                    //   FadeRoute(
                                                    //       page: FollowerList(
                                                    //           ctuerList: hmmies,
                                                    //           user: userData)
                                                    //   ),
                                                    //   ModalRoute.withName('FollowersList'),
                                                    // )
                                                    //:
                                                    () =>
                                                        print('tried pressing')
                                                    : () {}),
                                            FlatButton(
                                                highlightColor:
                                                    Colors.transparent,
                                                splashColor: Colors.transparent,
                                                padding: const EdgeInsets.only(
                                                    left: 21, right: 21),
                                                child: createColumns(
                                                    'Following',
                                                    countTotalFollowings),
                                                onPressed: (widget.currentUser!
                                                                .uid ==
                                                            widget.ctuer!.id ||
                                                        following)
                                                    ?
                                                    //TODO: ADD FOLLOWING LIST VIEW
                                                    //       () => Navigator.of(context)
                                                    //     .pushAndRemoveUntil(
                                                    //   FadeRoute(
                                                    //       page: FollowingList(
                                                    //           ctuerList: hmmies,
                                                    //           user: userData)),
                                                    //   ModalRoute.withName('FollowingList'),
                                                    // )
                                                    //      :
                                                    () =>
                                                        print('tried pressing')
                                                    : () {}),
                                            FlatButton(
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Colors.transparent,
                                              padding: const EdgeInsets.only(
                                                  left: 21, right: 21),
                                              child: createColumns('Fame',
                                                  widget.ctuer!.likes.length),
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
                                                createFollowButton(userData),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  (widget.currentUser!.uid ==
                                              widget.ctuer!.id ||
                                          following)
                                      ? Container(
                                          padding: EdgeInsets.all(15),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              const Text('V Ề  T Ô I',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: kPrimaryColor)),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(widget.ctuer!.bio,
                                                  //' hiiiiiiGreyscale, also known as, is a dreaded and usually fatal dis',
                                                  //"Greyscale, also known as, is a dreaded and usually fatal disease that can leave flesh stiff and dead, and the skin cracked and flaking, and stone-like to the touch. Those that manage to survive a bout with the illness will be immune from ever contracting it again, but the flesh damaged by the ravages of the disease will never heal, and they will be scarred for life. Princess Shireen Baratheon caught greyscale as an infant and survived, but the ordeal left half of her face disfigured by the disease.[2]",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  )),
                                              SizedBox(
                                                height: kSpacingUnit.w,
                                              ),
                                              const Text('C Ộ N G   Đ Ồ N G',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: kPrimaryColor)),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  "Đại học Cần Thơ, " +
                                                      "ngành " +
                                                      widget.ctuer!.major,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  )),
                                              SizedBox(
                                                height: kSpacingUnit.w,
                                              ),
                                              const Text(
                                                  'S O C I A L   M E D I A ',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: kPrimaryColor)),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(widget.ctuer!.media,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  )),
                                              SizedBox(
                                                height: kSpacingUnit.w,
                                              ),
                                              const Text('K H O Á',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: kPrimaryColor)),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(widget.ctuer!.course,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  )),
                                              SizedBox(
                                                height: kSpacingUnit.w,
                                              ),
                                              const Text('P L A Y L I S T',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: kPrimaryColor)),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(widget.ctuer!.playlist,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  )),
                                              SizedBox(
                                                height: kSpacingUnit.w,
                                              ),
                                              const Text('S Ố N G  Ở',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: kPrimaryColor)),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(widget.ctuer!.address,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  )),
                                              SizedBox(
                                                height: kSpacingUnit.w,
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(20),
                                          child: Text(
                                              'THEO DÕI ' +
                                                  widget.ctuer!.username +
                                                  ' ĐỂ HIỂN THỊ PROFILE',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w300,
                                                  color: kPrimaryColor)),
                                        ),
                                  (widget.currentUser!.uid ==
                                              widget.ctuer!.id ||
                                          following)
                                      ? StreamBuilder<QuerySnapshot>(
                                          stream: DatabaseServices(
                                                  uid: widget.ctuer!.id)
                                              .getPhotos(),
                                          builder: (context, snapshot) {
                                            return snapshot.hasData
                                                ? SizedBox(
                                                    height: MediaQuery.of(
                                                                    context)
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
                                                            .data!.docs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Container(
                                                              width: 150,
                                                              margin: const EdgeInsets
                                                                      .only(
                                                                  right: 20),
                                                              height: MediaQuery.of(
                                                                              context)
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
                                                                child: Image
                                                                    .network(
                                                                  snapshot
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                      .get(
                                                                          'photo'),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ));
                                                        }))
                                                : Loading();
                                          })
                                      : Container()
                                ])
                              ])))
                    ]),
                  );
                });
          } else {
            return Loading();
          }
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
        style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
      ),
      Container(
        margin: EdgeInsets.only(top: 5.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w200),
        ),
      )
    ],
  );
}
