import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:eventual/eventual-notifier.dart';
import 'package:eventual/eventual-single-builder.dart';
import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/post_controller.dart';
import 'package:luanvanflutter/models/notification.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/helper.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/home/chat/conversation_screen.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'package:uuid/uuid.dart';

import '../../controller/controller.dart';
import '../components/app_bar/standard_app_bar.dart';
import '../games/compatibility/compatibility_start.dart';
import 'feed/post_detail.dart';

//Class quản lý thông báo
class NotificationPage extends StatefulWidget {
  final String uid;

  const NotificationPage({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<QuerySnapshot>? notificationFuture;
  late UserData? userData;
  @override
  void initState() {
    super.initState();
    notificationFuture =
        DatabaseServices(uid: widget.uid).getAllNotifications();
    userData = UserDataService().getUserData();
  }

  Future _onRefresh() async {
    QuerySnapshot snapshot =
        await DatabaseServices(uid: widget.uid).getAllNotifications();
    setState(() {
      notificationFuture = Future<QuerySnapshot>.value(snapshot);
    });
  }

  _deleteAllNotification() {
    setState(() {
      DatabaseServices(uid: widget.uid).deleteAllNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseServices databaseService = DatabaseServices(uid: widget.uid);

    return Scaffold(
      appBar: StandardAppBar(
        title: 'T H Ô N G   B Á O',
        trailingIcon: FontAwesomeIcons.trash,
        onTrailingClick: () async {
          _deleteAllNotification();
        },
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<QuerySnapshot>(
            future: notificationFuture,
            builder: (context, dataSnapshot) {
              List<NotificationModel> notificationsItems = [];
              if (dataSnapshot.connectionState != ConnectionState.done) {
                return Loading();
              }
              if (dataSnapshot.hasData) {
                for (var document in dataSnapshot.data!.docs) {
                  notificationsItems
                      .add(NotificationModel.fromDocument(document));
                }

                return notificationsItems.isEmpty
                    ? const Center(
                        child: Text("Không có thông báo"),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _onRefresh(),
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return NotificationsItem(
                              noti: notificationsItems[index],
                              userData: userData!,
                            );
                          },
                          itemCount: notificationsItems.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(
                              height: 1,
                              thickness: 1,
                            );
                          },
                        ),
                      );
              }
              return const Center(
                child: Text("Bạn chưa có thông báo nào"),
              );
            }),
      ),
    );
  }
}

class NotificationsItem extends StatefulWidget {
  final NotificationModel noti;
  late String notificationItemText;
  late Widget mediaPreview;
  final UserData userData;

  NotificationsItem({Key? key, required this.noti, required this.userData})
      : super(key: key);

  DatabaseServices databaseService = DatabaseServices(uid: '');

  configureMediaPreview(context) {
    mediaPreview = noti.mediaUrl!.isNotEmpty
        ? SizedBox(
            width: 25,
            child: CachedNetworkImage(imageUrl: noti.mediaUrl!),
          )
        : SizedBox.shrink();
    if (noti.type == KEY_NOTIFICATION_FOLLOWING) {
      notificationItemText = 'đang theo dõi bạn';
    } else if (noti.type == KEY_NOTIFICATION_LIKE) {
      notificationItemText = 'đã thích bài viết của bạn';
    } else if (noti.type == KEY_NOTIFICATION_COMMENT) {
      notificationItemText = 'đã bình luận bài viết';
    } else if (noti.type == KEY_NOTIFICATION_MESSAGE) {
      notificationItemText = 'đã gửi bạn 1 tin nhắn';
    } else if (noti.type == KEY_NOTIFICATION_REQUEST &&
        noti.status != FollowStatus.ACCEPTED) {
      notificationItemText = 'yêu cầu theo dõi bạn';
    } else if (noti.type == KEY_NOTIFICATION_REQUEST &&
        noti.status == FollowStatus.ACCEPTED) {
      notificationItemText = 'đã chấp nhận yêu cầu theo dõi của bạn';
    } else if (noti.type == KEY_NOTIFICATION_COMP) {
      notificationItemText = 'muốn chơi trò QnA với bạn';
    } else if (noti.type == KEY_NOTIFICATION_QUESTION) {
      notificationItemText = 'đã đặt 1 câu hỏi cho bạn';
    } else if (noti.type == KEY_NOTIFICATION_ANSWER) {
      notificationItemText = 'đã trả lời câu hỏi của bạn';
    } else if (noti.type == KEY_NOTIFICATION_QA_GAME) {
      notificationItemText = 'đã mời bạn chơi hỏi xoáy đáp xoay';
    } else {
      notificationItemText = 'Lỗi, Unknown type = ' + noti.type;
    }
  }

  @override
  _NotificationsItemState createState() => _NotificationsItemState();
}

class _NotificationsItemState extends State<NotificationsItem> {
  EventualNotifier<bool> didAcceptRequest = EventualNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  checkFollowRequestStatus(String uid) {
    if (widget.noti.type == 'request' &&
        widget.noti.status == FollowStatus.ACCEPT) {
      didAcceptRequest.value = true;
    }
  }

  checkAcceptedOrDeclinedfortictactoe(String uid) {
    if (widget.noti.type == 'tictactoe') {
      // widget.databaseService.feedRef
      //     .doc(widget.ownerID)
      //     .collection('feed')
      //     .where('notifID', isEqualTo: widget.notifID)
      //     .where('type', isEqualTo: 'tictactoe')
      //     .get()
      //     .then((value) {
      //   if (value.docs[0].data()['status'] == 'accepted') {
      //     if (mounted) {
      //       setState(() {
      //         accepted = true;
      //       });
      //     }
      //   } else if (value.docs[0].data()['status'] == 'declined') {
      //     if (mounted) {
      //       setState(() {
      //         declined = true;
      //       });
      //     }
      //   }
      // });
    }
  }

  _handleAcceptRequest(CurrentUserId user) async {
    widget.databaseService.acceptRequest(user.uid, widget.noti.notifId);
    String notifId = Uuid().v4();
    widget.databaseService
        .addNotifiCation(widget.noti.userId, user.uid, notifId, {
      'notifId': notifId,
      'type': 'request',
      'timestamp': DateTime.now(),
      'avatar': widget.userData.avatar,
      'username': widget.userData.username,
      'status': 'accepted',
      'seenStatus': false,
      'userId': widget.userData.id,
      'isAnon': false
    });

    widget.databaseService.addFollowing(user.uid, widget.noti.userId, {
      'id': widget.userData.id,
      'username': widget.userData.username,
      'avatar': widget.userData.avatar,
    });

    widget.databaseService.addFollower(user.uid, widget.noti.userId, {
      'id': widget.noti.userId,
      'username': widget.noti.username,
      'avatar': widget.noti.avatar
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUserId?>(context);
    checkFollowRequestStatus(user!.uid);
    checkAcceptedOrDeclinedfortictactoe(user.uid);
    widget.configureMediaPreview(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: Stream.fromFuture(
            DatabaseServices(uid: user.uid).getCtuerById(widget.noti.userId)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData ctuer = UserData.fromDocumentSnapshot(snapshot.data!);
            return GestureDetector(
              onTap: () async {
                DatabaseServices(uid: user.uid).updateNotification(
                    user.uid, widget.noti.notifId, {"seenStatus": true});
                switch (widget.noti.type) {
                  case KEY_NOTIFICATION_LIKE:
                    Get.to(() => PostDetail(
                          postId: widget.noti.postId!,
                          ownerId: user.uid,
                        ));
                    break;
                  case KEY_NOTIFICATION_MESSAGE:
                    Get.to(() => ConversationScreen(
                        chatRoomId: widget.noti.chatRoomId!,
                        ctuer: ctuer,
                        userId: user.uid));
                    break;
                  case KEY_NOTIFICATION_REQUEST:
                    Get.to(() => OthersProfile(ctuerId: widget.noti.userId));
                    break;
                  case KEY_NOTIFICATION_COMP:
                    Get.to(() => CompatibilityStart(
                          ctuer: ctuer,
                          userData: UserDataService().getUserData()!,
                        ));
                    break;
                  case KEY_NOTIFICATION_QUESTION:
                    break;
                  case KEY_NOTIFICATION_ANSWER:
                    break;
                  case KEY_NOTIFICATION_QA_GAME:
                    break;
                  default:
                    break;
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color:
                      !widget.noti.seenStatus ? Colors.white : Colors.black12,
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 7,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 10.0, color: Colors.black),
                              children: [
                                TextSpan(
                                    text: widget.noti.username,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black)),
                                TextSpan(
                                    text: " " + widget.notificationItemText,
                                    style: (const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: ClipOval(
                        child: SizedBox(
                          width: 35,
                          height: 35,
                          child: widget.noti.avatar != ""
                              ? Image.network(
                                  widget.noti.avatar,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset('assets/images/profile1.png',
                                  fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    subtitle: Text(
                        tAgo.format(widget.noti.timestamp.toDate(),
                            locale: 'vi'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                    trailing: widget.noti.type == KEY_NOTIFICATION_REQUEST &&
                            (widget.noti.status != FollowStatus.ACCEPTED)
                        ? EventualSingleBuilder(
                            notifier: didAcceptRequest,
                            builder: (context, notifier, _) {
                              return notifier.value
                                  ? Text(
                                      "ĐÃ ĐỒNG Ý",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Wrap(
                                      spacing: 2.0,
                                      runSpacing: 2.0,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              _handleAcceptRequest(user),
                                          child: Text("ĐỒNG Ý"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            widget.databaseService
                                                .declineRequest(user.uid,
                                                    widget.noti.userId);
                                          },
                                          child: Text("HỦY"),
                                        ),
                                      ],
                                    );
                            })
                        : widget.mediaPreview,
                  ),
                ),
              ),
            );
          }
          return Container();
        });
  }
}
