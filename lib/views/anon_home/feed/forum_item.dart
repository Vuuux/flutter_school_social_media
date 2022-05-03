import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/forum.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/anon_home/feed/anon_forum_detail.dart';
import 'package:luanvanflutter/views/home/feed/post_detail.dart';
import 'package:provider/src/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'forum_comment_screen.dart';
import 'forum_tile.dart';

class ForumItem extends StatefulWidget {
  final ForumModel forum;
  bool isLiked = false;
  UserData? currentUser;

  ForumItem({Key? key, required this.forum}) : super(key: key);

  @override
  _ForumItemState createState() => _ForumItemState();
}

class _ForumItemState extends State<ForumItem> {
  onOpenPostOption(BuildContext nContext) {
    return widget.currentUser!.id == widget.forum.ownerId
        ? showDialog(
            context: nContext,
            builder: (context) {
              return SimpleDialog(
                children: <Widget>[
                  SimpleDialogOption(
                    child: const Text(
                      "Xóa bài viết",
                    ),
                    onPressed: () => DatabaseServices(uid: '').deleteForum(
                      widget.forum.forumId,
                      widget.forum.ownerId,
                    ),
                  ),
                  SimpleDialogOption(
                    child: const Text(
                      "Đóng",
                    ),
                    onPressed: () {},
                  )
                ],
              );
            })
        : null;
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        const Padding(padding: EdgeInsets.only(top: 10)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                widget.forum.username + "  ",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(widget.forum.description))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () =>
                  handleLikePost(widget.forum.ownerId, widget.forum.forumId),
              child: widget.isLiked
                  ? const Icon(
                      Icons.favorite,
                      size: 28.0,
                      color: Colors.pink,
                    )
                  : const Icon(
                      Icons.favorite_border,
                      size: 28.0,
                      color: Colors.pink,
                    ),
            ),
            const Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShowForumComments(
                          context: context, forum: widget.forum))),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount up votes",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  CurrentUserId? user;
  int likeCount = 0;
  bool showHeart = false;

  @override
  void initState() {
    super.initState();
    for (var val in widget.forum.upVotes.values) {
      if (val == true) {
        likeCount += 1;
      }
    }
  }

  Future getCurrentUserData(String uid) async {
    return await DatabaseServices(uid: uid).getUserByUserId();
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<CurrentUserId?>();
    widget.isLiked = (widget.forum.upVotes[user!.uid] == true);
    getCurrentUserData(user!.uid).then((value) {
      setState(() {
        widget.currentUser = UserData.fromDocumentSnapshot(value);
      });
    });
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: ForumTile(forum: widget.forum, userId: user!.uid));
  }

  handleLikePost(String ownerId, String postId) {
    bool _isLiked = (widget.forum.upVotes[user!.uid] == true);

    if (_isLiked) {
      DatabaseServices(uid: user!.uid)
          .unlikePost(user!.uid, ownerId, postId)
          .then((value) {
        setState(() {
          likeCount -= 1;
          widget.forum.upVotes[user!.uid] = false;
        });
      });

      DatabaseServices(uid: user!.uid).removeLikeNotifications(ownerId, postId);
    } else if (!_isLiked) {
      DatabaseServices(uid: user!.uid)
          .likePost(user!.uid, ownerId, postId)
          .then((value) {
        setState(() {
          likeCount += 1;
          widget.isLiked = true;
          widget.forum.upVotes[user!.uid] = true;
          showHeart = true;
        });
      });
      DatabaseServices(uid: user!.uid).addLikeNotifications(
          ownerId,
          widget.currentUser!.username,
          user!.uid,
          widget.currentUser!.avatar,
          postId,
          widget.forum.mediaUrl,
          Timestamp.now());
    }
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        showHeart = false;
      });
    });
  }

  buildCommentPage() {
    return ShowForumComments(context: context, forum: widget.forum);
  }
}
