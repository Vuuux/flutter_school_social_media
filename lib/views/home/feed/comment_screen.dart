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
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:provider/src/provider.dart';
import 'package:uuid/uuid.dart';

class ShowComments extends StatefulWidget {
  final BuildContext context;
  final String postId;
  final String ownerId;
  final String mediaUrl;
  TextEditingController commentController = TextEditingController();
  String comment = '';
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

buildCommentTree(String uid, String postId) {
  return StreamBuilder<QuerySnapshot>(
      stream: Stream.fromFuture(DatabaseServices(uid: uid).getComments(postId)),
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
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                          BorderRadius.circular(12)),
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
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          FutureBuilder<DocumentSnapshot>(
                                              future: DatabaseServices(
                                                  uid: data.tagId)
                                                  .getUserByUserId(),
                                              builder: (context, nameSnapshot) {
                                                UserData? userDetail;
                                                if (nameSnapshot.hasData) {
                                                  userDetail = UserData.fromDocumentSnapshot(nameSnapshot.data);
                                                }
                                                return _buildCommentLine(context, data, userDetail);
                                              }
                                          )
                                        ],
                                      ),
                                    ),
                                    DefaultTextStyle(
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.bold),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            const  SizedBox(
                                              width: 8,
                                            ),
                                            GestureDetector(
                                                onTap: (){},
                                                child: Text('Like')),
                                            const SizedBox(
                                              width: 24,
                                            ),
                                            GestureDetector(
                                                onTap: () {},
                                                child: Text('Reply')),
                                            Spacer(),
                                            buildLikeCount(data)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                              contentRoot: (context, data) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data.username,
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .caption!
                                                .copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            data.comment,
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .caption!
                                                .copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DefaultTextStyle(
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.bold),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            GestureDetector(
                                                onTap: (){},
                                                child: const Text('Like')),
                                            const SizedBox(
                                              width: 24,
                                            ),
                                            GestureDetector(
                                                onTap: (){},
                                                child: const Text('Reply')),
                                            const Spacer(),
                                            buildLikeCount(data)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ));
                      });
                });
          } else {
            return const Text('Chưa có bình luận nào :<');
          }
        } else {
          return Loading();
        }
        return const Center(
          child: Text("Chưa có bình luận nào :<"),
        );
      });
}

_buildCommentLine(BuildContext context, CommentModel data, UserData? userDetail) {
  return RichText(
    text: TextSpan(
        children: <TextSpan>[
          TextSpan(
              text: userDetail != null ? userDetail.username + ' ' : '',
              style: Theme
                  .of(context)
                  .textTheme
                  .caption
                  ?.copyWith(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                  color: Colors.blue[800]),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)
                  => OthersProfile(ctuer: userDetail!)));
                }
          ),
          TextSpan(
            text:
            data.comment,
            style: Theme
                .of(context)
                .textTheme
                .caption
                ?.copyWith(
                fontSize: 16,
                fontWeight:
                FontWeight.w300,
                color: Colors.black),
          ),
        ]),
  );
}

buildLikeCount(CommentModel data) {
  return data.getLikeCount() > 0
      ? Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
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
  return DatabaseServices(uid: tagId)
      .getUserByUserId()
      .then((value) {
    UserData userData = UserData.fromDocumentSnapshot(value);
    return userData.username;
  }) as String;
}

class _ShowCommentsState extends State<ShowComments> {
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

  handlePostComment(CurrentUser user) async {
    DocumentSnapshot snapshot = await DatabaseServices(uid: user.uid)
        .getUserByUserId()
        .then((value) => value);
    UserData currentUser = UserData.fromDocumentSnapshot(snapshot);
    var uuid = Uuid();
    DatabaseServices(uid: user.uid).postComment(
        widget.postId,
        currentUser.id,
        uuid.v4(),
        currentUser.username,
        widget.commentController.text,
        Timestamp.now(),
        currentUser.avatar,
        widget.replyTo,
        widget.tag,
    ).then((value) {
          setState(() {

          });
    });
    widget.commentController.clear();
  }
}