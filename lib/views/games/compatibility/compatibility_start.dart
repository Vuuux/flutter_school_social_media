import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/widget_extensions.dart';
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
    super.initState();
    widget.gameRoomId =
        widget.gameRoomId!.isEmpty ? const Uuid().v4() : widget.gameRoomId;
  }

  sendRequest(UserData userData) {
    setState(() {
      requested = true;
      toggle = 'join';
    });
    // saveReceiverCloudForRequest(widget.userData);
    db.addQAGameRequestNotifiCation(widget.ctuer.id, widget.gameRoomId!, {
      'notifId': Uuid().v1(),
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
          Text(
            "Thử trả lời 5 câu hỏi trong thời gian giới hạn để xem 2 bạn hợp nhau ra sao nhé!",
            textAlign: TextAlign.center,
          ).padding(EdgeInsets.symmetric(
              vertical: Dimen.paddingCommon20,
              horizontal: Dimen.paddingCommon15)),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: 150,
                decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    )),
                child: FlatButton(
                  child: const Text('Kết quả'),
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
              Container(
                width: 150,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    )),
                child: FlatButton(
                  child: const Text('Chơi'),
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
            ],
          ),
        ],
      ),
    );
  }
}
