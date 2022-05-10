import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_tree/comment_tree.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/comment.dart';
import 'package:luanvanflutter/models/forum.dart';
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

import 'components/forum_comment_tree.dart';

class ShowForumComments extends StatefulWidget {
  final BuildContext context;
  final ForumModel forum;
  TextEditingController commentController = TextEditingController();
  String replyTo = '';
  String tag = '';
  UserData? currentUser;
  bool isVoted = false;
  bool isUpVoted = false;
  bool isDownVoted = false;
  ShowForumComments({Key? key, required this.context, required this.forum})
      : super(key: key);

  @override
  _ShowForumCommentsState createState() => _ShowForumCommentsState();
}

class _ShowForumCommentsState extends State<ShowForumComments> {
  int upVoteCount = 0;
  int downVoteCount = 0;
  ScrollController _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    timeago.setLocaleMessages('vi_short', timeago.ViShortMessages());
    if (mounted) {
      downVoteCount = widget.forum.getDownVoteCount();
      upVoteCount = widget.forum.getUpvoteCount();
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
    return await DatabaseServices(uid: uid).getUserByUserId().then((value) {
      setState(() {
        widget.currentUser = UserData.fromDocumentSnapshot(value);
      });
    });
  }

  handleUpvote(String uid, String ownerId, String forumId) {
    if (widget.isVoted && widget.isDownVoted) {
      DatabaseServices(uid: uid)
          .updateVoteForum(uid, forumId, true, false)
          .then((value) {
        setState(() {
          upVoteCount += 1;
          downVoteCount -= 1;
          widget.forum.upVotes[uid] = true;
          widget.forum.downVotes[uid] = false;
          widget.isDownVoted = false;
          widget.isUpVoted = true;
        });
      });
    } else if (widget.isVoted && widget.isUpVoted) {
      DatabaseServices(uid: uid)
          .updateVoteForum(uid, forumId, false, false)
          .then((value) {
        setState(() {
          widget.isVoted = false;
          upVoteCount -= 1;
          widget.forum.upVotes[uid] = false;
          widget.forum.downVotes[uid] = false;
          widget.isDownVoted = false;
          widget.isUpVoted = false;
        });
      });
    } else if (!widget.isVoted && !widget.isDownVoted && !widget.isUpVoted) {
      DatabaseServices(uid: uid).upVoteForum(uid, forumId).then((value) {
        setState(() {
          upVoteCount += 1;
          widget.isVoted = true;
          widget.forum.upVotes[uid] = true;
          widget.isDownVoted = false;
          widget.isUpVoted = true;
        });
      });
      DatabaseServices(uid: uid).addVoteNotifications(
          ownerId,
          widget.currentUser!.nickname,
          uid,
          widget.currentUser!.anonAvatar,
          forumId,
          widget.forum.mediaUrl,
          Timestamp.now());
    }
  }

  handleDownVote(String uid, String ownerId, String forumId) {
    if (widget.isVoted && widget.isDownVoted) {
      DatabaseServices(uid: uid)
          .updateVoteForum(uid, forumId, false, false)
          .then((value) {
        setState(() {
          widget.isVoted = false;
          downVoteCount -= 1;
          widget.forum.upVotes[uid] = false;
          widget.forum.downVotes[uid] = false;
          widget.isDownVoted = false;
          widget.isUpVoted = false;
        });
      });
    } else if (widget.isVoted && widget.isUpVoted) {
      DatabaseServices(uid: uid)
          .updateVoteForum(uid, forumId, false, true)
          .then((value) {
        setState(() {
          downVoteCount += 1;
          upVoteCount -= 1;
          widget.forum.upVotes[uid] = false;
          widget.forum.downVotes[uid] = true;
          widget.isDownVoted = true;
          widget.isUpVoted = false;
        });
      });
    } else if (!widget.isVoted && !widget.isDownVoted && !widget.isUpVoted) {
      DatabaseServices(uid: uid).downVoteForum(uid, forumId).then((value) {
        setState(() {
          downVoteCount += 1;
          widget.isVoted = true;
          widget.isDownVoted = true;
          widget.forum.downVotes[uid] = true;
        });
      });
    }
  }

  buildForumFooter(String uid) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              onTap: () =>
                  handleUpvote(uid, widget.forum.ownerId, widget.forum.forumId),
              child: widget.isUpVoted
                  ? const Icon(
                      Icons.thumb_up,
                      size: 20.0,
                      color: Colors.blue,
                    )
                  : const Icon(
                      Icons.thumb_up_outlined,
                      size: 20.0,
                      color: Colors.blue,
                    ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: Text(
                "$upVoteCount /",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => handleDownVote(
                  uid, widget.forum.ownerId, widget.forum.forumId),
              child: widget.isDownVoted
                  ? const Icon(
                      Icons.thumb_down,
                      size: 20.0,
                      color: Colors.red,
                    )
                  : const Icon(
                      Icons.thumb_down_outlined,
                      size: 20.0,
                      color: Colors.red,
                    ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: Text(
                "$downVoteCount",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    widget.isVoted = (widget.forum.upVotes[user!.uid] == true ||
        widget.forum.downVotes[user.uid] == true);
    widget.isUpVoted = widget.forum.upVotes[user.uid] == true;
    widget.isDownVoted = widget.forum.downVotes[user.uid] == true;

    return Scaffold(
      bottomNavigationBar: ListTile(
        title: TextFormField(
          controller: widget.commentController,
          decoration: const InputDecoration(labelText: "Nhập bình luận..."),
        ),
        trailing: OutlineButton(
          onPressed: () => handlePostComment(user.uid),
          borderSide: BorderSide.none,
          child: const Text("GỬI"),
        ),
      ),
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
      body: SingleChildScrollView(
        controller: _controller,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "Nội dung",
                style: TextStyle(fontSize: 18),
              ),
            ),
            ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  child: CachedNetworkImage(
                    imageUrl: widget.forum.mediaUrl,
                    height: 200,
                    width: 200,
                  ),
                )),
            Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  color: kPrimaryColor.withOpacity(0.6),
                ),
                child: Center(
                    child: Text(
                  widget.forum.description,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timeago.format(widget.forum.timestamp.toDate(), locale: 'vi'),
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
            ),
            buildForumFooter(user.uid),
            const Divider(
              thickness: 3,
            ),
            buildCommentTree(user.uid, widget.forum.forumId),
            const Divider(
              thickness: 3,
            ),
          ],
        ),
      ),
    );
  }

  buildCommentTree(String uid, String forumId) {
    return StreamBuilder<QuerySnapshot>(
        stream: Stream.fromFuture(
            DatabaseServices(uid: "").getForumComments(widget.forum.forumId)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    CommentModel comment;
                    comment = CommentModel.fromDocumentSnapshot(
                        snapshot.data!.docs[index]);
                    return StreamBuilder<QuerySnapshot>(
                        stream: Stream.fromFuture(DatabaseServices(uid: uid)
                            .getForumReplyComments(forumId, comment.commentId)),
                        builder: (context, snapshot2) {
                          List<CommentModel> cmtList = [];
                          if (snapshot2.hasData) {
                            for (var doc in snapshot2.data!.docs) {
                              CommentModel cmt =
                                  CommentModel.fromDocumentSnapshot(doc);
                              cmtList.add(cmt);
                            }
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: ForumCommentTree(
                              forumId: forumId,
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
            return const Text("Không có bình luận nào");
          }
        });
  }

  Future<String> getReplyName(String tagId) async {
    return DatabaseServices(uid: tagId).getUserByUserId().then((value) {
      UserData userData = UserData.fromDocumentSnapshot(value);
      return userData.nickname;
    }) as String;
  }

  handlePostComment(String uid) async {
    getCurrentUserData(uid);

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

    DatabaseServices(uid: uid).postForumComment(
      widget.forum.forumId,
      currentUser.id,
      uuid.v4(),
      currentUser.nickname,
      comment,
      Timestamp.now(),
      currentUser.anonAvatar,
      widget.replyTo,
      widget.tag,
    );
    bool isNotPostOwner = widget.forum.ownerId != uid;
    if (isNotPostOwner) {
      DatabaseServices(uid: uid).addForumCommentNotifications(
          postOwnerId: widget.forum.ownerId,
          comment: comment,
          forumId: widget.forum.forumId,
          uid: uid,
          nickname: currentUser.nickname,
          avatar: currentUser.anonAvatar,
          url: widget.forum.mediaUrl,
          timestamp: Timestamp.now());
    }
    widget.tag = '';
    widget.replyTo = '';
    widget.commentController.clear();
    widget.commentController.clearComposing();
    FocusScope.of(context).unfocus();
  }
}
