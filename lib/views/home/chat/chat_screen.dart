import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/chat_room.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/home/chat/components/chat_screen_tiles.dart';
import 'package:luanvanflutter/views/home/search/search_screen.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

var f = DateFormat('h:mm a');

class _ChatScreenState extends State<ChatScreen> {
  Stream<QuerySnapshot>? chatsScreenStream;
  late UserData currentUser;
  late String userId;
  late String ctuerId;

  CurrentUserId? user;

  @override
  void initState() {
    super.initState();
    currentUser = UserDataService().getUserData()!;
    getUserInfo();
  }

  getUserInfo() async {
    chatsScreenStream =
        DatabaseServices(uid: currentUser.id).getChatRooms(currentUser.id);
  }

  Widget chatRoomList(String id) {
    return StreamBuilder<QuerySnapshot>(
        stream: chatsScreenStream,
        builder: (context, snapshot) {
          List<ChatRoom> chatRoomList = [];
          if (snapshot.hasData) {
            chatRoomList = snapshot.data!.docs
                .map((doc) => ChatRoom.fromDocumentSnapshot(doc))
                .toList();
            return chatRoomList.isNotEmpty
                ? ListView.builder(
                    itemCount: chatRoomList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      ctuerId = '';

                      List<dynamic> userIdList =
                          snapshot.data!.docs[index].get('users');
                      userIdList.forEach((userId) {
                        if (userId.toString() != id) {
                          ctuerId = userId;
                        }
                      });
                      return FutureBuilder<DocumentSnapshot>(
                          future:
                              DatabaseServices(uid: ctuerId).getUserByUserId(),
                          builder: (context, childSnapshot) {
                            if (childSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            }
                            if (childSnapshot.hasData) {
                              return ChatScreenTile(
                                chatRoom: chatRoomList[index],
                                userId: id,
                                ctuer: UserData.fromDocumentSnapshot(
                                    childSnapshot.data!),
                              );
                            }
                            return const Center(
                                child: Text(
                              'Nói chuyện với bạn bằng cách bấm + icon',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w300),
                            ));
                          });
                    },
                  )
                : const Center(child: Text("Bạn không có cuộc hội thoại nào"));
          }
          return Loading();
        });
  }

  _showDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Tạo phòng chat mới"),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text(
                  "Cá nhân",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Get.to(() => SearchScreen(
                        userId: currentUser.id,
                        isFromChatScreen: true,
                        isMultipleSelect: false,
                      ));
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  "Hội nhóm",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () async {
                  await Get.to(() => SearchScreen(
                        userId: currentUser.id,
                        isFromChatScreen: true,
                        isMultipleSelect: true,
                      ));
                  Get.back();
                },
                //onPressed: () => _pickImageFromGallery(userData),
              ),
              SimpleDialogOption(
                child: const Text(
                  "Đóng",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Wrapper(),
          ),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
          centerTitle: true,
          elevation: 0,
          title: const Text(
            "T R Ò   C H U Y Ệ N",
          ),
          actions: <Widget>[
            IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: () {
                _showDialog();
              },
            ),
          ],
        ),
        body: chatsScreenStream != null
            ? chatRoomList(currentUser.id)
            : Center(child: Loading()),
      ),
    );
  }
}
