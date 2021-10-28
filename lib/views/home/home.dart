
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/home/profile/profile.dart';
import 'package:luanvanflutter/views/home/search/example_search_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import 'chat/chat_screen.dart';
import 'feed/feed.dart';
import 'notifications_page.dart';

//Trang chủ sau đăng nhập
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static bool anonymous = false;
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late CurrentUser? user;
  //Các tab ở chế độ thường


  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  showSnackBar(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? androidNotification = message.notification?.android;

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Text(notification!.body!),
      action: SnackBarAction(
        textColor: Colors.black,
        label: 'Hmmie!',
        onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationPage(),
              ),
            ),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.deepPurpleAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }

  // showSnackBar(Map<String, dynamic> message) {
  //   final snackBar = SnackBar(
  //     behavior: SnackBarBehavior.fixed,
  //     content: Text(message['notification']['body']),
  //     action: SnackBarAction(
  //       textColor: Colors.black,
  //       label: 'Hmmie!',
  //       onPressed: () =>
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               //builder: (context) => NotificationPage(),
  //             ),
  //           ),
  //     ),
  //     duration: Duration(seconds: 3),
  //     backgroundColor: Colors.deepPurpleAccent,
  //   );
  //   _scaffoldkey.currentState.Scaffold(snackBar);
  // }

  _saveDeviceToken(String uid) async {
    String? fcmToken = await _fcm.getToken();
    DatabaseServices(uid: uid).uploadToken(fcmToken!);
  }

  @override
  void initState() {
    super.initState();
    //TODO: Add Day Night Switch
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   showSnackBar(message);
    //   print('onMessage: $message');
    // });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      showSnackBar(message);
      print('onMessage: $message');
    });

    // _fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     showSnackBar(message);
    //     print('onMessage: $message');
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print('onResume: $message');
    //     //Navigator.push(
    //         //context, MaterialPageRoute(builder: (context) => ChatScreen()));
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print('onLaunch: $message');
    //   },
    // );
    _fcm.requestPermission(
      sound: true,
      badge: true,
      alert: true,
    );

    // _fcm.requestNotificationPermissions(
    //     const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  //_currentIndex đại diện cho tab ở chế độ thường, _anonymousCurrentIndex cho tab ở chế độ ẩn danh
  @override
  Widget build(BuildContext context) {
    user = Provider.of<CurrentUser?>(context);
    _saveDeviceToken(user!.uid);
    final tabs = [
      const  Feed(),
      const ChatScreen(),
      const NotificationPage(),
      const MyProfile(),
      const SimpleSearch(),
    ];

    //Các tab ở chế độ ẩn danh
    final anonymousTabs = [
      //Forum(),
      //AnonymousChatScreen(),
      //NotificationPage(),
      //Myanonprofile(),
    ];
    //ScreenUtil.setScreenOrientation('portrait');
    //this StreamProvider provides the list of user for WiggleList();
    return
      anonymous
          ? Scaffold(
        key: _scaffoldKey,
        body: anonymousTabs[_currentIndex],
        //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: FloatingActionButton(
          splashColor: Colors.transparent,
          child: const Icon(Icons.portrait),
          onPressed: () {
            DatabaseServices(uid: user!.uid).updateAnon(false);
            setState(() {
              anonymous = false;
            });
          },
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF373737),
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: SizedBox(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      // minWidth: 40,
                      onPressed: () {
                        setState(() {
                          _currentIndex = 0;
                        });
                      },
                      child: Icon(
                        Icons.menu,
                        color: _currentIndex == 0
                            ? Colors.deepPurpleAccent
                            : Colors.white,
                      ),
                    ),
                    MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          _currentIndex = 0;
                        });
                      },
                      child: Icon(
                        Icons.chat,
                        color: _currentIndex == 0
                            ? Colors.deepPurpleAccent
                            : Colors.white,
                      ),
                    )
                  ],
                ),
                // Right Tab bar icons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                      child: Icon(
                        Icons.new_releases,
                        color: _currentIndex == 0
                            ? Colors.deepPurpleAccent
                            : Colors.white,
                      ),
                    ),
                    MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      // minWidth: 40,
                      onPressed: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                      },
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/ghosty2.png',
                            fit: BoxFit.fill,
                            color: _currentIndex == 0
                                ? Colors.deepPurpleAccent
                                : Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
          :
      Scaffold(
        key: _scaffoldKey,
        body: tabs[_currentIndex],
        floatingActionButton: FloatingActionButton(
          splashColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: Image.asset('assets/images/ghosty2.png',
                fit: BoxFit.fill, color: kPrimaryColor),
          ),
          onPressed: () {
            DatabaseServices(uid: user!.uid).updateAnon(true);
            setState(() {
              anonymous = true;
            });
          },
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Colors.white38,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: SizedBox(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      minWidth: 20,
                      onPressed: () => changePage(0),
                      child: Icon(
                        Icons.menu,
                        color: _currentIndex == 0
                            ? kPrimaryColor
                            : Colors.white,
                      ),
                    ),
                    MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      minWidth: 20,
                      onPressed: () => changePage(1),
                      child: Icon(
                        Icons.chat,
                        color: _currentIndex == 1
                            ? kPrimaryColor
                            : Colors.white,
                      ),
                    )
                  ],
                ),
                // Right Tab bar icons
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        minWidth: 20,
                        onPressed: () => changePage(2),
                        child: Icon(
                          Icons.new_releases,
                          color: _currentIndex == 2
                              ? kPrimaryColor
                              : Colors.white,
                        ),
                      ),
                      MaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        minWidth: 20,
                        onPressed: () => changePage(3),
                        child: Icon(
                          Icons.portrait,
                          color: _currentIndex == 3
                              ? kPrimaryColor
                              : Colors.white,
                        ),
                      ),
                      MaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        minWidth: 20,
                        onPressed: () => changePage(4),
                        child: Icon(
                          Icons.search,
                          color: _currentIndex == 4
                              ? kPrimaryColor
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }
}
