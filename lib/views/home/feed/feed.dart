import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/helper.dart';
import 'package:luanvanflutter/views/components/search_bar.dart';
import 'package:luanvanflutter/views/home/feed/post_screen.dart';
import 'package:luanvanflutter/views/home/feed/upload_image_screen.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

//Class feed chứa các bài post
class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  Stream<QuerySnapshot>? postsStream;
  final timelineReference = FirebaseFirestore.instance.collection('posts');
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  late CurrentUser currentUser;
  final picker = ImagePicker(); //API chọn hình ảnh
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<QuerySnapshot>? postFuture;
  RefreshController _controller = RefreshController(initialRefresh: false);
  //lấy time từ post

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1), () {
      searchController.clear();
      loadData();
    });
    _controller.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //listPosts.add((listPosts.length+1).toString());
    if (mounted) setState(() {});
    _controller.loadComplete();
  }

  handleSearch(String query) {
    Future<QuerySnapshot> posts = DatabaseServices(uid: '')
        .timelineReference
        .doc(currentUser.uid)
        .collection('timelinePosts')
        .where("description", isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      postFuture = posts;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  loadData() {
    Future<QuerySnapshot> posts = DatabaseServices(uid: currentUser.uid)
        .getTimelinePosts(currentUser.uid);
    setState(() {
      postFuture = posts;
    });
  }

  Widget postList(CurrentUser currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: Stream.fromFuture(postFuture!),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                controller: scrollController,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final PostModel post =
                      PostModel.fromDocument(snapshot.data!.docs[index]);
                  return Column(children: <Widget>[
                    if (index == 0)
                      const SizedBox(
                        height: 80,
                      ),
                    PostItem(post: post),
                    if (index != snapshot.data!.docs.length - 1)
                      const Divider(
                        height: 20,
                        thickness: 5,
                        color: kPrimaryColor,
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
    String userId = auth.currentUser!.uid;
    currentUser = CurrentUser(uid: userId);
    loadData();
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
    CurrentUser? user = context.watch<CurrentUser?>();
    currentUser = user!;
    return StreamBuilder<UserData>(
        stream: DatabaseServices(uid: user.uid).userData,
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
            body: Stack(
              children: [
                SmartRefresher(
                    controller: _controller,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: postList(user)),
                CustomSearchBar(
                  onSearchSubmit: handleSearch,
                  onTapCancel: loadData,
                  searchController: searchController,
                  hintText: 'Tìm kiếm bài viết...',
                ),
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
