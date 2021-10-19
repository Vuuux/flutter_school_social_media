import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:provider/src/provider.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final Timestamp timestamp;
  final String url;
  final dynamic likes;

  const Post(
      {Key? key,
        required this.postId,
        required this.ownerId,
        required this.username,
        required this.location,
        required this.description,
        required this.url,
        required this.likes,
        required this.timestamp})
      : super(key: key);


  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
        postId: doc['postId'],
        ownerId: doc['ownerId'],
        username: doc['username'],
        location: doc['location'],
        description: doc['description'],
        url: doc['url'],
        likes: doc['likes'],
        timestamp: doc['timestamp'],);
  }

  int getLikeCount() {
    if (likes == null) {
      return 0;
    }

    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });

    return count;
  }


  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  int likeCount = 0;

  buildPostHeader(String uid) {

    return FutureBuilder<DocumentSnapshot>(
      future: DatabaseServices(uid: uid).ctuerRef.doc(widget.ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        }
        UserData user = UserData.fromDocumentSnapshot(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            child: ClipOval(
              child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Image.network(
                    user.avatar,
                    fit: BoxFit.fill,
                  )
              ),
            ),
            //CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print('showing profile'),
            child: Text(
              user.name,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(widget.location),
          trailing: IconButton(
            //TODO: DELETE POST
            onPressed: () => print('deleting post'),
            icon: const Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => print('liking post'),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(widget.url),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 10)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                widget.username + "  ",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(widget.description))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () => print('liking post'),
              child: const Icon(
                Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => print('showing comments'),
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
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount luợt thích",
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUser?>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(user!.uid),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

}
