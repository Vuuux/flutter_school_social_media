import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/comment.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:provider/src/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatefulWidget {
  final String postId;
  final CommentModel data;
  late bool isLiked;
  final Size size;

  //final ValueChanged<MyProfileData> updateMyDataToMain;
  //final ValueChanged<List<String>> replyComment;
  CommentItem({Key? key, required this.postId,required this.data, required this.size}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommentItem();
}

class _CommentItem extends State<CommentItem> {
  //MyProfileData _currentMyData;
  @override
  void initState() {
    super.initState();
    if(mounted){
      getReply();
    }
  }

  void _updateLikeCount(bool isLikePost) async {
    //MyProfileData _newProfileData = await Utils.updateLikeCount(widget.data,isLikePost,widget.myData,widget.updateMyDataToMain,false);
    setState(() {
      //_currentMyData = _newProfileData;
    });
  }

  String replyName = '';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUser?>();
    widget.isLiked = widget.data.likes[user!.uid] == true;
    getReply();
    return Padding(
      padding: widget.data.replyTo.isEmpty ? const EdgeInsets.all(8.0)
            : const EdgeInsets.fromLTRB(34.0,8.0,8.0,8.0),
      child: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 2.0, 10.0, 2.0),
                child: Container(
                  width: widget.data == null ? 48 : 40,
                  height: widget.data == null ? 48 : 40,
                  child: CachedNetworkImage(imageUrl: widget.data.avatar),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              widget.data.username,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: widget.data.replyTo.isEmpty
                                ? Text(
                              widget.data.comment,
                              maxLines: null,
                            )
                                : RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: replyName + ' ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800])),
                                  TextSpan(
                                      text: widget.data.comment,
                                      // Utils.commentWithoutReplyUser(
                                      //     widget.data.comment),
                                      style: const TextStyle(
                                          color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //width: widget.size.width- (widget.data.commentId == null ? 90 : 110),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                      const BorderRadius.all(Radius.circular(15.0)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          GestureDetector(
                              onTap: () => handleLikeComment(user.uid),
                              child: Text('Like',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.isLiked
                                          ? Colors.blue[900]
                                          : Colors.grey[700]))),
                          const SizedBox(width: 5,),
                          GestureDetector(
                              onTap: () {
                                //TODO: handle reply
                                //widget.replyComment([widget.data['userName'],widget.data['commentID'],widget.data['FCMToken']]);
//                                _replyComment(widget.data['userName'],widget.data['commentID'],widget.data['FCMToken']);
                                print('leave comment of commnet');
                              },
                              child: Text('Reply',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700]))),
                          const SizedBox(width: 5,),
                          Text(
                              timeago.format(widget.data.timestamp.toDate())),
                        ],
                      ),
                    ),
                  ),
                  buildReplySection(user),
                ],
              ),
            ],
          ),
          buildLikeCount()
        ],
      ),
    );
  }

  handleLikeComment(String uid) async {
    await DatabaseServices(uid: uid).likeComment(
        widget.postId, widget.data.commentId);
    setState(() {
      widget.isLiked = !widget.isLiked;
      widget.data.likes[uid] = !widget.data.likes[uid];
    });
  }

  buildReplySection(CurrentUser user) {
    return SizedBox(
        height: 200,
        //mainAxisAlignment: MainAxisAlignment.start,
        child:
        StreamBuilder<QuerySnapshot>(
            stream: Stream.fromFuture(DatabaseServices(uid: user.uid).getComments(widget.postId)),
            builder: (context, snapshot){
              if(snapshot.hasData){
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return CommentItem(
                        postId: widget.postId,
                        data:
                        CommentModel.fromDocument(snapshot.data!.docs[index]),
                        size: const Size(100, 100));
                  },
                );
              }
              return const SizedBox.shrink();
            })
    );
   }

  Future<void> getReply() async {
    if(widget.data.replyTo.isNotEmpty){
      DocumentSnapshot snapshot = await DatabaseServices(uid: widget.data.userId)
          .getUserByUserId()
          .then((value) => value);
      UserData userData = UserData.fromDocumentSnapshot(snapshot);
      setState(() {
        replyName = userData.username;
      });

    }
  }

  buildLikeCount() {
    return widget.data.getLikeCount() > 0
        ? Positioned(
      bottom: 10,
      right: 0,
      child: Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.thumb_up,
                  size: 14,
                  color: Colors.blue[900],
                ),
                Text('${widget.data.getLikeCount()}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          )),
    )
        : Container();
  }
}
