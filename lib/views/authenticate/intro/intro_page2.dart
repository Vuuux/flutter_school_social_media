import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:luanvanflutter/views/games/trivia/trivia.dart';
import 'package:luanvanflutter/views/home/home.dart';

class IntroPage2 extends StatefulWidget {
  UserData userData;
  List<UserData> ctuerList;
  UserData chosenCtuer;

  IntroPage2(
      {required this.chosenCtuer,
      required this.userData,
      required this.ctuerList});

  @override
  _IntroPage2State createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            child: Container(
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
                    "Gặp bạn mới",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width * 0.92,
                      decoration: widget.chosenCtuer.anonAvatar == ''
                          ? const BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage('assets/images/profile1.png'),
                              ),
                            )
                          : BoxDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage(widget.chosenCtuer.anonAvatar),
                              ),
                            ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            bottom: MediaQuery.of(context).size.height * 0.1,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(25),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFF).withOpacity(0.8),
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(22),
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(
                                            "${widget.chosenCtuer.nickname}, ${widget.chosenCtuer.gender}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            LineAwesomeIcons.star_1,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          Text(
                                            'Fame: ' +
                                                widget.chosenCtuer.fame
                                                    .toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Khóa: ${widget.chosenCtuer.course}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Bio: ${widget.chosenCtuer.anonBio}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.03,
            left: MediaQuery.of(context).size.width * 0.30,
            child: FloatingActionButton(
              splashColor: Colors.transparent,
              heroTag: "cross",
              onPressed: () {
                Navigator.of(context).pop(
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
              backgroundColor: Colors.white,
              elevation: 10,
              child: const Icon(
                Icons.close,
                color: Color(0xFFA29FBE),
                size: 28,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.03,
            right: MediaQuery.of(context).size.width * 0.30,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => Trivia(
                      widget.chosenCtuer,
                      widget.userData,
                      widget.ctuerList,
                    ),
                  ),
                );
              },
              heroTag: "heart",
              backgroundColor: Colors.white,
              elevation: 10,
              child: const Icon(
                FontAwesomeIcons.solidHeart,
                color: Color(0xFFFF636B),
                size: 24,
              ),
            ),
          )
        ],
      ),
    );
  }
}
