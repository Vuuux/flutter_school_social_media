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

  ShowComments({Key? key,
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
    if(mounted){
      widget.commentController.addListener(() {
        if(widget.commentController.text.isEmpty || !widget.commentController.text.startsWith('@')){
          widget.replyTo = '';
          widget.tag = '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUser?>();
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
              onPressed: () => handlePostComment(user),
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
                              child:
                              CommentTreeWidget<CommentModel, CommentModel>(
                                comment,
                                cmtList,
                                treeThemeData: TreeThemeData(
                                    lineColor: cmtList.isEmpty
                                        ? Colors.transparent
                                        : kPrimaryColor,
                                    lineWidth: 2),
                                avatarRoot: (context, data) =>
                                    PreferredSize(
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey,
                                        backgroundImage:
                                        CachedNetworkImageProvider(data.avatar),
                                      ),
                                      preferredSize: const Size.fromRadius(28),
                                    ),
                                avatarChild: (context, data) =>
                                    PreferredSize(
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey,
                                        backgroundImage:
                                        CachedNetworkImageProvider(data.avatar),
                                      ),
                                      preferredSize: const Size.fromRadius(18),
                                    ),
                                contentChild: (context, data) {
                                  return FutureBuilder<DocumentSnapshot>(
                                      future: DatabaseServices(uid: data.tagId)
                                          .getUserByUserId(),
                                      builder: (context, nameSnapshot) {
                                        UserData? userDetail;
                                        bool isLiked = false;
                                        isLiked =
                                            data.likes[uid] == true;
                                        if (nameSnapshot.hasData) {
                                          userDetail =
                                              UserData.fromDocumentSnapshot(
                                                  nameSnapshot.data);
                                        }
                                        return Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                  horizontal: 8),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      12)),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.username,
                                                    style: Theme
                                                        .of(context)
                                                        .textTheme
                                                        .caption
                                                        ?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        color:
                                                        Colors.black),
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  _buildCommentLine(context,
                                                      data, userDetail, uid)
                                                ],
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                const EdgeInsets.only(top: 4),
                                                child: _buildLikeReply(comment.commentId, postId, uid, data, isLiked)
                                            )
                                          ],
                                        );
                                      });
                                },
                                contentRoot: (context, data) {
                                  return FutureBuilder<DocumentSnapshot>(
                                      future: DatabaseServices(uid: data.tagId)
                                          .getUserByUserId(),
                                      builder: (context, rootSnapshot) {
                                        UserData? userDetail;
                                        bool isRootLiked = false;
                                        isRootLiked =
                                            data.likes[uid] == true;
                                        if (rootSnapshot.hasData) {
                                          userDetail =
                                              UserData.fromDocumentSnapshot(
                                                  rootSnapshot.data);
                                        }
                                        return Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                  horizontal: 8),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      12)),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.username,
                                                    style: Theme
                                                        .of(context)
                                                        .textTheme
                                                        .caption
                                                        ?.copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        color:
                                                        Colors.black),
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  _buildCommentLine(context,
                                                      data, userDetail, uid)
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(top: 4),
                                              child: _buildLikeReply(comment.commentId, postId, uid, data, isRootLiked)
                                            )
                                          ],
                                        );
                                      });
                                },
                              ));
                        });
                  });
            } else {
              return const Text('Chưa có bình luận nào :<');
            }
          } else {
            return Container();
          }
        });
  }

  _buildCommentLine(BuildContext context, CommentModel data,
      UserData? userDetail, String uid) {
    return RichText(
      text: TextSpan(children: <TextSpan>[
        TextSpan(
            text: userDetail != null ? userDetail.username + ' ' : '',
            style: Theme
                .of(context)
                .textTheme
                .caption
                ?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800]),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                    userDetail!.id == uid
                        ? const MyProfile()
                        : OthersProfile(ctuer: userDetail)));
              }),
        TextSpan(
          text: data.comment,
          style: Theme
              .of(context)
              .textTheme
              .caption
              ?.copyWith(
              fontSize: 16, fontWeight: FontWeight.w300, color: Colors.black),
        ),
      ]),
    );
  }

  buildLikeCount(CommentModel data) {
    return data.getLikeCount() > 0
        ? Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.favorite,
                size: 14,
                color: Colors.red[900],
              ),
              Text('${data.getLikeCount()}',
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
        ))
        : SizedBox.shrink();
  }

  Future<String> getReplyName(String tagId) async {
    return DatabaseServices(uid: tagId).getUserByUserId().then((value) {
      UserData userData = UserData.fromDocumentSnapshot(value);
      return userData.username;
    }) as String;
  }

  handlePostComment(CurrentUser user) async {
    DocumentSnapshot snapshot = await DatabaseServices(uid: user.uid)
        .getUserByUserId()
        .then((value) => value);
    UserData currentUser = UserData.fromDocumentSnapshot(snapshot);
    var uuid = Uuid();
    String comment = '';
    if(widget.commentController.text.startsWith('@')){
      comment = widget.commentController.text.substring(widget.commentController.text.indexOf(' ') + 1);
    }
    List<String> commentData = widget.commentController.text.split(' ');
    DatabaseServices(uid: user.uid).postComment(
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
    widget.tag = '';
    widget.replyTo = '';
    widget.commentController.clear();
    widget.commentController.clearComposing();
    FocusScope.of(context).unfocus();
  }

  Future<bool> handleLikeComment(String postId, String uid,
      CommentModel data) async {
    if (data.likes[uid] == false) {
      await DatabaseServices(uid: uid).likeComment(postId, data.commentId);
      data.likes[uid] = true;
      return true;
    } else {
      await DatabaseServices(uid: uid).unlikeComment(postId, data.commentId);
      data.likes[uid] = false;
      return false;
    }
  }

  Widget _buildLikeReply(String rootCommentId,String postId, String uid, CommentModel data, bool isLiked) =>
      Row(
        children: [
          const SizedBox(
            width: 8,
          ),
          GestureDetector(
              onTap: () async {
                await handleLikeComment(
                    postId,
                    uid,
                    data)
                    .then((value) =>
                    setState(() {
                      isLiked = value;
                    }));
              },
              child: Text(
                'Like',
                style: Theme
                    .of(context)
                    .textTheme
                    .caption!
                    .copyWith(
                    color: isLiked
                        ? Colors.blue[
                    800]
                        : Colors.grey[
                    700],
                    fontWeight:
                    FontWeight
                        .bold),
              )),
          const SizedBox(
            width: 24,
          ),
          GestureDetector(
              onTap: () {
                widget.commentController.text = '@' + data.username + ' ';
                widget.replyTo = rootCommentId;
                widget.tag = data.userId;
              },
              child: Text('Reply')),
          const SizedBox(
            width: 12,
          ),
          Text(timeago.format(data.timestamp.toDate())),
          const Spacer(),
          buildLikeCount(data)
        ],
      );

}


