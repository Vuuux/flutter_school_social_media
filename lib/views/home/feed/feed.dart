import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/home/feed/upload_image_screen.dart';
import 'package:provider/provider.dart';

import 'comment_page_screen.dart';

//Class feed chứa các bài post
class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  Stream<QuerySnapshot>? postsStream;
  final timelineReference = FirebaseFirestore.instance.collection('posts');
  ScrollController scrollController = new ScrollController();
  late Ctuer currentCtuer;
  final picker = ImagePicker(); //API chọn hình ảnh

  //lấy time từ post
  retrieveTimeline() async {
    DatabaseServices(uid: currentCtuer.id).getPosts().then((val) {
      setState(() {
        postsStream = val;
      });
    });
  }

  Widget feedList(List<Ctuer> hmmies) {
    return StreamBuilder<QuerySnapshot> (
      stream: postsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
            controller: scrollController,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              String email = snapshot.data!.docs[index].get('email');
              String description =
              snapshot.data!.docs[index].get('description');
              Timestamp timestamp =
              snapshot.data!.docs[index].get('timestamp');
              String url = snapshot.data!.docs[index].get('url');
              String postId = snapshot.data!.docs[index].get('postId');
              int likes = snapshot.data!.docs[index].get('likes');
              //TODO: GET POST FROM FOLLOWER HERE
              print(email);
              for (int i = 0; i < hmmies.length; i++) {
                if (hmmies[i].email == email) {
                  currentCtuer = hmmies[i];
                }
              }

              return FeedTile(
                ctuer: currentCtuer,
                ctuerList: hmmies,
                description: description,
                timestamp: timestamp,
                url: url,
                postId: postId,
                likes: likes,
              );
            })
            : Container();
      },
    );
  }

  @override
  void initState() {
    retrieveTimeline();
    super.initState();
  }

  circularProgress() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 12),
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.redAccent),
      ),
    );
  }

  //lấy ảnh từ thư viện
  pickImageFromGallery(context, userData) async {
    Navigator.pop(context);

    PickedFile? pickedFile = await ImagePicker().getImage(source: ImageSource.gallery,maxHeight: 680, maxWidth: 970);
    File imageFile = File(pickedFile!.path,);
    if (imageFile == null) {
      // Navigator.of(context);
      // .pushAndRemoveUntil(
      //     FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UploadImage(file: imageFile, userData: userData),
        ),
      );
    }
  }

  captureImageWithCamera(context, userData) async {
    Navigator.pop(context);
    PickedFile? pickedFile = await ImagePicker().getImage(source: ImageSource.camera,maxHeight: 680, maxWidth: 970);
    File imageFile = File(pickedFile!.path);
    // File imageFile = await ImagePicker.pickImage(
    //     source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
    if (imageFile == null) {
      // Navigator.of(context).pushAndRemoveUntil(
      //     FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UploadImage(file: imageFile, userData: userData),
        ),
      );
    }
    if (imageFile == null) {
      // Navigator.of(context).pushAndRemoveUntil(
      //     FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UploadImage(file: imageFile, userData: userData),
        ),
      );
    }
  }

  takeImage(nContext, userData) {
    return showDialog(
        context: nContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Thêm bài viết mới"),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text(
                  "Chụp bằng camera",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () => captureImageWithCamera(nContext, userData),
              ),
              SimpleDialogOption(
                child: const Text(
                  "Chọn ảnh từ thư viện",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () => pickImageFromGallery(nContext, userData),
              ),
              SimpleDialogOption(
                child: const Text(
                  "Đóng",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        const BoxConstraints(
          maxWidth: 414,
          maxHeight: 869,
        ),
        designSize: const Size(360, 690),
        orientation: Orientation.portrait);
    //final hmmies = Provider.of<List<Ctuer>>(context);
    final user = context.watch<CurrentUser?>();
    return StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user!.uid).userData,
        builder: (context, snapshot) {
          UserData? userData = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: const Text("F E E D",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
              actions: <Widget>[
                IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(Icons.image),
                    onPressed: () {
                      takeImage(context, userData);
                    }),
              ],
            ),
            //TODO: ADD USER LIST HERE
            body: feedList([]),
          );
          // RefreshIndicator(
          //     child: createTimeLine(), onRefresh: () => retrieveTimeline()));
        });
  }
}

class FeedTile extends StatefulWidget {
  final Ctuer ctuer;
  final List<Ctuer> ctuerList;
  final Timestamp timestamp;
  final String description;
  final String url;
  final String postId;
  final int likes;

  FeedTile(
      {required this.ctuerList,
        required this.ctuer,
        required this.timestamp,
        required this.description,
        required this.url,
        required this.postId,
        required this.likes});

  @override
  _FeedTileState createState() => _FeedTileState();
}

class _FeedTileState extends State<FeedTile> {
  final f = DateFormat('h:mm a');

  late bool checkIfWasMe;
  bool liked = false;
  @override
  void initState() {
    getlikes();
    // TODO: implement initState
    super.initState();
  }

  getlikes() {
    DatabaseServices(uid: '')
        .postRef
        .doc(widget.postId)
        .collection('likes')
        .doc(Constants.myEmail)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          liked = true;
        });
      }
    });
  }

  createPostHead(context, UserData userData) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 10,
          ),
          CircleAvatar(
            radius: 15,
            child: ClipOval(
              child: SizedBox(
                width: 180,
                height: 180,
                child: Image.network(
                  widget.ctuer.avatar,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${widget.ctuer.name}',
            //TODO: ADD STYLE HERE
            //style: ,
          ),
          const Spacer(),
          checkIfWasMe
              ? IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => createAlertDialog(context),
          )
              : const Text('')
        ],
      ),
    );
  }

  createAlertDialog(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Bạn chắc muốn xóa post này chứ?'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    DatabaseServices(uid: '')
                        .postRef
                        .doc(widget.postId)
                        .get()
                        .then((doc) {
                      if (doc.exists) {
                        doc.reference.delete();

                        Navigator.pop(context);
                      }
                    });
                  }),
            ],
          );
        });
  }

  createPostPicture(UserData userData) {
    return GestureDetector(
      onDoubleTap: liked
          ? () {}
          : () {
        setState(() {
          liked = true;
          DatabaseServices(uid: '')
              .likePost(widget.likes, widget.postId, userData.email);
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[Image.network(widget.url)],
      ),
    );
  }

  createPostFooter(context, UserData userData) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.only(left: 10),
              onPressed: liked
                  ? () {
                setState(() {
                  liked = false;
                  DatabaseServices(uid: '').unlikePost(
                      widget.likes, widget.postId, userData.email);
                });
              }
                  : () {
                setState(() {
                  liked = true;
                  DatabaseServices(uid: '').likePost(
                      widget.likes, widget.postId, userData.email);
                });
              },
              icon: liked
                  ? const Icon(LineAwesomeIcons.heart_1)
                  : const Icon(LineAwesomeIcons.heart),
              iconSize: 25,
              color: liked ? Colors.redAccent : Colors.white,
            ),
            Text(
              '${widget.likes}',
            )
          ],
        ),
        Row(
          children: <Widget>[
            const SizedBox(
              width: 10,
            ),
            CircleAvatar(
              radius: 15,
              child: ClipOval(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Image.network(
                    widget.ctuer.avatar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              widget.ctuer.name,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 5),
            widget.description.length <= 18
                ? Text(
              widget.description,
              style: const TextStyle(fontSize: 12),
            )
                : FlatButton(
              child: Text('more...'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    FadeRoute(
                      page: CommentsPage(
                          ctuer: widget.ctuer,
                          description: widget.description),
                    ),
                    ModalRoute.withName('CommentsPage'));
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(f.format(widget.timestamp.toDate())),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUser>();
    return StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user.uid).userData,
        builder: (context, snapshot) {
          UserData? userData = snapshot.data;
          print("CONSTANT " + Constants.myEmail);
          checkIfWasMe = Constants.myEmail == widget.ctuer.email;
          return GestureDetector(
            onTap: () {
              // Navigator.of(context).pushAndRemoveUntil(
              //     FadeRoute(
              //       page: ConversationScreen(
              //         hmmies: hmmies,
              //         hmmie: hmmie,
              //         userData: userData,
              //       ),
              //     ),
              //     ModalRoute.withName('ConversationScreen'));
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  createPostHead(context, userData!),
                  createPostPicture(userData),
                  const SizedBox(
                    height: 10,
                  ),
                  createPostFooter(context, userData),
                ],
              ),
            ),
          );
        });
  }
}
