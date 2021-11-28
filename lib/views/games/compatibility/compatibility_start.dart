import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

import '../compatibility/compatibility_intro_page.dart';
import 'compatibility_status.dart';

class CompatibilityStart extends StatefulWidget {
  final UserData ctuer;
  final UserData userData;
  String? gameRoomId;

  CompatibilityStart(
      {Key? key,
      required this.userData,
      required this.ctuer,
      this.gameRoomId = ''})
      : super(key: key);

  @override
  _CompatibilityStartState createState() => _CompatibilityStartState();
}

class _CompatibilityStartState extends State<CompatibilityStart> {
  DatabaseServices db = DatabaseServices(uid: '');
  late String toggle;
  bool requested = false;
  String gameRoomId = '';

  @override
  void initState() {
    widget.gameRoomId =
        widget.gameRoomId!.isEmpty ? const Uuid().v4() : widget.gameRoomId;
  } // saveReceiverCloudForRequest(userData) async {
  //   QuerySnapshot query = await DatabaseServices(uid: widget.ctuer.id)
  //       .getReceiverToken(widget.ctuer.email);
  //   String val = query.docs[0].get('token').toString();
  //   db.cloudRef.doc().set({
  //     'type': 'compatibility',
  //     'ownerID': widget.ctuer.email,
  //     'ownerName': widget.ctuer.name,
  //     'timestamp': DateTime.now(),
  //     'userDp': userData.avatar,
  //     'userID': userData.name,
  //     'token': val,
  //   });
  // }

  sendRequest(UserData userData) {
    setState(() {
      requested = true;
      toggle = 'join';
    });
    // saveReceiverCloudForRequest(widget.userData);
    db.addQAGameRequestNotifiCation(widget.ctuer.id, widget.gameRoomId!, {
      "type": "qa-game",
      "username": userData.nickname,
      "userId": userData.id,
      "avatar": userData.anonAvatar,
      "gameRoomId": gameRoomId,
      "mediaUrl": "",
      "timestamp": Timestamp.now(),
      "status": "unseen",
      "isAnon": true
    });
    // db.feedRef
    //     .doc(widget.ctuer.email)
    //     .collection('feed')
    //     .doc(y)
    //     .set({
    //   'type': 'compatibility',
    //   'ownerID': widget.ctuer.email,
    //   'ownerName': widget.ctuer.name,
    //   'timestamp': DateTime.now(),
    //   'userDp': widget.userData.avatar,
    //   'userID': widget.userData.name,
    //   'status': 'sent',
    //   'senderEmail': widget.userData.email,
    //   'notifID': y
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(LineAwesomeIcons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
            }),
        title: const Text("Q U I Z   V U I",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 55,
            child: SizedBox(
              child:
                  Image.asset('assets/images/compatible.png', fit: BoxFit.fill),
            ),
          ),
          const SizedBox(height: 50),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      )),
                  child: FlatButton(
                    child: const Text('Results'),
                    onPressed: () {
                      sendRequest(widget.userData);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CompatibilityStatus(
                            gameRoomId: widget.gameRoomId!,
                            ctuer: widget.ctuer,
                            userData: widget.userData,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      )),
                  child: FlatButton(
                    child: const Text('Play'),
                    onPressed: () {
                      sendRequest(widget.userData);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CompatibilityIntroPage(
                            ctuer: widget.ctuer,
                            userData: widget.userData,
                            gameRoomId: widget.gameRoomId!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
