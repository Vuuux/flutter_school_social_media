import 'dart:math';
import 'package:eventual/eventual-notifier.dart';
import 'package:eventual/eventual-single-builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/widget_extensions.dart';
import '../../../models/user.dart';
import '../../../models/ctuer.dart';
import 'intro_page2.dart';

class IntroPage1 extends StatefulWidget {
  UserData userData;
  List<UserData> ctuerList;

  IntroPage1({Key? key, required this.userData, required this.ctuerList})
      : super(key: key);
  @override
  _IntroPage1State createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage1> {
  late int index;
  late UserData chosenCtuer;
  final EventualNotifier<bool> _isShow = EventualNotifier<bool>(false);
  @override
  void initState() {
    index = Random().nextInt(widget.ctuerList.length);

    chosenCtuer = widget.ctuerList[index];
    while (chosenCtuer.username == widget.userData.username) {
      index = Random().nextInt(widget.ctuerList.length);
      chosenCtuer = widget.ctuerList[index];
    }
    print(chosenCtuer.username);
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                EventualSingleBuilder(
                    notifier: _isShow,
                    builder: (context, notifier, child) {
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            if (notifier.value) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => IntroPage2(
                                    chosenCtuer: chosenCtuer,
                                    userData: widget.userData,
                                    ctuerList: widget.ctuerList,
                                  ),
                                ),
                              );
                            } else {
                              _isShow.value = !_isShow.value;
                              _isShow.notifyChange();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: notifier.value
                                    ? [
                                        BoxShadow(
                                            offset: const Offset(4, 4),
                                            color: Colors.grey.shade700,
                                            blurRadius: 15,
                                            spreadRadius: 1),
                                        const BoxShadow(
                                            offset: Offset(-4, -4),
                                            color: Colors.white,
                                            blurRadius: 15,
                                            spreadRadius: 1)
                                      ]
                                    : null),
                            child: FittedBox(
                              child: Text(
                                notifier.value
                                    ? 'GẶP BẠN MỚI THÔI'
                                    : 'CHẠM VÀO TỚ ĐI!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24,
                                ),
                              ).padding(EdgeInsets.all(8.0)),
                            ),
                          ),
                        ),
                      );
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
