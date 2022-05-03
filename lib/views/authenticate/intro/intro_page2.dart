import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:luanvanflutter/views/games/trivia/trivia.dart';
import 'package:luanvanflutter/home.dart';
import 'package:uuid/uuid.dart';

class IntroPage2 extends StatefulWidget {
  UserData userData;
  List<UserData> ctuerList;
  UserData chosenCtuer;

  IntroPage2(
      {Key? key,
      required this.chosenCtuer,
      required this.userData,
      required this.ctuerList})
      : super(key: key);

  @override
  _IntroPage2State createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  late String triviaRoomId = Uuid().v4();
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    String gender =
        widget.chosenCtuer.gender.toUpperCase() == 'MALE' ? "Nam" : "Nữ";
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
                    "Bạn mới của bạn đây!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FlipCard(
                      key: cardKey,
                      flipOnTouch: true,
                      direction: FlipDirection.HORIZONTAL,
                      front: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: MediaQuery.of(context).size.width * 0.92,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(4, 4),
                                  color: Colors.grey.shade500,
                                  blurRadius: 15,
                                  spreadRadius: 1),
                              const BoxShadow(
                                  offset: Offset(-4, -4),
                                  color: Colors.white,
                                  blurRadius: 15,
                                  spreadRadius: 1)
                            ],
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  widget.chosenCtuer.avatar),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 0,
                                bottom: 10,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(25),
                                  ),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color(0xFFFFFFF).withOpacity(0.8),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(22),
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  widget.chosenCtuer.username
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                flex: 2,
                                              ),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      widget.chosenCtuer.likes
                                                              .length
                                                              .toString() +
                                                          " ",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const Icon(
                                                      FontAwesomeIcons
                                                          .solidHeart,
                                                      color: Colors.red,
                                                    ),
                                                  ],
                                                ),
                                                flex: 1,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Giới tính: " + gender,
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
                                            "Ngành: ${widget.chosenCtuer.major}",
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
                      ),
                      back: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: MediaQuery.of(context).size.width * 0.92,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(4, 4),
                                  color: Colors.grey.shade500,
                                  blurRadius: 15,
                                  spreadRadius: 1),
                              const BoxShadow(
                                  offset: Offset(-4, -4),
                                  color: Colors.white,
                                  blurRadius: 15,
                                  spreadRadius: 1)
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                  colorBlendMode: BlendMode.softLight,
                                  imageUrl: widget.chosenCtuer.avatar),
                              Center(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5.0, sigmaY: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5)),
                                    child: Container(),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Giới thiệu về bản thân:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    widget.chosenCtuer.bio,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ))
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
              onPressed: () async {
                var response =
                    await DatabaseServices(uid: _auth.currentUser!.uid)
                        .increaseFame(
                            widget.chosenCtuer.id,
                            widget.userData.likes.length,
                            SubUserData(
                                id: widget.userData.id,
                                username: widget.userData.username,
                                avatar: widget.userData.avatar));

                response.fold((result) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => Trivia(
                        ctuerData: widget.chosenCtuer,
                        currentUserData: widget.userData,
                        ctuerList: widget.ctuerList,
                        triviaRoomId: triviaRoomId,
                      ),
                    ),
                  );
                },
                    (error) => Get.snackbar(
                        "Lỗi", "Có lỗi xảy ra: " + error.code,
                        snackPosition: SnackPosition.BOTTOM));
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
