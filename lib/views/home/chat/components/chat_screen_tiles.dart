import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/home/chat/conversation_screen.dart';
import 'package:provider/src/provider.dart';

class ChatScreenTile extends StatelessWidget {
  final String userId;
  final UserData ctuer;
  final String chatRoomId;
  Stream<QuerySnapshot>? chatMessagesStream;
  var f = DateFormat('h:mm a');
  String latestMsg = '';
  String latestTime = '';

  ChatScreenTile({
    Key? key,
    required this.userId,
    required this.ctuer,
    required this.chatRoomId,
  }) : super(key: key);

  Widget getLatestMsg() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatMessagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.length - 1 < 0) {
            return const Text('');
          } else {
            latestMsg = snapshot.data!.docs[snapshot.data!.docs.length - 1]
                .get("message");
            latestTime = f
                .format(snapshot.data!.docs[snapshot.data!.docs.length - 1]
                    .get("timestamp")
                    .toDate())
                .toString();
            return Text(latestMsg.length >= 20 ? '...' : latestMsg,
                style: const TextStyle(color: Colors.grey));
          }
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    chatMessagesStream =
        DatabaseServices(uid: '').getConversationMessages(chatRoomId);
    return StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user!.uid).userData,
        builder: (context, snapshot) {
          UserData? userData = snapshot.data;
          return FocusedMenuHolder(
            menuWidth: MediaQuery.of(context).size.width,
            menuBoxDecoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                      chatRoomId: chatRoomId, ctuer: ctuer, userId: userId)));
              // .pushAndRemoveUntil(
              //   FadeRoute(
              //     page: ConversationScreen(
              //       ctuerList: ctuerList,
              //       ctuer: currentCtuer,
              //       chatRoomId: chatRoomId,
              //       userData: userData,
              //     ),
              //   ),
              //   ModalRoute.withName('ConversationScreen'),
              // );
            },
            menuItems: <FocusedMenuItem>[
              FocusedMenuItem(
                  title: const Text(
                    "Xóa Chat",
                    style: TextStyle(color: Colors.black),
                  ),
                  trailingIcon: Icon(Icons.delete),
                  onPressed: () {
                    DatabaseServices(uid: '')
                        .chatReference
                        .doc(chatRoomId)
                        .collection('conversation')
                        .get()
                        .then((doc) {
                      if (doc.docs[0].exists) {
                        doc.docs[0].reference.delete();
                      }
                    });

                    DatabaseServices(uid: '')
                        .chatReference
                        .doc(chatRoomId)
                        .get()
                        .then((doc) {
                      if (doc.exists) {
                        doc.reference.delete();
                      }
                    });
                  },
                  backgroundColor: Colors.redAccent)
            ],
            child: Container(
              margin:
                  const EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: ClipOval(
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: ctuer.avatar.isNotEmpty
                                ? Image.network(
                                    ctuer.avatar,
                                    fit: BoxFit.fill,
                                  )
                                : Image.asset('assets/images/profile1.png',
                                    fit: BoxFit.fill),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            ctuer.username,
                            style: const TextStyle(color: Colors.black),
                          ),
                          getLatestMsg()
                        ],
                      )
                    ],
                  ),
                  Text(latestTime)
                ],
              ),
            ),
          );
        });
  }
}
