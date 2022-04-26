import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_tree/comment_tree.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/comment.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/home/feed/comment_item.dart';
import 'package:luanvanflutter/views/home/feed/components/comment_tree.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:luanvanflutter/views/home/profile/profile.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:provider/src/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShowComments extends StatefulWidget {
  final BuildContext context;
  final String postId;
  final String ownerId;
  final String mediaUrl;
  TextEditingController commentController = TextEditingController();
  String replyTo = '';
  String tag = '';
  UserData? currentUser;

  ShowComments(
      {Key? key,
      required this.context,
      required this.postId,
      required this.ownerId,
      required this.mediaUrl})
      : super(key: key);

  @override
  _ShowCommentsState createState() => _ShowCommentsState();
}

class _ShowCommentsState extends State<ShowComments> {
  @override
  void initState() {
    super.initState();
    if (mounted) {
      widget.commentController.addListener(() {
        if (widget.commentController.text.isEmpty ||
            !widget.commentController.text.startsWith('@')) {
          widget.replyTo = '';
          widget.tag = '';
        }
      });
    }
  }

  Future getCurrentUserData(String uid) async {
    return await DatabaseServices(uid: uid).getUserByUserId();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("B Ì N H  L U Ậ N",
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
        leading: IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            icon: const Icon(LineAwesomeIcons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
            }),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: buildCommentTree(user!.uid, widget.postId)),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: widget.commentController,
              decoration: const InputDecoration(labelText: "Nhập bình luận..."),
            ),
            trailing: OutlineButton(
              onPressed: () => handlePostComment(user.uid),
              borderSide: BorderSide.none,
              child: const Text("GỬI"),
            ),
          )
        ],
      ),
    );
  }

  buildCommentTree(String uid, String postId) {
    return StreamBuilder<QuerySnapshot>(
        stream: Stream.fromFuture(
            DatabaseServices(uid: "").getComments(widget.postId)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    CommentModel comment;
                    comment =
                        CommentModel.fromDocument(snapshot.data!.docs[index]);
                    return StreamBuilder<QuerySnapshot>(
                        stream: Stream.fromFuture(DatabaseServices(uid: uid)
                            .getReplyComments(postId, comment.commentId)),
                        builder: (context, snapshot2) {
                          List<CommentModel> cmtList = [];
                          if (snapshot2.hasData) {
                            for (var doc in snapshot2.data!.docs) {
                              CommentModel cmt = CommentModel.fromDocument(doc);
                              cmtList.add(cmt);
                            }
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: CommentTree(
                              postId: postId,
                              comment: comment,
                              cmtList: cmtList,
                              onClickReply: (data, replyTo, tag) {
                                widget.commentController.text =
                                    '@' + data.username + ' ';
                                widget.replyTo = replyTo;
                                widget.tag = tag;
                              },
                            ),
                          );
                        });
                  });
            } else {
              return Loading();
            }
          } else {
            return Loading();
          }
        });
  }

  Future<String> getReplyName(String tagId) async {
    return DatabaseServices(uid: tagId).getUserByUserId().then((value) {
      UserData userData = UserData.fromDocumentSnapshot(value);
      return userData.username;
    }) as String;
  }

  handlePostComment(String uid) async {
    await getCurrentUserData(uid).then((value) {
      setState(() {
        widget.currentUser = UserData.fromDocumentSnapshot(value);
      });
    });

    DocumentSnapshot snapshot = await DatabaseServices(uid: uid)
        .getUserByUserId()
        .then((value) => value);
    UserData currentUser = UserData.fromDocumentSnapshot(snapshot);
    var uuid = Uuid();
    String comment = '';
    if (widget.commentController.text.startsWith('@')) {
      comment = widget.commentController.text
          .substring(widget.commentController.text.indexOf(' ') + 1);
    } else {
      comment = widget.commentController.text;
    }

    DatabaseServices(uid: uid).postComment(
      widget.postId,
      currentUser.id,
      uuid.v4(),
      currentUser.username,
      comment,
      Timestamp.now(),
      currentUser.avatar,
      widget.replyTo,
      widget.tag,
    );
    bool isNotPostOwner = widget.ownerId != uid;
    if (isNotPostOwner) {
      DatabaseServices(uid: uid).addCommentNotifications(
          postOwnerId: widget.ownerId,
          comment: comment,
          postId: widget.postId,
          uid: uid,
          username: currentUser.username,
          avatar: currentUser.avatar,
          url: widget.mediaUrl,
          timestamp: Timestamp.now());
    }
    widget.tag = '';
    widget.replyTo = '';
    widget.commentController.clear();
    widget.commentController.clearComposing();
    FocusScope.of(context).unfocus();
  }
}
