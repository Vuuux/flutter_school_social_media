import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/profile_notifier.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/home/feed/post_screen.dart';

class ForumDetail extends StatefulWidget {
  final String ownerId;
  final String forumId;

  const ForumDetail({Key? key, required this.forumId, required this.ownerId})
      : super(key: key);

  @override
  _ForumDetailState createState() => _ForumDetailState();
}

class _ForumDetailState extends State<ForumDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: <Widget>[
            IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              icon: const Icon(
                LineAwesomeIcons.alternate_sign_out,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot>(
                stream: DatabaseServices(uid: '')
                    .getPostById(widget.ownerId, widget.forumId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    PostModel post =
                        PostModel.fromDocumentSnapshot(snapshot.data!.docs[0]);
                    return PostItem(post: post);
                  }
                  return Loading();
                }),
          ),
        ));
  }
}
