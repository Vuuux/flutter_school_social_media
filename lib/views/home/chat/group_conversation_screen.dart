import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/chat_room.dart';
import 'package:luanvanflutter/models/conversation_item.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/components/send_message_widget.dart';
import 'package:luanvanflutter/views/games/compatibility/compatibility_start.dart';
import 'package:luanvanflutter/views/games/trivia/answerscreen.dart';
import 'package:luanvanflutter/views/home/chat/chat_screen.dart';
import 'package:luanvanflutter/views/home/chat/components/message_tiles.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:luanvanflutter/views/home/search/search_screen.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import 'components/chat_screen_tiles.dart';

class GroupConversationScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  final String userId;

  const GroupConversationScreen(
      {Key? key, required this.chatRoom, required this.userId})
      : super(key: key);

  @override
  _GroupConversationScreenState createState() =>
      _GroupConversationScreenState();
}

final f = new DateFormat('h:mm a');

class _GroupConversationScreenState extends State<GroupConversationScreen> {
  String message = '';
  TextEditingController messageTextEditingController = TextEditingController();

  ScrollController scrollController = ScrollController();

  Stream<QuerySnapshot>? chatMessagesStream;

  Widget chatMessageList() {
    return Scrollbar(
      child: StreamBuilder<QuerySnapshot>(
        stream: chatMessagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ConversationItemModel> messageList = snapshot.data!.docs
                .map((doc) => ConversationItemModel.fromDocumentSnapshot(doc))
                .toList();
            if (messageList.length == 0) {
              return const Center(
                child: Text(
                  "Nói gì đó để bắt đầu cuộc trò chuyện nào!",
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                          child: FadeInAnimation(
                              child: MessageTile(
                        ctuer: null,
                        chatRoomId: widget.chatRoom.chatRoomId,
                        messageModel: messageList[index],
                        isSendByMe:
                            messageList[index].senderId == widget.userId,
                      ))));
                });
          }
          return Loading();
        },
      ),
    );
  }

  _sendMessage(UserData userData) {
    message = messageTextEditingController.text;
    if (message.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": message,
        "sendBy": userData.username,
        "senderId": widget.userId,
        "timestamp": Timestamp.now(),
        "type": 'message'
      };
      DatabaseServices(uid: '')
          .addConversationMessages(widget.chatRoom.chatRoomId, messageMap);
      String notifId = Uuid().v4();

      setState(() {
        message = "";
        messageTextEditingController.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId>();
    ScreenUtil.init(
        const BoxConstraints(
          maxWidth: 414,
          maxHeight: 869,
        ),
        designSize: const Size(360, 690),
        orientation: Orientation.portrait);
    chatMessagesStream = DatabaseServices(uid: '')
        .getConversationMessages(widget.chatRoom.chatRoomId);

    return StreamBuilder<UserData?>(
      stream: DatabaseServices(uid: user.uid).userData,
      builder: (context, snapshot) {
        UserData? userData = snapshot.data;
        if (userData != null) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              // backgroundColor: Color.fromRGBO(3, 9, 23, 1),
              appBar: AppBar(
                titleSpacing: 50,
                leading: IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(LineAwesomeIcons.home),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          FadeRoute(page: Wrapper()),
                          ModalRoute.withName('Wrapper'));
                    }),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 23,
                          child: ClipOval(
                            child: SizedBox(
                              width: 180,
                              height: 180,
                              child: widget.chatRoom.groupAvatar.isNotEmpty
                                  ? Image.network(
                                      widget.chatRoom.groupAvatar,
                                      fit: BoxFit.fill,
                                    )
                                  : Image.asset('assets/images/profile1.png',
                                      fit: BoxFit.fill),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(
                        widget.chatRoom.groupName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    const Icon(Icons.person),
                    Text(widget.chatRoom.users.length.toString())
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Get.to(() => SearchScreen(
                          userId: widget.userId,
                          isFromChatScreen: true,
                          isMultipleSelect: false,
                          isAddExtraUser: true,
                          chatRoomId: widget.chatRoom.chatRoomId,
                          memberIdList: widget.chatRoom.users,
                          onMemberCallback: (String id) {
                            setState(() {
                              widget.chatRoom.users.add(id);
                            });
                          }));
                      setState(() {});
                    },
                  ),
                ],
              ),
              body: Column(
                children: <Widget>[
                  Expanded(child: chatMessageList()),
                  // Divider(height: 2),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.grey)),
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: messageTextEditingController,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration.collapsed(
                                  hintText: "Send a message...",
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _sendMessage(userData);
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Image.asset('assets/images/send.png'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }
}
