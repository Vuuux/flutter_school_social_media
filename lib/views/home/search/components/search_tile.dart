import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/chat_utils.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/home/chat/conversation_screen.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:provider/src/provider.dart';
import 'package:uuid/uuid.dart';

class SearchTile extends StatelessWidget {
  final UserData ctuer;

  const SearchTile({Key? key, required this.ctuer}) : super(key: key);

  createChatRoomAndStartConversation(
      BuildContext context, String uid, UserData userData) async {
    List<String> chatRoomID =
        ChatUtils.createChatRoomIdFromUserId(uid, userData.id);
    String existedChatRoomId =
        await DatabaseServices(uid: uid).checkIfChatRoomExisted(chatRoomID);
    bool isChatRoomExisted = existedChatRoomId.isEmpty ? false : true;
    String resultChatRoomId =
        isChatRoomExisted ? existedChatRoomId : chatRoomID[0];

    List<String> users = [uid, userData.id];

    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomId": resultChatRoomId,
      "timestamp": Timestamp.now(),
    };

    if (!isChatRoomExisted) {
      await DatabaseServices(uid: uid)
          .createChatRoom(resultChatRoomId, chatRoomMap);
      Get.to(() => ConversationScreen(
          chatRoomId: resultChatRoomId, ctuer: userData, userId: uid));
    } else {
      Get.to(() => ConversationScreen(
          chatRoomId: existedChatRoomId, ctuer: userData, userId: uid));
    }
  }

  Widget buildSearchTile(BuildContext context, String uid) {
    if (uid != ctuer.id) {
      return RaisedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => OthersProfile(ctuerId: ctuer.id)),
          );
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
                Text(
                  ctuer.username,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                createChatRoomAndStartConversation(context, uid, ctuer);
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
    final user = context.watch<CurrentUserId?>();
    return buildSearchTile(context, user!.uid);
  }
}
