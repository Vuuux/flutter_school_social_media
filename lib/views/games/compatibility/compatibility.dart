import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:uuid/uuid.dart';
import 'compatibility_card.dart';
import 'compatibility_status.dart';

//Class trò trả lời câu hỏi
class QuestionGame extends StatefulWidget {
  final List<String> questions;
  final UserData ctuer;
  final UserData userData;
  final String gameRoomId;
  QuestionGame({
    Key? key,
    required this.questions,
    required this.ctuer,
    required this.userData,
    required this.gameRoomId,
  }) : super(key: key);

  @override
  _QuestionGameState createState() => _QuestionGameState();
}

class _QuestionGameState extends State<QuestionGame>
    with TickerProviderStateMixin {
  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  int index = 0;

  int i = 0;
  CompatibilityCard? currentCompatibilityCard;
  List<int> usedNumbers = [0];
  List<String> questions = [];
  List<String> myAnswers = [];
  Stream<QuerySnapshot>? compatibilityResults;
  late AnimationController controller;

  List<CompatibilityCard> cards = [
    const CompatibilityCard('3x2+5-3x8=', 'Không biết', '2'),
    const CompatibilityCard('Bạn có nhiều bạn không?', 'Có', 'Khôngg'),
    const CompatibilityCard(
        'Bạn thích sẽ follow ai trước??', 'Sơn Tùng', 'Jack'),
    const CompatibilityCard(
        'Bạn nhìn điều gì của mỗi người trước?', 'Vẻ ngoài', 'Tâm hồn'),
    const CompatibilityCard('Bạn từng 1 lần chơi ngu chưa?', 'Yess', 'Không'),
    const CompatibilityCard('Bạn bị công an thổi lần nào chưa?', 'Rồi huhu',
        'Tất nhiên là chưa rồi!'),
    const CompatibilityCard(
        'Thích bắt chuyện với người lạ chứ?', 'Yes!', 'Không nha!'),
    const CompatibilityCard('Socola hay Vani?', 'Socola', 'Vani'),
    const CompatibilityCard('Bạn yêu cha hay mẹ hơn?', 'Mẹ', 'Cha'),
    const CompatibilityCard(
        'Từng hôn bản thân trong gương chưa?', 'Rồi >//<', 'Chưa, ew!'),
    const CompatibilityCard(
        'Đã từng khóc nhiều đến mức thiếp đi chưa?', 'yeahh', 'nahh'),
    const CompatibilityCard(
        'Đã từng làm điều mà bạn tự bảo sẽ không bao giờ làm chưa?',
        'Rồi',
        'Không'),
    const CompatibilityCard(
        'Đang uống nước tự nhiên cười sặc?', 'Rồi =))', 'Chưa'),
    const CompatibilityCard('Thích da nâu hay da trắng?', 'Nâu', 'Trắng'),
    const CompatibilityCard(
        'Uống say bất tỉnh lần nào chưa?', 'Rồi', 'Chưa nhá'),
    const CompatibilityCard('Bạn đã từng thử hù ai chưa?', 'Rồi', 'Khôngg'),
    const CompatibilityCard('Từng khóc vì ai đó chưa?', 'Rồi', 'Không'),
    const CompatibilityCard('Bạn có nuôi chó chứ?', 'Có', 'hôngg'),
    const CompatibilityCard(
        'Từng thích bạn thân khác giới chưa?', 'Rồi', 'Chưaa'),
    const CompatibilityCard(
        'Bạn nghĩ giữa nam và nữ có thể có tình bạn trong sáng không?',
        'Có',
        'Không nhéeee'),
    const CompatibilityCard(
        'Bây giờ bạn có cảm thấy hạnh phúc không?', 'Có :>', 'Không'),
    const CompatibilityCard(
        'Have you ever doubted your sexuality?', 'Yes', 'No'),
    const CompatibilityCard('Had/Have a dog?', 'Yes', 'No'),
  ];
  List<int> indexes = [];

  initialize() {
    widget.questions.forEach((element1) {
      cards.forEach((element2) {
        if (element1 == element2.question) {
          indexes.add(cards.indexOf(element2));
        }
      });
    });
    indexes.add(0);
    generateRandomCard();
    print(indexes);
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );
    initialize();
    super.initState();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  generateRandomCard() {
    if (widget.questions.isEmpty) {
      while (usedNumbers.contains(index)) {
        index = Random().nextInt(cards.length);
      }
      usedNumbers.add(index);
    } else {
      index = indexes[i];
      i += 1;
    }

    print(myAnswers);
    print(questions);
    setState(() {
      currentCompatibilityCard = cards[index];
    });

    if (questions.length > 4) {
      print('Xong');
      print(myAnswers);
      print(questions);
      try {
        DatabaseServices(uid: '').createQAGameRoom(
            gameRoomId: widget.gameRoomId,
            player1: widget.userData.id,
            player2: widget.ctuer.id);
        DatabaseServices(uid: '').uploadAnswersQAGame(
          uid: widget.userData.id,
          gameRoomId: widget.gameRoomId,
          myAnswers: myAnswers,
        );
        DatabaseServices(uid: '').uploadQAGameQuestions(
          gameRoomId: widget.gameRoomId,
          questions: questions,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompatibilityStatus(
              userData: widget.userData,
              ctuer: widget.ctuer,
              gameRoomId: widget.gameRoomId,
            ),
          ),
        );
      } on FirebaseException catch (error) {
        Get.snackbar("Lỗi", "Có lỗi xảy ra:" + error.code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Q U I Z",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
        ),
      ),
      body: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height:
                        controller.value * MediaQuery.of(context).size.height,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Align(
                          alignment: FractionalOffset.center,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Stack(
                              children: <Widget>[
                                Align(
                                  alignment: FractionalOffset.center,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            6, 0, 6, 0),
                                        child: AutoSizeText(
                                          currentCompatibilityCard!.question,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        timerString,
                                        style: const TextStyle(
                                          fontSize: 112.0,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                questions.add(
                                                    currentCompatibilityCard!
                                                        .question);
                                                myAnswers.add(
                                                    currentCompatibilityCard!
                                                        .answer1);

                                                generateRandomCard();
                                              });
                                            },
                                            child: Container(
                                              height: 70,
                                              width: 130,
                                              color: Colors.purple[300],
                                              alignment: Alignment.center,
                                              child: AutoSizeText(
                                                currentCompatibilityCard!
                                                    .answer1,
                                                style: const TextStyle(
                                                    fontSize: 20.0,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                questions.add(
                                                    currentCompatibilityCard!
                                                        .question);
                                                myAnswers.add(
                                                    currentCompatibilityCard!
                                                        .answer2);
                                                generateRandomCard();
                                              });
                                            },
                                            child: Container(
                                              height: 70,
                                              width: 130,
                                              color: Colors.blueAccent,
                                              alignment: Alignment.center,
                                              child: AutoSizeText(
                                                currentCompatibilityCard!
                                                    .answer2,
                                                style: const TextStyle(
                                                    fontSize: 20.0,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                          animation: controller,
                          builder: (context, child) {
                            return FloatingActionButton.extended(
                              onPressed: () {
                                if (controller.isAnimating) {
                                  controller.stop();
                                } else {
                                  controller.reverse(
                                      from: controller.value == 0.0
                                          ? 1.0
                                          : controller.value);
                                }
                              },
                              icon: Icon(controller.isAnimating
                                  ? Icons.pause
                                  : Icons.play_arrow),
                              label: Text(
                                  controller.isAnimating ? "Pause" : "Play"),
                            );
                          }),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}

// class CustomTimerPainter extends CustomPainter {
//   CustomTimerPainter({
//     this.animation,
//     this.backgroundColor,
//     this.color,
//   }) : super(repaint: animation);

//   final Animation<double> animation;
//   final Color backgroundColor, color;
//   final double pi = 3.1415926535897932;

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = backgroundColor
//       ..strokeWidth = 10.0
//       ..strokeCap = StrokeCap.butt
//       ..style = PaintingStyle.stroke;

//     canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
//     paint.color = color;
//     double progress = (1.0 - animation.value) * 2 * pi;
//     canvas.drawArc(Offset.zero & size, pi * 1.5, -progress, false, paint);
//   }

//   @override
//   bool shouldRepaint(CustomTimerPainter old) {
//     return animation.value != old.animation.value ||
//         color != old.color ||
//         backgroundColor != old.backgroundColor;
//   }
// }
