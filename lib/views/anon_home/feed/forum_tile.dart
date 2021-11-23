import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/forum.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';

import 'forum_comment_screen.dart';

class ForumTile extends StatelessWidget {
  final ForumModel forum;
  final String userId;

  ForumTile(
      {Key? key, required this.forum,
        required this.userId}) : super(key: key);


  String defineCategory(String category){
    String type;
    switch(category){
      case 'questions':
        type = 'Hỏi đáp';
        break;
      case 'studying':
        type = 'Học tập';
        break;
      case 'advise':
        type = 'Tư vấn';
        break;
      case 'secret':
        type = 'Tâm sự đời tư';
        break;
      default:
        type = 'Xin hỗ trợ';
        break;
    }
    return type;
  }

  Color defineColor(String category){
    Color color = Colors.white;
    switch(category){
      case 'questions':
        color = kQuestionColor;
        break;
      case 'studying':
        color = kStudyColor;
        break;
      case 'advise':
        color = kAdviseColor;
        break;
      case 'secret':
        color = kSecretColor;
        break;
      default:
        color = kSupportColor;
        break;
    }
    return color;
  }

  String shortText(String text) {
    if(text.length > 40) {
      return text.substring(0, 50).trim() + '...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
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
            builder: (context) => ShowForumComments(
                context: context,
                forum: forum))),
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
                builder: (context) => ShowForumComments(
                    context: context,
                    forum: forum))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            gradient:  LinearGradient(
              colors: [
                defineColor(forum.category),
                kPrimaryDarkColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment(1.0, 1.0)
            )
          ),
          height: 150,
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(forum.mediaUrl),
                    )
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          defineCategory(forum.category), style: const TextStyle( color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 3),
                        const Icon(Icons.explore),
                        const SizedBox(width: 3,),
                        Text(forum.username, style: const TextStyle( color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)
                      ],
                    ),
                    Container(
                      height: 75,
                      alignment: Alignment.center,
                      child: Text(
                       shortText(forum.title),
                        textAlign: TextAlign.center,
                        style:
                        const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w400),
                      ),
                    ),
                    Text(
                      forum.getUpvoteCount().toString() + " up votes",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      forum.getDownVoteCount().toString() + " down votes",
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