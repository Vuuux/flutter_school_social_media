import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';

import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/home.dart';
import 'package:luanvanflutter/utils/chat_utils.dart';
import 'package:luanvanflutter/views/components/custom_input_field.dart';
import 'package:uuid/uuid.dart';

import '../../home/chat/chat_screen.dart';

class AnswerScreen extends StatefulWidget {
  String triviaRoomID;
  String question;
  UserData userData;
  UserData ctuer;

  AnswerScreen(
      {Key? key,
      required this.userData,
      required this.ctuer,
      required this.triviaRoomID,
      required this.question})
      : super(key: key);

  @override
  _AnswerScreenState createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  late String player1Text;
  late String player2Text;
  late String message;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController messageTextEditingController =
      new TextEditingController();

  Future<String> createChatRoomAndStartConversation(
      UserData userData, UserData ctuer, String chatRoomID) async {
    List<String> users = [userData.id, ctuer.id];

    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomId": chatRoomID,
      "timestamp": Timestamp.now(),
    };
    await DatabaseServices(uid: userData.id)
        .createChatRoom(chatRoomID, chatRoomMap);
    return chatRoomID;
  }

  sendMessage() async {
    if (message.isNotEmpty) {
      List<String> chatRoomID = ChatUtils.createChatRoomIdFromUserId(
          widget.userData.id, widget.ctuer.id);
      String existedChatRoomId = await DatabaseServices(uid: widget.userData.id)
          .checkIfChatRoomExisted(chatRoomID);
      bool isChatRoomExisted = existedChatRoomId.isEmpty ? false : true;
      String resultChatRoomId =
          isChatRoomExisted ? existedChatRoomId : chatRoomID[0];

      Map<String, dynamic> questionMap = {
        "message": widget.question,
        "triviaRoomId": widget.triviaRoomID,
        "sendBy": widget.userData.username,
        "timestamp": Timestamp.now(),
        "senderId": widget.userData.id,
        "type": KEY_NOTIFICATION_QUESTION
      };
      Map<String, dynamic> messageMap = {
        "message": message,
        "triviaRoomId": widget.triviaRoomID,
        "sendBy": widget.userData.username,
        "timestamp": Timestamp.now(),
        "senderId": widget.userData.id,
        "type": KEY_NOTIFICATION_MESSAGE
      };
      if (!isChatRoomExisted) {
        await createChatRoomAndStartConversation(
            widget.userData, widget.ctuer, resultChatRoomId);
      }

      DatabaseServices(uid: _auth.currentUser?.uid)
          .addConversationMessages(resultChatRoomId, questionMap);
      DatabaseServices(uid: _auth.currentUser?.uid)
          .addConversationMessages(resultChatRoomId, messageMap);
      String notifId = Uuid().v4();
      DatabaseServices(uid: _auth.currentUser?.uid)
          .addNotifiCation(widget.ctuer.id, widget.userData.id, notifId, {
        'notifId': notifId,
        'type': KEY_NOTIFICATION_QUESTION,
        'triviaRoomId': widget.triviaRoomID,
        'chatRoomId': resultChatRoomId,
        'msgInfo': widget.question,
        'ownerID': widget.ctuer.email,
        'ownerName': widget.ctuer.username,
        'timestamp': DateTime.now(),
        'status': null,
        'seenStatus': false,
        'userDp': widget.userData.anonAvatar,
        'userID': widget.userData.nickname,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Trả lời"),
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: AutoSizeText(
                  widget.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: CustomInputField(
                controller: messageTextEditingController,
                title: 'Câu trả lời của bạn',
                content: 'Đáp án',
              ),
            ),
            ElevatedButton(
              child: Text(
                "ĐỒNG Ý",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Get.isDarkMode ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () {
                // print(widget.userData.name);
                // print(widget.hmmie);
                _validateInput(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _validateInput(BuildContext context) {
    if (messageTextEditingController.text.isEmpty) {
      Get.snackbar("Bắt buộc", "Vui lòng nhập câu trả lời của bạn",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      message = messageTextEditingController.text;
      player1Text = messageTextEditingController.text;
      player2Text = "";
      sendMessage();
      DatabaseServices(uid: _auth.currentUser?.uid).updateTrivia(
          triviaRoomID: widget.triviaRoomID,
          question: widget.question,
          answer1: player1Text,
          answer2: player2Text);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
          (Route<dynamic> route) => route is Home);
    }
  }
}
