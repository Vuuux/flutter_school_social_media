import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/home/chat/components/chat_screen_tiles.dart';
import 'package:luanvanflutter/views/home/search/search_screen.dart';
import 'package:provider/provider.dart';

class AnonChatScreen extends StatefulWidget {
  const AnonChatScreen({Key? key}) : super(key: key);

  @override
  _AnonChatScreenState createState() => _AnonChatScreenState();
}

var f = DateFormat('h:mm a');


class _AnonChatScreenState extends State<AnonChatScreen> {
  Stream<QuerySnapshot>? chatsScreenStream;
  late UserData currentCtuer;
  late String userId;
  late String ctuerId;

  CurrentUser? user;

  @override
  void initState() {
    super.initState();
  }

  getUserInfo(CurrentUser user) async {
    chatsScreenStream = DatabaseServices(uid: '').getChatRooms(user.uid);
  }

  Widget chatRoomList(CurrentUser user) {
    return StreamBuilder<QuerySnapshot>(
        stream: chatsScreenStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              ctuerId = '';

              List<dynamic> userIdList = snapshot.data!.docs[index].get('users');
              userIdList.forEach((userId) {
                if(userId.toString() != user.uid) {
                  ctuerId = userId;
                }
              });
              return FutureBuilder<DocumentSnapshot>(
                future: DatabaseServices(uid: ctuerId).getUserByUserId(),
                builder: (context, childSnapshot) {
                  var roomId = snapshot.data!.docs[index].get("chatRoomId");
                  if(childSnapshot.connectionState == ConnectionState.waiting){
                    return Loading();
                  }
                  if(childSnapshot.hasData){
                    return ChatScreenTile(
                      chatRoomId: roomId,
                      userId: user.uid,
                      ctuer: UserData.fromDocumentSnapshot(childSnapshot.data),
                    );
                  }
                  return const Center(
                      child: Text(
                      'Nói chuyện với bạn bằng cách bấm + icon',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                  ));
                }
              );
            },
          )
              : const Center(child: Text("NOTHING HERE!"));
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUser?>();
    getUserInfo(user!);
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            )),
        centerTitle: true,
        elevation: 0,
        title: const Text("T R Ò   C H U Y Ệ N",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
        actions: <Widget>[
          IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchScreen(userId: user.uid)));
            },
          ),
        ],
      ),
      body: chatsScreenStream != null ? chatRoomList(user) : Center(child: Loading()),
    );
  }
}
