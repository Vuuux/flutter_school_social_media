import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:luanvanflutter/models/notification.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as tAgo;

import '../../controller/controller.dart';

//Class quản lý thông báo
class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser?>(context);
    DatabaseServices databaseService = DatabaseServices(uid: user!.uid);

    return StreamBuilder<UserData>(
        stream: databaseService.userData,
        builder: (context, snapshot) {
          UserData? userData = snapshot.data;
          if (userData != null) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                title: const Text("T H Ô N G    B Á O",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
              ),
              body: FutureBuilder<QuerySnapshot>(
                  future: databaseService.getNotifications(),
                  builder: (context, dataSnapshot) {
                    List<NotificationModel> notificationsItems = [];
                    if (dataSnapshot.connectionState != ConnectionState.done) {
                      return Loading();
                    }
                    if (dataSnapshot.hasData) {

                      for (var document in dataSnapshot.data!.docs) {
                        notificationsItems.add(NotificationModel.fromDocument(document));
                      }
                      return ListView.separated(
                        itemBuilder: (context, index) {
                          return NotificationsItem(
                              noti: notificationsItems[index]);
                        },
                        itemCount: notificationsItems.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(height: 1, thickness: 1,);
                        },
                      );
                    }

                    return const Center(
                      child: Text("Bạn chưa có thông báo nào"),
                    );
                  }),
            );
          } else {
            return Loading();
          }
        });
  }
}

class NotificationsItem extends StatefulWidget {
  final NotificationModel noti;
  late String notificationItemText;
  late Widget mediaPreview;

  NotificationsItem({Key? key, required this.noti}) : super(key: key);

  DatabaseServices databaseService = DatabaseServices(uid: '');

  configureMediaPreview(context) {
    mediaPreview = SizedBox(
      child: CachedNetworkImage(imageUrl: noti.mediaUrl),
    );
    if (noti.type == 'follow') {
      notificationItemText = 'đang theo dõi bạn';
    } else if (noti.type == 'like') {
      notificationItemText = 'đã thích bài viết của bạn';
    } else if (noti.type == 'comment') {
      notificationItemText = 'đã bình luận: ' + noti.comment!;
    } else if (noti.type == 'message') {
      notificationItemText = 'gởi bạn 1 tin nhắn';
    } else if (noti.type == 'request') {
      notificationItemText = 'yêu cầu theo dõi bạn';
    } else if (noti.type == 'compatibility') {
      notificationItemText = 'muốn chơi trò QnA với bạn';
    } else if (noti.type == 'anonmessage') {
      notificationItemText = 'đã gởi 1 tin nhắn (Vô danh)';
    } else if (noti.type == 'question') {
      notificationItemText = 'muốn chơi đố vui cùng bạn';
    } else {
      notificationItemText = 'Lỗi, Unknown type = ' + noti.type;
    }
  }

  @override
  _NotificationsItemState createState() => _NotificationsItemState();
}

class _NotificationsItemState extends State<NotificationsItem> {
  bool accepted = false;
  bool declined = false;

  @override
  void initState() {
    checkAcceptedOrDeclinedforfollow();
    checkAcceptedOrDeclinedfortictactoe();
    super.initState();
  }

  checkAcceptedOrDeclinedforfollow() {
    if (widget.noti.type == 'request') {
      //TODO: ACCEP REQUEST
    }
    //   widget.databaseService.feedRef
    //       .doc(widget.ownerID)
    //       .collection('feed')
    //       .doc(widget.senderEmail)
    //       .get()
    //       .then((doc) {
    //     if (doc.exists) {
    //       if (doc.data()!['status'] == 'followed') {
    //         if (mounted) {
    //           setState(() {
    //             accepted = true;
    //           });
    //         }
    //       }
    //     }
    //   });
    // }
  }

  checkAcceptedOrDeclinedfortictactoe() {
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

  @override
  Widget build(BuildContext context) {
    widget.configureMediaPreview(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: Container(
        color: kPrimaryLightColor,
        child: ListTile(
          title: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 10.0, color: Colors.black),
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
                widget.noti.type == 'request'
                    ? accepted || declined
                        ? accepted
                            ? InkWell(
                                child: const Text('ĐỒNG Ý',
                                    style: TextStyle(fontSize: 10)),
                                onTap: () {
                                  print('NHẤN');
                                })
                            : InkWell(
                                child: const Text('TỪ CHỐI',
                                    style: TextStyle(fontSize: 10.0)),
                                onTap: () {
                                  print('NHẤN');
                                })
                        : Row(
                            children: <Widget>[
                              InkWell(
                                  child: const Text('ĐỒNG Ý',
                                      style: TextStyle(fontSize: 10.0)),
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        accepted = true;
                                        widget.notificationItemText =
                                            'đang theo dõi bạn';
                                      });
                                    }
                                    //TODO: ACCEPT REQUEST
                                    // widget.databaseService.acceptRequest(
                                    //     widget.ownerID,
                                    //     widget.ownerName,
                                    //     widget.userDp,
                                    //     widget.userID,
                                    //     widget.senderEmail);
                                  }),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 13,
                              ),
                              InkWell(
                                child: const Text('TỪ CHỐI',
                                    style: TextStyle(fontSize: 10)),
                                onTap: () {
                                  widget.databaseService.feedRef
                                      .doc(widget.noti.userId)
                                      .collection('feedItems')
                                      .doc(widget.noti.userId)
                                      .get()
                                      .then((doc) {
                                    if (doc.exists) {
                                      doc.reference.delete();
                                    }
                                  });
                                  if (mounted) {
                                    setState(() {
                                      declined = true;
                                    });
                                  }
                                },
                              ),
                            ],
                          )
                    : Container(),
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

                // Image.network(
                //       widget.userDp,
                //       fit: BoxFit.fill,
                //     ) ??
                //     Image.asset('assets/images/profile1.png', fit: BoxFit.fill),
              ),
            ),
          ),
          subtitle: Text(tAgo.format(widget.noti.timestamp.toDate()),
              overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          trailing: widget.mediaPreview,
        ),
      ),
    );
  }
}
