import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/question.dart';
import 'package:luanvanflutter/models/user.dart';

import 'answerscreen.dart';

class Trivia extends StatefulWidget {
  UserData userData;
  List<UserData> ctuerList;
  UserData ctuer;

  Trivia(this.ctuer, this.userData, this.ctuerList);

  @override
  _TriviaState createState() => _TriviaState();
}

class _TriviaState extends State<Trivia> {
  int index = 0;
  late String currentQuestion; //câu hỏi hiện tại

  //List câu hỏi
  List<Questions> questions = [
    Questions(text: 'Chọn 1 thẻ'),
    Questions(text: 'Nếu bạn có thể sống ở bất cứ đâu, thì nơi bạn chọn là?'),
    Questions(text: 'Bạn sợ nhất điều gì?'),
    Questions(text: 'Kỳ nghỉ ưa thích nhất của bạn?'),
    Questions(text: 'Nếu có thể thì bạn muốn thay đổi bản thân thế nào?'),
    Questions(text: 'Điều gì làm bạn thật sự dễ tức giận?'),
    Questions(text: 'Động lực nào để bạn cố gắng học tập?'),
    Questions(text: 'Điều tuyệt nhất trong cuộc đời sinh viên của bạn?'),
    Questions(text: 'Điều bất mãn nhất với công việc của bạn?'),
    Questions(text: 'Thành tích đáng tự hào nhất của bạn là gì?'),
    Questions(text: 'Bạn có yêu thích đoàn khoa không?'),
    Questions(text: 'Thứ gì dễ lấy được nụ cười của bạn?'),
    Questions(text: 'Bộ phim cuối cùng bạn từng khen?'),
    Questions(text: 'Lúc còn bé, bạn muốn trở thành ai?'),
    Questions(text: 'Bạn có yêu khoa và ngành của mình không?'),
    Questions(
        text:
        'Nếu bạn có quyền làm mọi thứ trong 24h, bạn sẽ làm gì?'),
    Questions(text: 'Trò chơi ưa thích của bạn là gì?'),
    Questions(
        text: 'Xe đạp, xe máy, xe hơi hay máy bay?'),
    Questions(text: 'Bạn hát bài gì đầu tiên nếu đi Karaoke?'),
    Questions(
        text: 'Hai môn học phần bạn ưa thích nhất?'),
    Questions(
        text:
        'Lần cuối bạn rơi lệ là khi nào?'),
    Questions(
        text:
        'Nếu bạn có quyền chọn bạn gái, bạn sẽ chọn mẫu người thế nào?'),
    Questions(
        text:
        'Nếu bạn chỉ có thể ăn 1 món duy nhất trong phần đời còn lại của mình, bạn sẽ chọn món gì?'),
    Questions(text: 'Tác giả yêu thích của bạn?'),
    Questions(text: 'Bạn đã từng có biệt danh nào rồi?'),
    Questions(text: 'Bạn có thích sự bất ngờ không? Giải thích đi.'),
    Questions(
        text:
        'Vào buổi tối, bạn sẽ thích làm gì?'),
    Questions(text: 'Hà Nội hay Sài Gòn?'),
    Questions(
        text:
        'Giữa trúng số và có được một công việc hoàn hảo, bạn chọn cái nào?'),
    Questions(
        text: 'Nếu bạn bị lạc ra hoang đảo, bạn muốn ở cùng ai?'),
    Questions(
        text: 'Nếu mà tiền bạc không còn là vấn đề nữa, bạn sẽ làm gì mỗi ngày?'),
    Questions(
        text: 'Nếu mà bạn có thể du hành thời gian, bạn sẽ quay lại thời điểm nào?'),
    Questions(text: 'Bạn bè của bạn miêu tả bạn thế nào?'),
    Questions(text: 'Sở thích của bạn là gì?'),
    Questions(text: 'Món quà tuyệt vời nhất bạn từng nhận được?'),
    Questions(text: 'Món quà tệ nhất mà bạn từng nhận được là gì?'),
    Questions(
        text:
        'Bên cạnh những vật dụng cần thiết, món nào là vật bất ly thân của bạn khi ra ngoài?'),
    Questions(text: 'Kể tên vật nuôi yêu thích của bạn đi.'),
    Questions(text: 'Sau 5 năm bạn thấy mình đã thay đổi thế nào?'),
    Questions(text: 'Bạn sở hữu bao nhiêu đôi giày?'),
    Questions(text: 'Nếu bạn có siêu năng lực, bạn muốn nó là gì?'),
    Questions(text: 'Bạn sẽ làm gì nếu trúng số độc đắc?'),
    Questions(
        text:
        'Bạn thích di chuyển trên loại phương tiện nào?'),
    Questions(text: 'Sở thú nào bạn từng ghé qua rồi?'),
    Questions(
        text:
        'Bạn muốn giây phút cuối đời của bạn sẽ như thế nào?'),
    Questions(
        text:
        'Nếu bạn có thể ăn cùng 4 người, dù sống hay đã mất, thì sẽ là những người nào?'),
    Questions(text: 'Ngủ với bao nhiêu cái gối là đủ?'),
    Questions(
        text: 'Lần mất ngủ lâu nhất của bạn là bao lâu?'),
    Questions(text: 'Tòa nhà cao nhất bạn từng đến?'),
    Questions(
        text:
        'Bạn có sẵn lòng dùng trí thông minh của mình đổi lấy trí tuệ không?'),
    Questions(text: 'Bạn có thường xuyên shopping không?'),
    Questions(text: 'Đã từng có ai thầm ngưỡng mộ bạn chưa?'),
    Questions(text: 'Ngày nghỉ yêu thích của bạn sẽ như thế nào?'),
    Questions(text: 'Việc liều nhất bạn từng làm là gì?'),
    Questions(text: 'Thứ cuối cùng bạn ghi hình lại trên điện thoại là?'),
    Questions(text: 'Quyển sách cuối cùng mà bạn đọc'),
    Questions(text: 'Món ăn nước ngoài nào bạn mê nhất?'),
    Questions(text: 'Bạn là người sống sạch sẽ hay bừa bộn?'),
    Questions(
        text: 'Nếu bạn là diễn viên trong 1 bộ phim, bạn sẽ là nhân vật nào?'),
    Questions(text: 'Bạn tốn bao lâu để chuẩn bị cho buổi sáng?'),
    Questions(text: 'Bạn thích món nước hay món khô?'),
    Questions(text: 'Chuỗi cửa hàng thức ăn nhanh yêu thích của bạn?'),
    Questions(text: 'Tình yêu lý tưởng của các hạ là?'),
    Questions(text: 'Thích hay ghét tàu lượn siêu tốc?'),
    Questions(text: 'Truyền thống gia đình yêu thích của bạn?'),
    Questions(text: 'Kỷ niệm tuổi thơ đáng nhớ nhất của bạn là gì?'),
    Questions(text: 'Bộ phim ưa thích của bạn là gì?'),
    Questions(
        text:
        'Lần đầu bạn nhận ra Ông già Noel không tồn tại là lúc mấy tuổi và bằng cách nào?'),
    Questions(text: 'Bạn chọn tình yêu hay sự nghiệp'),
    Questions(
        text: 'Chuyện điên nhất mà bạn từng làm trong tình cảm?'),
    Questions(
        text: 'Nếu bị đem ra hoang đảo, bạn sẽ đem cái gì theo?'),
    Questions(text: 'Ngôn ngữ ưa thích của bạn?'),
    Questions(text: 'Thứ kì lạ nhất bạn từng bỏ vào miệng là gì?'),
    Questions(text: 'Bạn có sưu tập thứ gì không?'),
    Questions(
        text: 'Bạn có muốn style thời trang nào nổi tiếng trở lại không?'),
    Questions(text: 'Bạn là người hướng ngoại hay hướng nội?'),
    Questions(
        text: 'Giác quan nào của bạn mạnh nhất trong 5 giác quan?'),
    Questions(
        text:
        'Bạn đã từng nhận được món quà bất ngờ nào chưa?'),
    Questions(text: 'Bạn có họ hàng với người nổi tiếng nào không?'),
    Questions(text: 'Bạn làm gì để giữ dáng?'),
    Questions(text: 'Gia đình bạn có tiêu chuẩn sống nào không?'),
    Questions(
        text:
        'Nếu bạn cai trị một quốc gia, điều luật đầu tiên bạn đặt ra là gì?'),
    Questions(
        text: 'Ai là giáo viên ưu thích của bạn trong trường và tại sao?'),
    Questions(text: '3 thứ mà bạn nghĩ về nhiều nhất trong ngày?'),
    Questions(
        text: 'Nếu bạn nhận được điềm báo không lành, bạn nghĩ nó sẽ là gì?'),
    Questions(text: 'Thứ gì có thể làm bạn lên tinh thần ngay lập tức?'),
    Questions(
        text:
        'Bạn có muốn gặp 1 người nổi tiếng? Và đó là ai?'),
    Questions(text: 'Ai là crush đầu tiên của bạn?'),
    Questions(text: 'Hãy tự đánh giá độ hài hước của bạn trên thang điểm 10'),
    Questions(
        text: 'Sau 10 năm nhìn lại bản thân, bạn thấy mình thay đổi thế nào rồi?'),
    Questions(text: 'Việc làm đầu tiên bạn được nhận là gì?'),
    Questions(text: 'Bạn nói được bao nhiêu thứ tiếng?'),
    Questions(text: 'Người thông minh nhất bạn từng gặp là ai?'),
    Questions(
        text:
        'Bạn sẽ dùng con vật nào để mô tả bản thân mình?'),
    Questions(text: 'Thứ gì mà bạn sẽ không bao giờ thử?'),
    Questions(text: 'Ai hiểu rõ bạn nhất?'),
  ];

  late Widget currentCard;

  generateRandomCard() {
    index = Random().nextInt(questions.length);
    print(index);
    setState(() {
      currentCard = questionTemplate(index, questions);
    });
    return questionTemplate(index, questions);
  }

  Widget questionTemplate(index, question) {
    currentQuestion = question[index].text;
    this.index = index;
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 300,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: AutoSizeText(
          question[index].text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  getTriviaRoomID(String a, String b) {
    // print(a);
    // print(b);
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  answerQuestion() {
    //TODO: ADD UID
    DatabaseServices(uid: '').createTriviaRoom(
        getTriviaRoomID(widget.userData.username, widget.ctuer.username),
        widget.userData.username,
        widget.ctuer.username);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AnswerScreen(
                ctuerList: widget.ctuerList,
                userData: widget.userData,
                triviaRoomID: getTriviaRoomID(
                    widget.userData.nickname, widget.ctuer.nickname),
                ctuer: widget.ctuer,
                question: this.currentQuestion),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tôi có quen bạn không?',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(child: currentCard),
          RaisedButton(
            child: const Text(
              'Đổi Card',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              generateRandomCard();
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            child: const Text(
              'Trả lời',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              print(widget.ctuer);
              answerQuestion();
            },
          )
        ],
      ),
    );
  }
}