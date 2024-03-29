import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import "package:flutter/material.dart";
import 'package:luanvanflutter/models/notification.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/anon_home/profile/others_anon_profile.dart';
import 'package:luanvanflutter/utils/helper.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'package:uuid/uuid.dart';

import '../../controller/controller.dart';
import 'feed/anon_forum_detail.dart';

//Class quản lý thông báo
class AnonNotificationPage extends StatefulWidget {
  final String uid;

  const AnonNotificationPage({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _AnonNotificationPageState createState() => _AnonNotificationPageState();
}

class _AnonNotificationPageState extends State<AnonNotificationPage> {
  Future<QuerySnapshot>? notificationFuture;

  @override
  void initState() {
    super.initState();
    notificationFuture =
        DatabaseServices(uid: widget.uid).getAllAnonNotifications();
  }

  Future _onRefresh() async {
    QuerySnapshot snapshot =
        await DatabaseServices(uid: widget.uid).getAllNotifications();
    setState(() {
      notificationFuture = Future<QuerySnapshot>.value(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseServices databaseService = DatabaseServices(uid: widget.uid);

    return StreamBuilder<UserData?>(
        stream: databaseService.userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }
          if (snapshot.hasData) {
            UserData? userData = snapshot.data;
            if (userData != null) {
              return Scaffold(
                appBar: AppBar(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  )),
                  centerTitle: true,
                  elevation: 0,
                  title: const Text("T H Ô N G    B Á O",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
                ),
                body: FutureBuilder<QuerySnapshot>(
                    future: notificationFuture,
                    builder: (context, dataSnapshot) {
                      List<NotificationModel> notificationsItems = [];
                      if (dataSnapshot.connectionState !=
                          ConnectionState.done) {
                        return Loading();
                      }
                      if (dataSnapshot.hasData) {
                        for (var document in dataSnapshot.data!.docs) {
                          notificationsItems
                              .add(NotificationModel.fromDocument(document));
                        }
                        return RefreshIndicator(
                          onRefresh: () => _onRefresh(),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return AnonNotificationsItem(
                                  noti: notificationsItems[index]);
                            },
                            itemCount: notificationsItems.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const Divider(
                                height: 1,
                                thickness: 1,
                              );
                            },
                          ),
                        );
                      }
                      return const Center(
                        child: Text("Bạn chưa có thông báo nào"),
                      );
                    }),
              );
            }
          }
          return Center(
            child: const Text("Bạn không có thông báo nào!"),
          );
        });
  }
}

class AnonNotificationsItem extends StatefulWidget {
  final NotificationModel noti;
  late String notificationItemText;
  late Widget mediaPreview;
  UserData? userData;

  AnonNotificationsItem({Key? key, required this.noti}) : super(key: key);

  DatabaseServices databaseService = DatabaseServices(uid: '');

  configureMediaPreview(context) {
    mediaPreview = noti.mediaUrl!.isNotEmpty
        ? SizedBox(
            child: CachedNetworkImage(imageUrl: noti.mediaUrl!),
          )
        : SizedBox.shrink();
    if (noti.type == 'following') {
      notificationItemText = 'đang theo dõi bạn';
    } else if (noti.type == 'like') {
      notificationItemText = 'đã thích bài viết của bạn';
    } else if (noti.type == 'comment') {
      notificationItemText = 'đã bình luận bài viết';
    } else if (noti.type == 'message') {
      notificationItemText = 'đã gửi bạn 1 tin nhắn';
    } else if (noti.type == 'request') {
      notificationItemText = 'yêu cầu theo dõi bạn';
    } else if (noti.type == 'accept-request') {
      notificationItemText = 'đã chấp nhận yêu cầu theo dõi của bạn';
    } else if (noti.type == 'qa-game') {
      notificationItemText = 'muốn chơi trò QnA với bạn';
    } else if (noti.type == 'anonmessage') {
      notificationItemText = 'đã gởi 1 tin nhắn mật';
    } else if (noti.type == 'question') {
      notificationItemText = 'muốn chơi đố vui cùng bạn';
    } else if (noti.type == 'vote') {
      notificationItemText = 'đã bỏ phiếu cho bài viết của bạn';
    } else if (noti.type == 'approved') {
      notificationItemText = 'Admin đã duyệt bài viết của bạn';
    } else {
      notificationItemText = 'Lỗi, Unknown type = ' + noti.type;
    }
  }

  @override
  _AnonNotificationsItemState createState() => _AnonNotificationsItemState();
}

class _AnonNotificationsItemState extends State<AnonNotificationsItem> {
  bool accepted = false;
  bool declined = false;

  @override
  void initState() {
    super.initState();
  }

  checkFollowRequestStatus(String uid) {
    if (widget.noti.type == 'request') {
      widget.databaseService
          .getRequestNotification(uid, widget.noti.userId)
          .then((doc) {
        if (doc.exists) {
          if (doc.data()!['status'] == 'followed' ||
              doc.data()!['status'] == 'accepted') {
            if (mounted) {
              setState(() {
                accepted = true;
              });
            }
          }
        }
      });
    }
  }

  checkAcceptedOrDeclinedfortictactoe(String uid) {
    if (widget.noti.type == 'tictactoe') {
      // widget.databaseService.feedRef
      //     .doc(widget.ownerID)
      //     .collection('feed')
      //     .where('notifID', isEqualTo: widget.notifID)
      //     .where('type', isEqualTo: 'tictactoe')
      //     .get()
      //     .then((value) {
      //   if (value.docs[0].data()['status'] == 'accepted') {
      //     if (mounted) {
      //       setState(() {
      //         accepted = true;
      //       });
      //     }
      //   } else if (value.docs[0].data()['status'] == 'declined') {
      //     if (mounted) {
      //       setState(() {
      //         declined = true;
      //       });
      //     }
      //   }
      // });
    }
  }

  getGameRoomID(String a, String b) {
    codeUnit(String a) {
      int count = 0;
      for (int i = 0; i < a.length; i++) {
        count += a.codeUnitAt(i);
      }
      return count;
    }

    if (a.length < b.length) {
      return "$a\_$b";
    } else if (a.length > b.length) {
      return "$b\_$a";
    } else {
      print(codeUnit(a) + codeUnit(b));
      return (codeUnit(a) + codeUnit(b)).toString();
    }
  }

  Future getCurrentUserData(String uid) async {
    return await DatabaseServices(uid: uid).getUserByUserId();
  }

  handleAcceptRequest(CurrentUserId user) async {
    await getCurrentUserData(user.uid).then((value) {
      setState(() {
        widget.userData = UserData.fromDocumentSnapshot(value);
      });
    });
    widget.databaseService.acceptRequest(user.uid, widget.noti.userId);
    String notifId = Uuid().v4();
    widget.databaseService
        .addNotifiCation(widget.noti.userId, user.uid, notifId, {
      'notifId': notifId,
      'type': 'request',
      'timestamp': DateTime.now(),
      'avatar': widget.userData!.avatar,
      'username': widget.userData!.username,
      'status': 'following',
      'seenStatus': false,
      'userId': widget.userData!.id
    });

    widget.databaseService.addFollowing(user.uid, widget.noti.userId, {
      'userId': widget.userData!.id,
      'username': widget.userData!.username,
      'avatar': widget.userData!.avatar
    });

    widget.databaseService.addFollower(user.uid, widget.noti.userId, {
      'userId': widget.noti.userId,
      'username': widget.noti.username,
      'avatar': widget.noti.avatar
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUserId?>(context);
    checkFollowRequestStatus(user!.uid);
    checkAcceptedOrDeclinedfortictactoe(user.uid);
    widget.configureMediaPreview(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        color:
            widget.noti.status == 'unseen' || widget.noti.status == 'requesting'
                ? Colors.white
                : Colors.black12,
        child: ListTile(
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          widget.noti.type == 'accept-request' ||
                                  widget.noti.type == 'request'
                              ? OthersAnonProfile(ctuerId: widget.noti.userId)
                              : ForumDetail(
                                  forumId: widget.noti.postId!,
                                  ownerId: user.uid,
                                )));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 7,
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style:
                          const TextStyle(fontSize: 10.0, color: Colors.black),
                      children: [
                        TextSpan(
                            text: widget.noti.username,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black)),
                        TextSpan(
                            text: " " + widget.notificationItemText,
                            style: (const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black))),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: widget.noti.type == 'request' ||
                          widget.noti.type == 'accept-request'
                      ? 3
                      : 0,
                  child: widget.noti.type == 'request'
                      ? accepted || declined
                          ? accepted
                              ? InkWell(
                                  child: const Text('ĐÃ ĐỒNG Ý!',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold)),
                                  onTap: () {})
                              : InkWell(
                                  child: const Text('ĐÃ TỪ CHỐI',
                                      style: TextStyle(fontSize: 12.0)),
                                  onTap: () {})
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(
                                    child: const Text('OK!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.bold)),
                                    onTap: () {
                                      if (mounted) {
                                        setState(() {
                                          accepted = true;
                                          widget.notificationItemText =
                                              'đang theo dõi bạn';
                                        });
                                      }
                                      handleAcceptRequest(user);
                                    }),
                                InkWell(
                                  child: const Text('TỪ CHỐI',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.bold)),
                                  onTap: () {
                                    widget.databaseService.declineRequest(
                                        user.uid, widget.noti.userId);
                                    if (mounted) {
                                      setState(() {
                                        declined = true;
                                      });
                                    }
                                  },
                                )
                              ],
                            )
                      : Container(),
                ),
              ],
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 25,
            child: ClipOval(
              child: SizedBox(
                width: 56,
                height: 56,
                child: widget.noti.avatar != ""
                    ? Image.network(
                        widget.noti.avatar,
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/images/profile1.png',
                        fit: BoxFit.cover),
              ),
            ),
          ),
          subtitle: Text(tAgo.format(widget.noti.timestamp.toDate()),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12)),
          trailing: widget.noti.type == 'request' ||
                  widget.noti.type == 'accept-request'
              ? null
              : widget.mediaPreview,
        ),
      ),
    );
  }
}
