import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/games/compatibility/compatibility_start.dart';

class CompatibilityStatus extends StatefulWidget {
  final String gameRoomId;
  final UserData ctuer;
  final UserData userData;

  const CompatibilityStatus(
      {Key? key,
      required this.ctuer,
      required this.userData,
      required this.gameRoomId})
      : super(key: key);

  @override
  _CompatibilityStatusState createState() => _CompatibilityStatusState();
}

class _CompatibilityStatusState extends State<CompatibilityStatus> {
  List<String> answer1 = [];
  List<String> answer2 = [];

  late Stream<DocumentSnapshot> myCompatibilityResults;
  late Stream<DocumentSnapshot> friendCompatibilityResults;
  late Stream<QuerySnapshot> compatibilityQuestions;
  late List<String> friendAnswer;

  Widget compatibilityResultsList() {
    return StreamBuilder<QuerySnapshot>(
        stream: compatibilityQuestions,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return snapshot.data!.docs.isNotEmpty &&
                    snapshot.data!.docs[0].get('questions').isNotEmpty
                ? StreamBuilder<DocumentSnapshot>(
                    stream: myCompatibilityResults,
                    builder: (context, snapshot1) {
                      if (snapshot1.data != null) {
                        return snapshot1.data!.exists &&
                                snapshot1.data!.get('answers').isNotEmpty
                            ? StreamBuilder<DocumentSnapshot>(
                                stream: friendCompatibilityResults,
                                builder: (context, snapshot2) {
                                  if (snapshot2.data != null) {
                                    return snapshot2.data!.exists &&
                                            snapshot2.data!
                                                .get('answers')
                                                .isNotEmpty
                                        ? ListView.builder(
                                            itemCount: 5,
                                            itemBuilder: (context, index) {
                                              return CompatibilityTile(
                                                friendAnswer: snapshot2.data!
                                                        .get(
                                                            'answers')[index] ??
                                                    'not filled',
                                                myAnswer: snapshot1.data!.get(
                                                        'answers')[index] ??
                                                    'not filled',
                                                question: snapshot.data!.docs[0]
                                                    .get('questions')[index],
                                              );
                                            })
                                        : Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(30),
                                              child: AutoSizeText(
                                                "${widget.ctuer.username} chưa hoàn thành Quiz",
                                                style: const TextStyle(
                                                    fontSize: 40,
                                                    fontWeight:
                                                        FontWeight.w100),
                                              ),
                                            ),
                                          );
                                  } else {
                                    return Loading();
                                  }
                                })
                            : const Center(
                                child: Text(
                                  "Bạn chưa hoàn thành Quiz",
                                  style: TextStyle(
                                      fontSize: 40, color: Colors.white),
                                ),
                              );
                      } else {
                        return Loading();
                      }
                    })
                : const Center(
                    child: Text(
                      "Không có quiz nào",
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  );
          } else {
            return Loading();
          }
        });
  }

  @override
  void initState() {
    help();
    initialize();
    super.initState();
  }

  initialize() {
    myCompatibilityResults = DatabaseServices(uid: '').getMyQAGameResults(
      widget.userData.id,
      widget.gameRoomId,
    );

    friendCompatibilityResults = DatabaseServices(uid: '').getFriendCompResults(
      widget.ctuer.id,
      widget.gameRoomId,
    );

    compatibilityQuestions = DatabaseServices(uid: '').getCompQuestions(
      widget.gameRoomId,
    );
  }

  Future<int> documentThings() async {
    int count = 0;
    List<String> myAnswers = [];
    List<String> friendAnswers = [];

    try {
      DocumentSnapshot docMyAnswers = await DatabaseServices(uid: '')
          .getDocMyCompatibilityAnswers(widget.userData.id, widget.gameRoomId);
      DocumentSnapshot docFriendAnswers = await DatabaseServices(uid: '')
          .getDocFriendCompatibilityAnswers(widget.ctuer.id, widget.gameRoomId);
      myAnswers = List<String>.from(
          docMyAnswers.get("answers").map((String ans) => ans.toString()));
      friendAnswers = List<String>.from(docFriendAnswers.get("answers"));
      if (docFriendAnswers.exists && docMyAnswers.exists) {
        for (int i = 0; i < 5; i++) {
          if (answer1.length < 5) {
            answer1.add(docMyAnswers.get('answers')[i].toString());
            answer2.add(docFriendAnswers.get('answers')[i].toString());

            if (docMyAnswers.get('answers')[i].toString() ==
                docFriendAnswers.get('answers')[i].toString()) {
              count++;
            }
          }
        }
      }
    } on FirebaseException catch (error) {
      Get.snackbar("Lỗi", "Có lỗi xảy ra:" + error.code,
          snackPosition: SnackPosition.BOTTOM);
    }

    return count;
  }

  int score = 0;

  help() async {
    return await documentThings().then((val) {
      setState(() {
        score = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.blueGrey,
        title: const Text(
          "K Ế T   Q U Ả",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Score: $score',
                textAlign: TextAlign.end,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
              ),
            ),
          ),
          compatibilityResultsList(),
          Align(
              alignment: const Alignment(0, 0.85),
              child: Container(
                height: 50,
                width: 150,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    )),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      score = 0;
                    });
                    DatabaseServices(uid: '').uploadAnswersQAGame(
                      uid: widget.userData.id,
                      gameRoomId: widget.gameRoomId,
                      myAnswers: [],
                    );
                    DatabaseServices(uid: '').uploadQAGameQuestions(
                      gameRoomId: widget.gameRoomId,
                      questions: [],
                    );
                    DatabaseServices(uid: '').uploadFriendAnswersQAGame(
                      ctuerId: widget.ctuer.id,
                      gameRoomId: widget.gameRoomId,
                      myAnswers: [],
                    );
                    Get.to(() => CompatibilityStart(
                        userData: widget.userData, ctuer: widget.ctuer));
                  },
                  child: Center(
                    child: Text(
                      'CHƠI LẠI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w100,
                          color: Get.isDarkMode ? Colors.black : Colors.white),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

class CompatibilityTile extends StatelessWidget {
  final String question;
  final String myAnswer;
  final String friendAnswer;

  const CompatibilityTile(
      {required this.question,
      required this.myAnswer,
      required this.friendAnswer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            question,
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  myAnswer,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                Text(
                  friendAnswer,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
