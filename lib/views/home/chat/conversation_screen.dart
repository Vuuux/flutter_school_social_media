import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/conversation_item.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/components/send_message_widget.dart';
import 'package:luanvanflutter/views/games/compatibility/compatibility_start.dart';
import 'package:luanvanflutter/views/games/trivia/answerscreen.dart';
import 'package:luanvanflutter/views/home/chat/chat_screen.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
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

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final UserData ctuer;
  final String userId;

  const ConversationScreen(
      {Key? key,
      required this.chatRoomId,
      required this.ctuer,
      required this.userId})
      : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

final f = new DateFormat('h:mm a');

class _ConversationScreenState extends State<ConversationScreen> {
  String message = '';
  TextEditingController messageTextEditingController = TextEditingController();

  ScrollController scrollController = ScrollController();

  Stream<QuerySnapshot>? chatMessagesStream;

  Widget chatMessageList() {
    return StreamBuilder<QuerySnapshot>(
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
              itemCount: messageList.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                        child: FadeInAnimation(
                            child: MessageTile(
                      ctuer: widget.ctuer,
                      chatRoomId: widget.chatRoomId,
                      messageModel: messageList[index],
                      isSendByMe: messageList[index].senderId == widget.userId,
                    ))));
              });
        }
        return Loading();
      },
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
          .addConversationMessages(widget.chatRoomId, messageMap);
      String notifId = Uuid().v4();
      DatabaseServices(uid: '')
          .addNotifiCation(widget.ctuer.id, widget.userId, notifId, {
        'notifId': notifId,
        'userId': userData.id,
        'type': 'message',
        'messageData': message,
        'timestamp': Timestamp.now(),
        'avatar': userData.avatar,
        'username': userData.username,
        'status': null,
        'seenStatus': false,
        'isAnon': false
      });

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
    chatMessagesStream =
        DatabaseServices(uid: '').getConversationMessages(widget.chatRoomId);

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
                              child: widget.ctuer.avatar.isNotEmpty
                                  ? Image.network(
                                      widget.ctuer.avatar,
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
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Text(widget.ctuer.username.split(" ").last,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 20)),
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            FadeRoute(
                              page: OthersProfile(
                                ctuerId: widget.ctuer.id,
                              ),
                            ),
                            ModalRoute.withName('OthersProfile'));
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(Icons.gamepad),
                    onPressed: () async {
                      await DatabaseServices(uid: '')
                          .getQAGameRoomId(widget.ctuer.id, userData.id)
                          .then((QuerySnapshot<Map<String, dynamic>> value) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CompatibilityStart(
                                  ctuer: widget.ctuer,
                                  userData: userData,
                                  gameRoomId: value.docs.isNotEmpty
                                      ? value.docs[0].id
                                      : "",
                                )));
                      });
                    },
                  ),
                ],
              ),
              body: Stack(
                children: <Widget>[
                  chatMessageList(),
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

class MessageTile extends StatelessWidget {
  final UserData ctuer;
  final bool isSendByMe;
  final String chatRoomId;
  final ConversationItemModel messageModel;
  const MessageTile(
      {required this.chatRoomId,
      required this.isSendByMe,
      required this.ctuer,
      required this.messageModel,
      Key? key})
      : super(key: key);

  //delete msg
  //edit msg
  _onTap() {
    if (messageModel.type == KEY_NOTIFICATION_QUESTION &&
        messageModel.message.isNotEmpty &
            messageModel.triviaRoomId!.isNotEmpty &&
        !isSendByMe) {
      Get.to(() => AnswerScreen(
            question: messageModel.message,
            triviaRoomID: messageModel.triviaRoomId!,
            ctuer: ctuer,
            userData: UserDataService().getUserData()!,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isSendByMe ? 0 : 24,
          right: isSendByMe ? 24 : 0),
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      child: FocusedMenuHolder(
        menuWidth: MediaQuery.of(context).size.width * 0.35,
        onPressed: () => FocusScope.of(context).unfocus(),
        menuBoxDecoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
          bottomLeft: Radius.circular(23),
          bottomRight: Radius.circular(23),
        )),
        menuItems: <FocusedMenuItem>[
          FocusedMenuItem(
              title: const Text(
                "Xóa",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              trailingIcon: Icon(Icons.delete),
              onPressed: () {
                DatabaseServices(uid: '')
                    .chatReference
                    .doc(chatRoomId)
                    .collection('conversation')
                    .where("message", isEqualTo: messageModel.message)
                    .get()
                    .then((doc) {
                  if (doc.docs[0].exists) {
                    doc.docs[0].reference.delete();
                  }
                });
              },
              backgroundColor: Colors.redAccent)
        ],
        child: Container(
          margin: isSendByMe
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(-1, 4),
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 1)
            ],
            color: (messageModel.type == 'message')
                ? (!isSendByMe
                    ? Get.isDarkMode
                        ? kPrimaryDarkColor
                        : Colors.red
                    : Colors.white)
                : kStudyColor,
            borderRadius: isSendByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23),
                  ),
          ),
          child: Column(
            crossAxisAlignment:
                isSendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                f.format(messageModel.timestamp.toDate()).toString(),
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular'),
              ),
              Text(
                messageModel.message,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: messageModel.type == 'message'
                        ? FontWeight.w300
                        : FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
