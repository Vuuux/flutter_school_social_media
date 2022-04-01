import 'package:eventual/eventual-builder.dart';
import 'package:eventual/eventual-notifier.dart';
import 'package:eventual/eventual-single-builder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/theme_service.dart';
import 'package:luanvanflutter/views/anon_home/anon_notifications_page.dart';
import 'package:luanvanflutter/views/anon_home/feed/forum_feed.dart';
import 'package:luanvanflutter/views/anon_home/profile/anon_profile.dart';
import 'package:luanvanflutter/views/anon_home/search/anon_example_search_screen.dart';
import 'package:luanvanflutter/views/components/bottom_bar/bottom_bar.dart';
import 'package:luanvanflutter/views/components/buttons/bottom_bar_button.dart';
import 'package:luanvanflutter/views/home/profile/profile.dart';
import 'package:luanvanflutter/views/home/schedule/task_manager.dart';
import 'package:luanvanflutter/views/home/search/example_search_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import 'views/home/chat/chat_screen.dart';
import 'views/home/feed/feed.dart';
import 'views/home/notifications_page.dart';

//Trang chủ sau đăng nhập
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  EventualNotifier<bool> anonymous = EventualNotifier(false);
  EventualNotifier<int> _currentAnonymousIndex = EventualNotifier(0);
  EventualNotifier<int> _currentIndex = EventualNotifier(0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late CurrentUser? user;

  //Các tab ở chế độ thường

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  showSnackBar(String message) {
    // RemoteNotification? notification = message.notification;
    // AndroidNotification? androidNotification = message.notification?.android;

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Text(message),
      action: SnackBarAction(
        textColor: Colors.black,
        label: 'Hmmie!',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationPage(uid: user!.uid),
          ),
        ),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.amber,
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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      var messageData = message.data;
      final String recipientId = messageData["recipient"];
      final String? body = message.notification!.body;
      if (recipientId == user!.uid && body!.isNotEmpty) {
        showSnackBar(body);
      }

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
  }

  void changePage(int index) {
    setState(() {
      _currentIndex.value = index;
    });
  }

  //_currentIndex đại diện cho tab ở chế độ thường, _anonymousCurrentIndex cho tab ở chế độ ẩn danh
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    user = Provider.of<CurrentUser?>(context);
    _saveDeviceToken(user!.uid);
    final tabs = [
      const Feed(),
      const TaskManagerPage(),
      const ChatScreen(),
      NotificationPage(
        uid: user!.uid,
      ),
      const MyProfile(),
      SimpleSearch(),
    ];

    //Các tab ở chế độ ẩn danh
    final anonymousTabs = [
      const AnonForumFeed(),
      AnonNotificationPage(
        uid: user!.uid,
      ),
      const AnonProfile(),
      AnonSimpleSearch(),
    ];
    //ScreenUtil.setScreenOrientation('portrait');
    //this StreamProvider provides the list of user for WiggleList();
    return EventualBuilder(
        notifiers: [anonymous, ThemeService.themeNotifier],
        builder: (context, anonNotifier, _) {
          ThemeMode themeMode = anonNotifier[1].value;
          return anonNotifier[0].value
              ? EventualSingleBuilder(
                  notifier: _currentAnonymousIndex,
                  builder: (context, notifier, _) => Scaffold(
                    extendBody: true,
                    key: _scaffoldKey,
                    body: anonymousTabs[notifier.value],
                    bottomNavigationBar:
                        _buildAnonymousBottomBar(size, themeMode),
                  ),
                )
              : EventualSingleBuilder(
                  notifier: _currentIndex,
                  builder: (context, notifier, _) => Scaffold(
                    extendBody: true,
                    key: _scaffoldKey,
                    body: tabs[notifier.value],
                    bottomNavigationBar: _buildBottomBar(size, themeMode),
                  ),
                );
        });
  }

  Widget _buildBottomBar(Size size, ThemeMode themeMode) => BottomAppBar(
        elevation: 10,
        color: Colors.white.withOpacity(0),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Stack(
          children: [
            CustomPaint(
                size: Size(size.width, 70),
                painter: BNBCustomPainter(),
                child: SizedBox(
                  height: 70,
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: BottomBarButton(
                            index: 0,
                            currentIndex: _currentIndex,
                            icon: Icons.menu),
                      ),
                      Flexible(
                        flex: 1,
                        child: BottomBarButton(
                            index: 1,
                            currentIndex: _currentIndex,
                            icon: Icons.edit_calendar),
                      ),
                      Flexible(
                        flex: 1,
                        child: BottomBarButton(
                            currentIndex: _currentIndex,
                            index: 2,
                            icon: Icons.chat),
                      ),
                      Center(
                        child: SizedBox(
                          width: size.width * 0.2,
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: BottomBarButton(
                            currentIndex: _currentIndex,
                            index: 3,
                            icon: Icons.new_releases),
                      ),
                      Flexible(
                        flex: 1,
                        child: BottomBarButton(
                            currentIndex: _currentIndex,
                            index: 4,
                            icon: Icons.portrait),
                      ),
                      Flexible(
                        flex: 1,
                        child: BottomBarButton(
                            index: 5,
                            currentIndex: _currentIndex,
                            icon: Icons.search),
                      ),
                      // Right Tab bar icons
                    ],
                  ),
                )),
            Center(
              heightFactor: 0.6,
              child: FloatingActionButton(
                backgroundColor: themeMode == ThemeMode.dark
                    ? kPrimaryDarkColor
                    : kPrimaryColor,
                splashColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset('assets/images/ghosty2.png',
                      fit: BoxFit.fill,
                      color: themeMode == ThemeMode.dark
                          ? Colors.black
                          : Colors.white),
                ),
                onPressed: () {
                  DatabaseServices(uid: user!.uid).changeAnonymousMode(true);
                  anonymous.value = true;
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildAnonymousBottomBar(Size size, ThemeMode themeValue) =>
      BottomAppBar(
        elevation: 10,
        color: Colors.white.withOpacity(0),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(size.width, 70),
              painter: BNBCustomPainter(),
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    BottomBarButton(
                      index: 0,
                      icon: Icons.menu,
                      currentIndex: _currentAnonymousIndex,
                    ),
                    BottomBarButton(
                        index: 1,
                        currentIndex: _currentAnonymousIndex,
                        icon: Icons.new_releases),
                    // Right Tab bar icons
                    SizedBox(
                      width: size.width * 0.3,
                    ),
                    BottomBarButton(
                        index: 2,
                        currentIndex: _currentAnonymousIndex,
                        icon: Icons.portrait),
                    BottomBarButton(
                        index: 3,
                        currentIndex: _currentAnonymousIndex,
                        icon: Icons.search),
                  ],
                ),
              ),
            ),
            Center(
              heightFactor: 0.6,
              child: FloatingActionButton(
                backgroundColor: themeValue == ThemeMode.dark
                    ? kPrimaryDarkColor
                    : kPrimaryColor,
                splashColor: Colors.transparent,
                child: Icon(Icons.portrait,
                    color: themeValue == ThemeMode.dark
                        ? Colors.black
                        : Colors.white),
                onPressed: () {
                  DatabaseServices(uid: user!.uid).updateAnon(false);
                  setState(() {
                    anonymous.value = false;
                  });
                },
              ),
            )
          ],
        ),
      );
}
