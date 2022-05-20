import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/conversation_item.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/games/trivia/answerscreen.dart';
import 'package:luanvanflutter/views/home/chat/conversation_screen.dart';

class MessageTile extends StatelessWidget {
  final UserData? ctuer;
  final bool isSendByMe;
  final String chatRoomId;
  final ConversationItemModel messageModel;
  const MessageTile(
      {required this.chatRoomId,
      required this.isSendByMe,
      required this.ctuer,
      required this.messageModel,
      Key? key})
      : super(key: key);

  //delete msg
  //edit msg
  _onTap() {
    if (messageModel.type == KEY_NOTIFICATION_QUESTION &&
        messageModel.message.isNotEmpty &
            messageModel.triviaRoomId!.isNotEmpty &&
        !isSendByMe) {
      if (ctuer != null) {
        Get.to(() => AnswerScreen(
              question: messageModel.message,
              triviaRoomID: messageModel.triviaRoomId!,
              ctuer: ctuer!,
              userData: UserDataService().getUserData()!,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isSendByMe ? 0 : 24,
          right: isSendByMe ? 24 : 0),
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      child: FocusedMenuHolder(
        menuWidth: MediaQuery.of(context).size.width * 0.35,
        onPressed: () => FocusScope.of(context).unfocus(),
        menuBoxDecoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
          bottomLeft: Radius.circular(23),
          bottomRight: Radius.circular(23),
        )),
        menuItems: <FocusedMenuItem>[
          FocusedMenuItem(
              title: const Text(
                "Xóa",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              trailingIcon: Icon(Icons.delete),
              onPressed: () {
                DatabaseServices(uid: '')
                    .chatReference
                    .doc(chatRoomId)
                    .collection('conversation')
                    .where("message", isEqualTo: messageModel.message)
                    .get()
                    .then((doc) {
                  if (doc.docs[0].exists) {
                    doc.docs[0].reference.delete();
                  }
                });
              },
              backgroundColor: Colors.redAccent)
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSendByMe)
              Text(
                messageModel.senderName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ).paddingOnly(left: 12.0),
            Container(
              margin: isSendByMe
                  ? const EdgeInsets.only(left: 30)
                  : const EdgeInsets.only(right: 30),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      offset: Offset(-1, 4),
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                      spreadRadius: 1)
                ],
                color: (messageModel.type == 'message')
                    ? (!isSendByMe
                        ? Get.isDarkMode
                            ? kPrimaryDarkColor
                            : Colors.red
                        : Colors.white)
                    : kStudyColor,
                borderRadius: isSendByMe
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomLeft: Radius.circular(23),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomRight: Radius.circular(23),
                      ),
              ),
              child: Column(
                crossAxisAlignment: isSendByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    f.format(messageModel.timestamp.toDate()).toString(),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular'),
                  ),
                  Text(
                    messageModel.message,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                        fontWeight: messageModel.type == 'message'
                            ? FontWeight.w300
                            : FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
