import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:luanvanflutter/models/user.dart';
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
        builder: (context, snapshot ) {
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
              body: FutureBuilder(
                  future: databaseService.getNotifications(userData.email),
                  builder: (context, dataSnapshot) {
                    if(dataSnapshot.connectionState != ConnectionState.done){
                      return Loading();
                    }
                    if(dataSnapshot.hasError) {
                      //TODO: Show Error
                    }

                    List<NotificationsItem> items = dataSnapshot.data as List<NotificationsItem>;
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return items[index];
                      },
                      itemCount: items.length,
                    );
                  }),
            );
          } else {
            return Loading();
          }
        });
  }
}

late String notificationItemText;
late Widget mediaPreview;

class NotificationsItem extends StatefulWidget {
  final String type;
  final String ownerID;
  final String ownerName;
  final Timestamp timestamp;
  final String userDp;
  final String userID;
  final String msgInfo;
  final String status;
  final String senderEmail;
  final String notifID;

  NotificationsItem(
      {
        Key? key, required this.type,
      required this.ownerID,
      required this.ownerName,
      required this.timestamp,
      required this.userDp,
      required this.userID,
      required this.msgInfo,
      required this.status,
      required this.senderEmail,
      required this.notifID}) : super(key: key);

  DatabaseServices databaseService = DatabaseServices(uid: '');

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationsItem(
        type: documentSnapshot.get('type'),
        ownerID: documentSnapshot.get('ownerID'),
        ownerName: documentSnapshot.get('ownerName'),
        timestamp: documentSnapshot.get('timestamp'),
        userDp: documentSnapshot.get('userDp'),
        userID: documentSnapshot.get('userID'),
        msgInfo: documentSnapshot.get('msgInfo'),
        status: documentSnapshot.get('status'),
        senderEmail: documentSnapshot.get('senderEmail'),
        notifID: documentSnapshot.get('notifID'));
  }
  configureMediaPreview(context) {
    mediaPreview = const Text('');
    if (type == 'follow') {
      notificationItemText = 'đang theo dõi bạn';
    } else if (type == 'message') {
      notificationItemText = 'gởi bạn 1 tin nhắn';
    } else if (type == 'request') {
      notificationItemText = 'yêu cầu theo dõi bạn';
    } else if (type == 'compatibility') {
      notificationItemText = 'muốn chơi trò QnA với bạn';
    } else if (type == 'anonmessage') {
      notificationItemText = 'đã gởi 1 tin nhắn (Vô danh)';
    } else if (type == 'question') {
      notificationItemText = 'muốn chơi đố vui cùng bạn';
    } else {
      notificationItemText = 'Lỗi, Unknown type = $type';
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
    if (widget.type == 'request') {
      widget.databaseService.feedRef
          .doc(widget.ownerID)
          .collection('feed')
          .doc(widget.senderEmail)
          .get()
          .then((doc) {
        if (doc.exists) {
          if (doc.data()!['status'] == 'followed') {
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

  checkAcceptedOrDeclinedfortictactoe() {
    if (widget.type == 'tictactoe') {
      widget.databaseService.feedRef
          .doc(widget.ownerID)
          .collection('feed')
          .where('notifID', isEqualTo: widget.notifID)
          .where('type', isEqualTo: 'tictactoe')
          .get()
          .then((value) {
        if (value.docs[0].data()['status'] == 'accepted') {
          if (mounted) {
            setState(() {
              accepted = true;
            });
          }
        } else if (value.docs[0].data()['status'] == 'declined') {
          if (mounted) {
            setState(() {
              declined = true;
            });
          }
        }
      });
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
        color: const Color(0xFF212121),
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
                          text: widget.userID,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Colors.white)),
                      TextSpan(
                          text: ' $notificationItemText',
                          style: (const TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
                widget.type == 'request'
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
                                        notificationItemText =
                                            'đang theo dõi bạn';
                                      });
                                    }
                                    widget.databaseService.acceptRequest(
                                        widget.ownerID,
                                        widget.ownerName,
                                        widget.userDp,
                                        widget.userID,
                                        widget.senderEmail);
                                  }),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 13,
                              ),
                              InkWell(
                                child: const Text('TỪ CHỐI',
                                    style: TextStyle(fontSize: 10)),
                                onTap: () {
                                  widget.databaseService.feedRef
                                      .doc(widget.ownerID)
                                      .collection('feed')
                                      .doc(widget.senderEmail)
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
                child: widget.userDp != ""
                    ? Image.network(
                        widget.userDp,
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
          subtitle: Text(tAgo.format(widget.timestamp.toDate()),
              overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
