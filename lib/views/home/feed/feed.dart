import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/components/search_bar.dart';
import 'package:luanvanflutter/views/home/feed/post_screen.dart';
import 'package:luanvanflutter/views/home/feed/upload_image_screen.dart';
import 'package:provider/provider.dart';

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
  Ctuer currentCtuer = Ctuer();
  final picker = ImagePicker(); //API chọn hình ảnh
  //lấy time từ post

  Widget postList(CurrentUser currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: Stream.fromFuture(DatabaseServices(uid: currentUser.uid)
          .getTimelinePosts(currentUser.uid)),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                controller: scrollController,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  String postId = snapshot.data!.docs[index].get('postId');
                  String ownerId = snapshot.data!.docs[index].get('ownerId');
                  String username = snapshot.data!.docs[index].get('username');
                  String location = snapshot.data!.docs[index].get('location');
                  String description =
                      snapshot.data!.docs[index].get('description');
                  Timestamp timestamp =
                      snapshot.data!.docs[index].get('timestamp');
                  String url = snapshot.data!.docs[index].get('url');
                  Map<String, dynamic> likes =
                      snapshot.data!.docs[index].get('likes');

                  final post = PostModel(
                      postId: postId,
                      ownerId: ownerId,
                      username: username,
                      location: location,
                      description: description,
                      url: url,
                      likes: likes,
                      timestamp: timestamp);

                  return Column(children: <Widget>[
                    PostItem(post: post),
                    const Divider(
                      height: 20,
                      thickness: 5,
                      color: kPrimaryLightColor,
                    ),
                  ]);
                })
            : const Center(
                child: Text(
                  "Chưa có bài viết nào.",
                  style: TextStyle(color: Colors.black),
                ),
              );
      },
    );
  }

  @override
  void initState() {
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
  pickImageFromGallery(UserData userData) async {
    Navigator.pop(context);

    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxHeight: 680, maxWidth: 970);
    File imageFile = File(
      pickedFile!.path,
    );
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

  captureImageWithCamera(UserData userData) async {
    Navigator.pop(context);
    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
    File imageFile = File(pickedFile!.path);

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

  takeImage(UserData userData) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Thêm bài viết mới"),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text(
                  "Chụp bằng camera",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () => captureImageWithCamera(userData),
              ),
              SimpleDialogOption(
                child: const Text(
                  "Chọn ảnh từ thư viện",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () => pickImageFromGallery(userData),
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
    final user = context.watch<CurrentUser?>();

    return StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user!.uid).userData,
        builder: (context, snapshot) {
          UserData? userData = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              )),
              title: const Text("F E E D",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(Icons.image),
                    onPressed: () {
                      takeImage(userData!);
                    }),
              ],
            ),
            body: Column(
              children: [
                const CustomSearchBar(),
                //postList(user),
              ],
            ),
          );
          // RefreshIndicator(
          //     child: createTimeLine(), onRefresh: () => retrieveTimeline()));
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
