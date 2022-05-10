import 'dart:io';

import 'package:eventual/eventual-builder.dart';
import 'package:eventual/eventual-notifier.dart';
import 'package:eventual/eventual-single-builder.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/notification.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/components/circle_avatar.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'follower_list.dart';
import 'following_list.dart';

//Xem profile người khác
class OthersProfile extends StatefulWidget {
  final ctuerId;
  final String? notifId;

  UserData? ctuer;
  CurrentUserId? currentUser;
  Stream<DocumentSnapshot>? ctuerDataStream;
  OthersProfile({Key? key, required this.ctuerId, this.notifId})
      : super(key: key);

  @override
  _OthersProfileState createState() => _OthersProfileState();
}

class _OthersProfileState extends State<OthersProfile> {
  List<SubUserData> followers = [];
  List<SubUserData> followings = [];
  DatabaseServices dbServer = DatabaseServices(uid: '');
  late UserData currentUserData;
  EventualNotifier<bool> isAlreadyFollowing = EventualNotifier(false);
  EventualNotifier<bool> isSentRequest = EventualNotifier(false);
  String requestNotifId = "";
  @override
  void initState() {
    super.initState();
    currentUserData = UserDataService().getUserData()!;
    widget.ctuerDataStream = Stream.fromFuture(
        DatabaseServices(uid: widget.ctuerId).getUserByUserId());
    requestNotifId = widget.notifId ?? "";
    Future.delayed(const Duration(milliseconds: 200), () async {
      await getAllFollowers();
      await getAllFollowings();
      isAlreadyFollowing.value = checkAlreadyFollowing();
      if (!isAlreadyFollowing.value) {
        await checkIfSentRequest(currentUserData);
      }
    });
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await dbServer.followingReference
        .doc(widget.ctuerId)
        .collection('userFollowings')
        .get();
    if (mounted) {
      setState(() {
        followings = List<SubUserData>.from(querySnapshot.docs
            .map((doc) => SubUserData.fromDocumentSnapshot(doc)));
      });
    }
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await dbServer.followerReference
        .doc(widget.ctuerId)
        .collection('userFollowers')
        .get();
    if (mounted) {
      setState(() {
        followers = List<SubUserData>.from(querySnapshot.docs
            .map((doc) => SubUserData.fromDocumentSnapshot(doc)));
      });
    }
  }

  bool checkAlreadyFollowing() {
    bool isFollowing = false;
    for (var follower in followers) {
      if (follower.id == currentUserData.id) {
        isFollowing = true;
      }
    }
    return isFollowing;
  }

  checkIfSentRequest(UserData currentUser) async {
    NotificationModel? notifModel;
    if (requestNotifId.isNotEmpty) {
      var notifResponse = await dbServer.getSpecificNotifications(
          widget.ctuer!.id, (requestNotifId));
      notifModel = NotificationModel.fromDocument(notifResponse);
    } else {
      var notifResponse = await dbServer.getSpecificNotificationFromUser(
          widget.ctuer!.id, currentUser.id);
      notifModel = notifResponse.docs
          .map((e) => NotificationModel.fromDocument(e))
          .toList()
          .first;
      requestNotifId = notifModel.notifId;
    }

    if (notifModel != null) {
      if (notifModel.status == FollowStatus.REQUESTING) {
        isSentRequest.value = true;
      } else
        isSentRequest.value = false;
    }
    return;
  }

  Widget createFollowButton(UserData userData) => EventualBuilder(
      notifiers: [isAlreadyFollowing, isSentRequest],
      builder: (context, notifier, _) {
        return Container(
          padding: const EdgeInsets.only(top: 0.5),
          child: FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () => notifier[0].value
                ? controlUnfollowUser(userData)
                    ? notifier[1].value
                    : deleteOldRequest(userData)
                : sendRequest(userData),
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              height: 35.0,
              child: Text(
                  notifier[0].value
                      ? "Bỏ theo dõi"
                      : notifier[1].value
                          ? "Hủy yêu cầu"
                          : "Gửi yêu cầu",
                  style: TextStyle(
                      color: Get.isDarkMode ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        );
      });

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
          isAlreadyFollowing.value = false;
          isSentRequest.value = false;
          getAllFollowers();
          getAllFollowings();
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
        .doc(requestNotifId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  sendRequest(UserData userData) async {
    String notifId = const Uuid().v4();
    await dbServer.addNotifiCation(widget.ctuer!.id, userData.id, notifId, {
      'notifId': notifId,
      'type': 'request',
      'timestamp': DateTime.now(),
      'avatar': userData.avatar,
      'username': userData.username,
      'status': 'requesting',
      'seenStatus': false,
      'userId': userData.id,
      'isAnon': false
    }).then((value) => isSentRequest.value = true);
  }

  deleteOldRequest(UserData userData) async {
    await dbServer
        .deleteNotification(widget.ctuer!.id, userData.id)
        .then((value) => isSentRequest.value = false);
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
    return StreamBuilder<DocumentSnapshot>(
        stream: widget.ctuerDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else {
            if (snapshot.hasData) {
              widget.ctuer = UserData.fromDocumentSnapshot(snapshot.data!);
              checkIfSentRequest(currentUserData);
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
                                          widget.ctuer!.avatar,
                                          fit: BoxFit.fill,
                                        )),
                                        const SizedBox(height: 15),
                                        Text(
                                          widget.ctuer!.username,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Get.isDarkMode
                                                  ? kPrimaryDarkColor
                                                  : kPrimaryColor),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: MediaQuery.of(context).size.width / 1.17,
                                padding: const EdgeInsets.only(
                                  top: 3,
                                  bottom: 3,
                                ),
                                decoration: BoxDecoration(
                                    color: Get.isDarkMode
                                        ? kPrimaryDarkColor
                                        : kPrimaryColor,
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
                                            'Followers', followers.length),
                                        onPressed: () {
                                          Get.defaultDialog(
                                              title: "Người theo dõi",
                                              middleText: "Hello world!",
                                              backgroundColor: Colors.white,
                                              titleStyle: TextStyle(
                                                  color: Colors.black),
                                              middleTextStyle: TextStyle(
                                                  color: Get.isDarkMode
                                                      ? kPrimaryDarkColor
                                                      : kPrimaryColor),
                                              textCancel: "Đóng",
                                              cancelTextColor: Colors.black,
                                              buttonColor: Get.isDarkMode
                                                  ? kPrimaryDarkColor
                                                  : kPrimaryColor,
                                              barrierDismissible: false,
                                              radius: 50,
                                              content: Column(
                                                children: [
                                                  Container(
                                                      child: Text("Hello 1")),
                                                  Container(
                                                      child: Text("Hello 2")),
                                                  Container(
                                                      child: Text("Hello 3")),
                                                ],
                                              ));
                                        }),
                                    FlatButton(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        padding: const EdgeInsets.only(
                                            left: 21, right: 21),
                                        child: createColumns(
                                            'Following', followings.length),
                                        onPressed: () {
                                          Get.defaultDialog(
                                              title: "Người theo dõi",
                                              middleText: "Hello world!",
                                              backgroundColor: Colors.white,
                                              titleStyle: const TextStyle(
                                                  color: Colors.black),
                                              middleTextStyle: TextStyle(
                                                  color: Get.isDarkMode
                                                      ? kPrimaryDarkColor
                                                      : kPrimaryColor),
                                              textConfirm: "Confirm",
                                              textCancel: "Cancel",
                                              cancelTextColor: Colors.white,
                                              confirmTextColor: Colors.white,
                                              buttonColor: Colors.red,
                                              barrierDismissible: false,
                                              radius: 50,
                                              content: Column(
                                                children: [
                                                  Container(
                                                      child: Text("Hello 1")),
                                                  Container(
                                                      child: Text("Hello 2")),
                                                  Container(
                                                      child: Text("Hello 3")),
                                                ],
                                              ));
                                        }),
                                    FlatButton(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      padding: const EdgeInsets.only(
                                          left: 21, right: 21),
                                      child: createColumns(
                                          'Fame', widget.ctuer!.likes.length),
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
                                        createFollowButton(currentUserData),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          EventualSingleBuilder(
                              notifier: isAlreadyFollowing,
                              builder: (context, notifier, _) {
                                if (widget.currentUser!.uid ==
                                        widget.ctuer!.id ||
                                    notifier.value) {
                                  return _buildInformation(context);
                                }
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                      'THEO DÕI ' +
                                          widget.ctuer!.username +
                                          ' ĐỂ HIỂN THỊ PROFILE',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Get.isDarkMode
                                              ? kPrimaryDarkColor
                                              : kPrimaryColor)),
                                );
                              }),
                          EventualSingleBuilder(
                              notifier: isAlreadyFollowing,
                              builder: (context, notifier, _) {
                                if (widget.currentUser!.uid ==
                                        widget.ctuer!.id ||
                                    notifier.value) {
                                  return StreamBuilder<QuerySnapshot>(
                                      stream: DatabaseServices(
                                              uid: widget.ctuer!.id)
                                          .getPhotos(),
                                      builder: (context, snapshot) {
                                        return snapshot.hasData
                                            ? SizedBox(
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
                                                        .data!.docs.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Container(
                                                          width: 150,
                                                          margin:
                                                              const EdgeInsets
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
                                                            child:
                                                                Image.network(
                                                              snapshot.data!
                                                                  .docs[index]
                                                                  .get('photo'),
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ));
                                                    }))
                                            : Loading();
                                      });
                                }
                                return const SizedBox.shrink();
                              }),
                        ])
                      ])))
            ]),
          );
        });
  }

  Container _buildInformation(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('V Ề  T Ô I',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor)),
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
            height: 4.0,
          ),
          Text('C Ộ N G   Đ Ồ N G',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor)),
          const SizedBox(
            height: 5,
          ),
          Text("Đại học Cần Thơ, " + "ngành " + widget.ctuer!.major,
              style: const TextStyle(
                fontSize: 15,
              )),
          SizedBox(
            height: 4.0,
          ),
          Text('S O C I A L   M E D I A ',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor)),
          const SizedBox(
            height: 5,
          ),
          Text(widget.ctuer!.media,
              style: const TextStyle(
                fontSize: 15,
              )),
          SizedBox(
            height: 4.0,
          ),
          Text('K H O Á',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor)),
          const SizedBox(
            height: 5,
          ),
          Text(widget.ctuer!.course,
              style: const TextStyle(
                fontSize: 15,
              )),
          SizedBox(
            height: 4.0,
          ),
          Text('P L A Y L I S T',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor)),
          const SizedBox(
            height: 5,
          ),
          Text(widget.ctuer!.playlist,
              style: const TextStyle(
                fontSize: 15,
              )),
          SizedBox(
            height: 4.0,
          ),
          Text('S Ố N G  Ở',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor)),
          const SizedBox(
            height: 5,
          ),
          Text(widget.ctuer!.address,
              style: const TextStyle(
                fontSize: 15,
              )),
          SizedBox(
            height: 4.0,
          ),
        ],
      ),
    );
  }
}

Column createColumns(String title, int count) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        count.toString(),
        style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            color: Get.isDarkMode ? Colors.black : Colors.white),
      ),
      Container(
        margin: EdgeInsets.only(top: 5.0),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w200,
              color: Get.isDarkMode ? Colors.black : Colors.white),
        ),
      )
    ],
  );
}
