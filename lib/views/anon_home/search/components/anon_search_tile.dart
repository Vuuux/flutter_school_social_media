import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/views/anon_home/profile/others_anon_profile.dart';
import 'package:luanvanflutter/views/home/chat/conversation_screen.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:provider/src/provider.dart';
import 'package:uuid/uuid.dart';

class AnonSearchTile extends StatelessWidget {
  final UserData userData;

  const AnonSearchTile({Key? key, required this.userData}) : super(key: key);

  createChatRoomAndStartConversation(BuildContext context, String uid, UserData userData) {
    String chatRoomId = const Uuid().v4();
    List<String> users = [uid, userData.id];

    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomId": chatRoomId,
      "timestamp": Timestamp.now(),
      "isPrivateChat": true
    };

    DatabaseServices(uid: '').createAnonChatRoom(chatRoomId, uid, userData.id,
        chatRoomMap);
    //TODO: START CONVERSATION
    // Map<String, dynamic> chatRoomMap = {
    //   "users": users,
    //   "chatRoomId": chatRoomID
    // };
    // DatabaseServices(uid: '').uploadBondData(
    //     userData: userData,
    //     myAnon: true,
    //     ctuer: ctuer,
    //     friendAnon: false,
    //     chatRoomID: chatRoomID);

    //DatabaseServices(uid: '').createAnonChatRoom(chatRoomID, chatRoomMap);
    //TODO: AnonymousConversation
    // Navigator.of(context).pushAndRemoveUntil(
    //   FadeRoute(
    //     page: AnonymousConversation(
    //       friendAnon: false,
    //       ctuerList: widget.ctuerList,
    //       ctuer: ctuer,
    //       chatRoomId: chatRoomID,
    //       userData: userData,
    //     ),
    //   ),
    //   ModalRoute.withName('AnonymousConversation'),
    // );

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (context) =>
            ConversationScreen(
                chatRoomId: chatRoomId, ctuer: userData, userId: uid)), (
        route) => false);
  }

  Widget buildSearchTile(BuildContext context, String uid) {
    if (uid != userData.id) {
      return RaisedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => OthersAnonProfile(ctuerId: userData.id)),);
          //     .pushAndRemoveUntil(
          //   FadeRoute(
          //     page: OthersProfile(
          //       ctuerList: widget.ctuerList,
          //       ctuer: ctuer,
          //       userData: userData,
          //     ),
          //   ),
          //   ModalRoute.withName('OthersProfile'),
          // );
        },
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: const Color(0xFFD4D4D4),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: ClipOval(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: userData.avatar.isNotEmpty
                          ? Image.network(
                        userData.avatar,
                        fit: BoxFit.fill,
                      )
                          : Image.asset('assets/images/profile1.png',
                          fit: BoxFit.fill),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  userData.nickname,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                createChatRoomAndStartConversation(context, uid, userData);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(30)),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                child: const Text('Text'),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUser?>();
    return buildSearchTile(context, user!.uid);
  }
}
