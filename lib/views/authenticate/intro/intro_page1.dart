import 'dart:math';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import '../../../models/user.dart';
import '../../../models/ctuer.dart';
import 'intro_page2.dart';

class IntroPage1 extends StatefulWidget {
  UserData userData;
  List<Ctuer> ctuerList;

  IntroPage1({required this.userData, required this.ctuerList});
  @override
  _IntroPage1State createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage1> {
  late int index;
  late Ctuer chosenCtuer;
  @override
  void initState() {
    index = Random().nextInt(widget.ctuerList.length);

    chosenCtuer = widget.ctuerList[index];
    while (chosenCtuer.name == widget.userData.name) {
      index = Random().nextInt(widget.ctuerList.length);
      chosenCtuer = widget.ctuerList[index];
    }
    print(chosenCtuer.name);
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.95,
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
                left: 30,
                right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Chúng tôi đã tìm ra cho bạn 1 người bạn!",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                FlatButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      height: 500,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        'Click!',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    //TODO: ADD UID
                    DatabaseServices(uid: '').uploadBondData(
                      userData: widget.userData,
                      myAnon: true,
                      hmmie: chosenCtuer,
                      friendAnon: true,
                      chatRoomID: getChatRoomID(
                          widget.userData.nickname, chosenCtuer.nickname),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => IntroPage2(
                          chosenCtuer: chosenCtuer,
                          userData: widget.userData,
                          ctuerList: widget.ctuerList,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
