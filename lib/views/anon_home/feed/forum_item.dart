import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/forum.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';

import 'anon_comment_screen.dart';

class ForumTile extends StatelessWidget {
  final ForumModel forum;
  final UserData userData;
  ForumTile(
      {Key? key, required this.forum,
        required this.userData}) : super(key: key);
  int upVoteCount = 0;
  int downVoteCount = 0;
  @override
  Widget build(BuildContext context) {
    upVoteCount = forum.getUpvoteCount();
    upVoteCount = forum.getDownVoteCount();
    return FocusedMenuHolder(
      menuWidth: MediaQuery.of(context).size.width,
      menuBoxDecoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AnonShowComments(
                context: context,
                postId: forum.forumId,
                ownerId: forum.ownerId,
                mediaUrl: forum.url))),
      menuItems: <FocusedMenuItem>[
        FocusedMenuItem(
            title: const Text(
              "Xóa Forum",
              style: TextStyle(color: Colors.black),
            ),
            trailingIcon: Icon(Icons.delete),
            onPressed: () {
              // DatabaseServices()
              //     .blogRef
              //     .document(description)
              //     .collection('chats')
              //     .getDocuments()
              //     .then((doc) {
              //   if (doc.documents[0].exists) {
              //     doc.documents[0].reference.delete();
              //   }
              // });

              // DatabaseServices()
              //     .forumRef
              //     .doc(forumId)
              //     .get()
              //     .then((doc) {
              //   if (doc.exists) {
              //     doc.reference.delete();
              //   }
              // });
            },
            backgroundColor: Colors.redAccent)
      ],
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AnonShowComments(
                    context: context,
                    postId: forum.forumId,
                    ownerId: forum.ownerId,
                    mediaUrl: forum.url))),
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          height: 150,
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  forum.url,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 170,
                decoration: BoxDecoration(
                    color: Colors.black45.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6)),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      forum.category.toUpperCase(),
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      forum.description,
                      style:
                      const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(forum.username)
                    ,
                    Text(
                      "$upVoteCount up votes",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}