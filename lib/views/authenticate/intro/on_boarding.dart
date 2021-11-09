import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/authenticate/intro/filterpage.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:provider/provider.dart';

//class nhập môn, tạo hướng dẫn và thông báo ứng dụng
class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final pageDecoration = PageDecoration(
    titleTextStyle:
        const PageDecoration().titleTextStyle.copyWith(color: Colors.black),
    bodyTextStyle: const PageDecoration().bodyTextStyle.copyWith(color: Colors.black),
    contentPadding: const EdgeInsets.all(10),
  );

  //Tạo screen hướng dẫn
  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        image: Image.asset("assets/images/community.png"),
        title: "Chào mừng đã đến với CTUPG",
        body: "Cùng nhau tham gia vào cộng đồng nào!",
        decoration: pageDecoration,
      ),
      PageViewModel(
          image: Image.asset("assets/images/cuteghost.png"),
          title: "Chế độ ẩn danh để bạn dễ dàng đặt câu hỏi",
          body:
              "Kết bạn mỗi ngày và bắt đầu cuộc trò chuyện với 1 trò chơi nhỏ",
          decoration: pageDecoration),
      PageViewModel(
        image: Image.asset("assets/images/converse.png"),
        title: "Gởi tin nhắn",
        body: "Kết nối cùng bạn bè và chia sẻ khoảnh khắc!",
        decoration: pageDecoration,
      ),
      PageViewModel(
          image: Image.asset("assets/images/gaming.png"),
          title: "Quẩy Game",
          body: "Còn gì tuyệt hơn khi tìm được bạn chơi game cùng?",
          decoration: pageDecoration),
    ];
  }

  createAlertDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return const CustomDialog(
            title: 'Đi kết bạn nào!',
            description: 'Hôm nay bạn sẽ kết bạn với Hmmie nào đây?',
            buttonText: 'Tìm hiểu',
          );
        });
  }

  @override
  void initState() {
    initializing();
    super.initState();
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late AndroidInitializationSettings androidInitializationSettings;
  late IOSInitializationSettings iosInitializationSettings;
  late InitializationSettings initializationSettings;

  void initializing() async {
    androidInitializationSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _showNotifications() async {
    await notification();
  }

  void _showNotificationsAfterSecond() async {
    await notificationAfterSec();
  }

  Future<void> notification() async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority.high,
            importance: Importance.max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = const IOSNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'Xin chào bạn', 'sử dụng app vui vẻ nhé', notificationDetails);
    createAlertDialog();
  }

  Future<void> notificationAfterSec() async {
    // var timeDelayed = DateTime.now().add(Duration(seconds: 5));
    var time = const Time(21, 00, 0);
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
            'second channel ID', 'second Channel title', 'second channel body',
            priority: Priority.high,
            importance: Importance.max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = const IOSNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    // await flutterLocalNotificationsPlugin.schedule(1, 'Hello there',
    //     'please subscribe my channel', timeDelayed, notificationDetails);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        1, "CTUER", "Kết bạn ngay!", time, notificationDetails);
  }

  Future<void> onSelectNotification(String? payLoad) async {
    if (payLoad != null) {
      print(payLoad);
      createAlertDialog();
    }
    //TODO: Set navigator to other screen
    // we can set navigator to navigate another screen
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    return CupertinoAlertDialog(
      title: Text(title!),
      content: Text(body!),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("");
            },
            child: const Text("Okay")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      // ),
      body: Padding(
        padding: const EdgeInsets.only(top: 200),
        child: IntroductionScreen(
          showSkipButton: true,
          skip: const Text("Bỏ qua"),
          pages: getPages(),
          done: const Text(
            "Let's go!",
            style: TextStyle(color: kPrimaryColor),
          ),
          onDone: () {
            _showNotifications();
            _showNotificationsAfterSecond();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Wrapper(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;

  const CustomDialog(
      {required this.title,
      required this.description,
      required this.buttonText,});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    final user = Provider.of<CurrentUser?>(context);
    List<UserData> ctuerList;
    return StreamBuilder<Object>(
        stream: DatabaseServices(uid: user!.uid).userData,
        builder: (context, snapshot) {
          Object? userData = snapshot.data;
          if (userData != null) {
            return StreamBuilder<List<UserData>>(
              stream: DatabaseServices(uid: user.uid).ctuerList,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  ctuerList = snapshot.data!;

                  return Stack(
                    children: <Widget>[
                      Container(
                          padding: const EdgeInsets.only(
                              top: 100, bottom: 16, left: 14, right: 14),
                          margin: const EdgeInsets.only(top: 50),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(17),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 10),
                                )
                              ]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(title,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimaryColor)),
                              Text(description,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w100,
                                      color: Colors.black)),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => Filterpage(
                                            userData: userData as UserData,
                                            ctuerList: ctuerList),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'DZÔ',
                                    style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            radius: 60,
                            backgroundImage: AssetImage('assets/images/WTaB.gif'),
                          ))
                    ],
                  );
                }
                return Loading();
              }
            );
          } else {
            return Loading();
          }
        });
  }
}
