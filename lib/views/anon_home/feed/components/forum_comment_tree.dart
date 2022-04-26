import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_tree/widgets/comment_tree_widget.dart';
import 'package:comment_tree/widgets/tree_theme_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/comment.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/anon_home/profile/anon_profile.dart';
import 'package:luanvanflutter/views/anon_home/profile/others_anon_profile.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:luanvanflutter/views/home/profile/profile.dart';
import 'package:provider/src/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumCommentTree extends StatefulWidget {
  final String forumId;
  final CommentModel comment;
  final List<CommentModel> cmtList;
  final Function onClickReply;

  const ForumCommentTree(
      {Key? key,
      required this.forumId,
      required this.comment,
      required this.cmtList,
      required this.onClickReply})
      : super(key: key);

  @override
  State<ForumCommentTree> createState() => _ForumCommentTreeState();
}

class _ForumCommentTreeState extends State<ForumCommentTree> {
  Future<bool> handleLikeComment(
      String forumId, String uid, CommentModel data) async {
    if (data.likes[uid] == false || data.likes.isEmpty) {
      await DatabaseServices(uid: uid)
          .likeForumComment(forumId, data.commentId);
      data.likes[uid] = true;
      return true;
    } else {
      await DatabaseServices(uid: uid)
          .unlikeForumComment(forumId, data.commentId);
      data.likes[uid] = false;
      return false;
    }
  }

  Widget _buildLikeReply(String rootCommentId, String forumId, String uid,
          CommentModel data, bool isLiked) =>
      Row(
        children: [
          const SizedBox(
            width: 8,
          ),
          GestureDetector(
              onTap: () async {
                await handleLikeComment(forumId, uid, data).then((value) {
                  setState(() {
                    isLiked = value;
                  });
                });
              },
              child: Text(
                'Like',
                style: TextStyle(
                    color: isLiked ? Colors.blue[800] : Colors.grey[700],
                    fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            width: 24,
          ),
          GestureDetector(
              onTap: () =>
                  widget.onClickReply(data, rootCommentId, data.userId),
              child: Text('Reply')),
          const SizedBox(
            width: 12,
          ),
          Text(timeago.format(data.timestamp.toDate())),
          const Spacer(),
          buildLikeCount(data)
        ],
      );

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
        : const SizedBox.shrink();
  }

  _buildCommentLine(BuildContext context, CommentModel data,
      UserData? userDetail, String uid) {
    return RichText(
      text: TextSpan(children: <TextSpan>[
        TextSpan(
            text: userDetail != null ? userDetail.nickname + ' ' : '',
            style: Theme.of(context).textTheme.caption?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800]),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => userDetail!.id == uid
                        ? const AnonProfile()
                        : OthersAnonProfile(ctuerId: userDetail.id)));
              }),
        TextSpan(
          text: data.comment,
          style: Theme.of(context).textTheme.caption?.copyWith(
              fontSize: 16, fontWeight: FontWeight.w300, color: Colors.black),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    CurrentUserId user = context.watch<CurrentUserId>();
    String uid = user.uid;
    return CommentTreeWidget<CommentModel, CommentModel>(
      widget.comment,
      widget.cmtList,
      treeThemeData: TreeThemeData(
          lineColor:
              widget.cmtList.isEmpty ? Colors.transparent : kPrimaryColor,
          lineWidth: 2),
      avatarRoot: (context, data) => PreferredSize(
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey,
          backgroundImage: CachedNetworkImageProvider(data.avatar),
        ),
        preferredSize: const Size.fromRadius(28),
      ),
      avatarChild: (context, data) => PreferredSize(
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey,
          backgroundImage: CachedNetworkImageProvider(data.avatar),
        ),
        preferredSize: const Size.fromRadius(18),
      ),
      contentChild: (context, data) {
        return FutureBuilder<DocumentSnapshot>(
            future: DatabaseServices(uid: data.tagId).getUserByUserId(),
            builder: (context, nameSnapshot) {
              UserData? userDetail;
              bool isLiked = false;
              isLiked = data.likes[uid] == true;
              if (nameSnapshot.hasData) {
                userDetail = UserData.fromDocumentSnapshot(nameSnapshot.data!);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.username,
                          style: Theme.of(context).textTheme.caption?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        _buildCommentLine(context, data, userDetail, uid)
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _buildLikeReply(widget.comment.commentId,
                          widget.forumId, uid, data, isLiked))
                ],
              );
            });
      },
      contentRoot: (context, data) {
        return FutureBuilder<DocumentSnapshot>(
            future: DatabaseServices(uid: data.tagId).getUserByUserId(),
            builder: (context, rootSnapshot) {
              UserData? userDetail;
              bool isRootLiked = false;
              isRootLiked = data.likes[uid] == true;
              if (rootSnapshot.hasData) {
                userDetail = UserData.fromDocumentSnapshot(rootSnapshot.data!);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.username,
                          style: Theme.of(context).textTheme.caption?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        _buildCommentLine(context, data, userDetail, uid)
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _buildLikeReply(widget.comment.commentId,
                          widget.forumId, uid, data, isRootLiked))
                ],
              );
            });
      },
    );
  }
}
