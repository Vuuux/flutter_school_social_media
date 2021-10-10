import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/decoration.dart';
import 'package:luanvanflutter/views/home/home.dart';

class AnswerScreen extends StatefulWidget {
  String triviaRoomID;
  String question;
  UserData userData;
  Ctuer ctuer;
  List<Ctuer> ctuerList;

  AnswerScreen(
      {required this.ctuerList,
      required this.userData,
      required this.ctuer,
      required this.triviaRoomID,
      required this.question});

  @override
  _AnswerScreenState createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  late String player1Text;
  late String player2Text;
  late String message;
  TextEditingController messageTextEditingController =
      new TextEditingController();

  getChatRoomID(String a, String b) {
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

  createChatRoomAndStartConversation(UserData userData, Ctuer hmmie) {
    String chatRoomID = getChatRoomID(userData.nickname, hmmie.nickname);
    List<String> users = [userData.email, hmmie.email];

    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomId": chatRoomID
    };
    //TODO: ADD uid
    DatabaseServices(uid: '').createAnonChatRoom(chatRoomID, chatRoomMap);
  }

  sendMessage() {
    if (message.isNotEmpty) {
      createChatRoomAndStartConversation(widget.userData, widget.ctuer);

      Map<String, dynamic> questionMap = {
        "message": widget.question,
        "sendBy": widget.userData.name,
        "time": Timestamp.now(),
        "email": widget.userData.email,
        "type": 'question'
      };
      Map<String, dynamic> messageMap = {
        "message": message,
        "sendBy": widget.userData.name,
        "time": Timestamp.now(),
        "email": widget.userData.email,
        "type": 'message'
      };

      //TODO: ADD UID
      DatabaseServices(uid: '').addAnonConversationMessages(
          getChatRoomID(widget.userData.nickname, widget.ctuer.nickname),
          questionMap);
      DatabaseServices(uid: '').addAnonConversationMessages(
          getChatRoomID(widget.userData.nickname, widget.ctuer.nickname),
          messageMap);

      DatabaseServices(uid: '')
          .feedRef
          .doc(widget.ctuer.email)
          .collection('feed')
          .add({
        'type': 'question',
        'msgInfo': widget.question,
        'ownerID': widget.ctuer.email,
        'ownerName': widget.ctuer.name,
        'timestamp': DateTime.now(),
        'userDp': widget.userData.anonAvatar,
        'userID': widget.userData.nickname,
      });

      setState(() {
        saveReceiverCloud(widget.ctuer);
        message = "";
        messageTextEditingController.clear();
      });
    }
  }

  saveReceiverCloud(Ctuer hmmie) async {
    QuerySnapshot query =
        (await DatabaseServices(uid: hmmie.id).getReceiverToken(hmmie.email)) as QuerySnapshot<Object?>;
    String val = query.docs[0].get('token').toString();
    DatabaseServices(uid: '').cloudRef.doc().set({
      'type': 'question',
      'ownerID': hmmie.email,
      'ownerName': hmmie.name,
      'timestamp': DateTime.now(),
      'userDp': widget.userData.anonAvatar,
      'userID': widget.userData.nickname,
      'token': val,
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Now I do"),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: TextFormField(
                // initialValue: userData.name,
                // validator: (val) {
                //   return val.isEmpty ? 'Please provide some' : null;
                // },
                controller: messageTextEditingController,
                onChanged: (val) {
                  setState(() {
                    message = val;
                    player1Text = val;
                  });
                },
                style: TextStyle(color: Colors.white),
                decoration: textFieldInputDecoration('Your answer'),
                maxLines: 3,
              ),
            ),
            FlatButton(
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                // print(widget.userData.name);
                // print(widget.hmmie);
                sendMessage();
                DatabaseServices(uid: '').updateTrivia(
                    triviaRoomID: widget.triviaRoomID,
                    question: widget.question,
                    answer1: player1Text,
                    answer2: player2Text);
                // return Home(widget.userData, widget.hmmies);

                Navigator.of(context).pop(
                  MaterialPageRoute(
                    builder: (context) =>
                        const Home(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
