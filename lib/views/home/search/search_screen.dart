import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/authenticate/helper.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class SearchScreen extends StatefulWidget {
  List<Ctuer> ctuerList = [];

  SearchScreen({required this.ctuerList});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchTextEditingController =
  TextEditingController();
  late QuerySnapshot searchSnapshot;
  bool isLoading = false;
  bool haveUserSearched = false;
  late Stream chatsScreenStream;

  initiateSearch() async {
    if (searchTextEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseServices(uid: '')
          .getUserByUsername(searchTextEditingController.text)
          .then((val) {
        searchSnapshot = val;
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
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

  createChatRoomAndStartConversation(UserData userData, Ctuer ctuer) {
    String chatRoomID = getChatRoomID(userData.email, ctuer.nickname);
    List<String> users = [userData.email, ctuer.email];

    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomId": chatRoomID
    };
    DatabaseServices(uid: '').uploadBondData(
        userData: userData,
        myAnon: true,
        ctuer: ctuer,
        friendAnon: false,
        chatRoomID: chatRoomID);
    DatabaseServices(uid: '').createAnonChatRoom(chatRoomID, chatRoomMap);
    //TODO: AnonymousConversation
    // Navigator.of(context).pushAndRemoveUntil(
    //   FadeRoute(
    //     page: AnonymousConversation(
    //       friendAnon: false,
    //       ctuerList: widget.ctuerList,
    //       ctuer: ctuer,
    //       chatRoomId: chatRoomID,
    //       userData: userData,
    //     ),
    //   ),
    //   ModalRoute.withName('AnonymousConversation'),
    // );
  }

  Widget searchTile({required String myEmail, required Ctuer ctuer, required UserData userData}) {
    if (ctuer.email != userData.email) {
      return RaisedButton(
        onPressed: () {
          // Navigator.of(context).pushAndRemoveUntil(
          //   FadeRoute(
          //     page: OthersProfile(
          //       ctuerList: widget.ctuerList,
          //       ctuer: ctuer,
          //       userData: userData,
          //     ),
          //   ),
          //   ModalRoute.withName('OthersProfile'),
          // );
        },
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: Color(0xFF555555),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: ClipOval(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Image.network(
                        ctuer.avatar,
                        fit: BoxFit.fill,
                      ) ??
                          Image.asset('assets/images/profile1.png',
                              fit: BoxFit.fill),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ctuer.username,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                createChatRoomAndStartConversation(userData, ctuer);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                child: const Text('Text'),
              ),
            ),
          ],
        ),
      );
    }
    else {
      return const SizedBox.shrink();
    }
  }

  Widget searchList(List<Ctuer> ctuerList) {
    String name;
    Ctuer? currentCtuer;

    final user = Provider.of<CurrentUser>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user.uid).userData,
        builder: (context, snapshot) {
          UserData? userData = snapshot.data;

          if (userData != null) {
            return searchSnapshot != null
                ? ListView.builder(
                itemCount: searchSnapshot.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  name = searchSnapshot.docs[index].get('name');
                  for (int i = 0; i < ctuerList.length; i++) {
                    if (ctuerList[i].username == name) {
                      currentCtuer = ctuerList[i];
                    }
                  }
                  return searchTile(
                      myEmail: userData.email,
                      ctuer: currentCtuer!,
                      userData: userData);
                })
                : Container();
          } else {
            return Loading();
          }
        });
  }

  getUserInfo() async {
    Constants.myEmail = (await Helper.getUserEmailSharedPreference())!;
    Constants.myName = (await Helper.getUserNameSharedPreference())!;
    // print(Constants.myName);
    DatabaseServices(uid: '').getAnonymousChatRooms(Constants.myEmail).then((val) {
      setState(() {
        chatsScreenStream = val;
      });
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(LineAwesomeIcons.home),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
              }),
          centerTitle: true,
          title: const Text("T Ì M   B Ạ N",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
        ),
        body: isLoading
            ? Center(child: const CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: const Color(0xFF373737),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: searchTextEditingController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "search username...",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        initiateSearch();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Image.asset(
                            "assets/images/search_white.png"),
                      ),
                    ),
                  ],
                ),
              ),
              searchList(widget.ctuerList),
            ],
          ),
        ),
      ),
    );
  }
}
