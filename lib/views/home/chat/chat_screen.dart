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

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

var f = DateFormat('h:mm a');


class _ChatScreenState extends State<ChatScreen> {
  late Stream<QuerySnapshot> chatsScreenStream;
  late UserData currentCtuer;
  late String roomId;
  late String userId;
  late String ctuerId;

  CurrentUser? user;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    user = context.watch<CurrentUser?>()!;
    chatsScreenStream = DatabaseServices(uid: '').getChatRooms(user!.uid);
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
              roomId = snapshot.data!.docs[index].get("chatRoomId");
              List<dynamic> userIdList = snapshot.data!.docs[index].get('users');
              userIdList.forEach((userId) {
                if(userId.toString() != user.uid) {
                  ctuerId = userId;
                }
              });
              return FutureBuilder<DocumentSnapshot>(
                future: DatabaseServices(uid: ctuerId).getUserByUserId(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Loading();
                  }
                  if(snapshot.hasData){
                    return ChatScreenTile(
                      chatRoomId: roomId,
                      userId: user.uid,
                      ctuer: UserData.fromDocumentSnapshot(snapshot.data),
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
    user = context.watch<CurrentUser?>();
    getUserInfo();
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
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchScreen(userId: user!.uid)));
            },
          ),
        ],
      ),
      body: chatRoomList(user!),
    );
  }
}
