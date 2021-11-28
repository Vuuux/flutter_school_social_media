import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/home/feed/post_detail.dart';
import 'package:provider/src/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'comment_screen.dart';

class PostItem extends StatefulWidget {
  final PostModel post;
  bool isLiked = false;
  UserData? currentUser;

  PostItem({Key? key, required this.post}) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  
  buildPostHeader(String uid, BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          DatabaseServices(uid: uid).ctuerRef.doc(widget.post.ownerId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData user = UserData.fromDocumentSnapshot(snapshot.data!);
          return ListTile(
            leading: CircleAvatar(
              child: ClipOval(
                child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Image.network(
                      user.avatar,
                      fit: BoxFit.fill,
                    )),
              ),
              //CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostDetail(postId: widget.post.postId, ownerId: user.id))),
              child: Text(
                user.username,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(widget.post.location +' - ' + timeago.format(widget.post.timestamp.toDate(), locale: "vi")),
            trailing: IconButton(
              onPressed: () => onOpenPostOption(context),
              icon: const Icon(Icons.more_vert),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  onOpenPostOption(BuildContext nContext) {
    return widget.currentUser!.id == widget.post.ownerId ? showDialog(
        context: nContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: const Text(
                  "Xóa bài viết",
                ),
                onPressed: () => DatabaseServices(uid: '').deletePost(widget.post.ownerId, widget.post.postId),
              ),
              SimpleDialogOption(
                child: const Text(
                  "Đóng",
                ),
                onPressed: () {},
              )
            ],
          );
        }) : null;
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () =>
          handleLikePost(widget.post.ownerId, widget.post.postId),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(widget.post.url)),
          //TODO: ANIMATOR HERE
          showHeart
              ? Animator(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, anim, child) => Transform.scale(
                        scale: anim.animation.value as double,
                        child: const Icon(
                          Icons.favorite,
                          size: 80,
                          color: Colors.red,
                        ),
                      ))
              : const SizedBox.shrink()
        ],
      ),
    );
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
                widget.post.username + "  ",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(widget.post.description))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () =>
                  handleLikePost(widget.post.ownerId, widget.post.postId),
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
                      builder: (context) => ShowComments(
                          context: context,
                          postId: widget.post.postId,
                          ownerId: widget.post.ownerId,
                          mediaUrl: widget.post.url))),
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
                "$likeCount lượt thích",
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

  CurrentUser? user;
  int likeCount = 0;
  bool showHeart = false;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    timeago.setLocaleMessages('vi_short', timeago.ViShortMessages());
    for (var val in widget.post.likes.values) {
      if (val == true) {
        likeCount += 1;
      }
    }
  }

  Future getCurrentUserData(String uid) async {
    return await DatabaseServices(uid: uid).getUserByUserId().then((value) {
      setState(() {
        widget.currentUser = UserData.fromDocumentSnapshot(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<CurrentUser?>();
    widget.isLiked = (widget.post.likes[user!.uid] == true);
    getCurrentUserData(user!.uid);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildPostHeader(user!.uid, context),
          buildPostImage(),
          buildPostFooter()
        ],
      ),
    );
  }

  handleLikePost(String ownerId, String postId) {
    bool _isLiked = (widget.post.likes[user!.uid] == true);

    if (_isLiked) {
      DatabaseServices(uid: user!.uid)
          .unlikePost(user!.uid, ownerId, postId)
          .then((value) {
        setState(() {
          likeCount -= 1;
          widget.post.likes[user!.uid] = false;
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
          widget.post.likes[user!.uid] = true;
          showHeart = true;
        });
      });
      DatabaseServices(uid: user!.uid).addLikeNotifications(
          ownerId,
          widget.currentUser!.username,
          user!.uid,
          widget.currentUser!.avatar,
          postId,
          widget.post.url,
          Timestamp.now());
    }
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        showHeart = false;
      });
    });
  }

  buildCommentPage() {
    return ShowComments(
        context: context,
        postId: widget.post.postId,
        ownerId: widget.post.ownerId,
        mediaUrl: widget.post.url);
  }
}
