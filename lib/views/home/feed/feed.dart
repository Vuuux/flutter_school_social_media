import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/helper.dart';
import 'package:luanvanflutter/utils/theme_service.dart';
import 'package:luanvanflutter/views/components/app_bar/custom_sliver_app_bar.dart';
import 'package:luanvanflutter/views/components/buttons/ripple_animation.dart';
import 'package:luanvanflutter/views/components/dialog/custom_dialog.dart';
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
        if (snapshot.hasData) {
          List<PostModel> listPost = snapshot.data!.docs
              .map((doc) => PostModel.fromDocument(doc))
              .toList();
          if (listPost.isEmpty) {
            return const Center(
              child: Text(
                "Chưa có bài viết nào.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            controller: scrollController,
            itemCount: listPost.length,
            itemBuilder: (context, index) {
              final PostModel post = listPost[index];
              return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                      child: FadeInAnimation(child: PostItem(post: post))));
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                height: 6,
                width: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
              );
            },
          );
        }
        return Loading();
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
              body: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) => [
                            CustomAppBar(
                                title: 'T Ư Ờ N G   N H À',
                                background: Image.asset(
                                  "assets/images/ctu.jpg",
                                  fit: BoxFit.cover,
                                  color: Colors.white.withOpacity(0.95),
                                  colorBlendMode: BlendMode.modulate,
                                ),
                                trailingIcon: Icons.image,
                                onLeadingClick: () => null,
                                onTrailingClick: () {
                                  takeImage(userData!);
                                }),
                          ],
                  body: Stack(
                    children: [
                      postList(user).paddingOnly(top: 55),
                      CustomSearchBar(
                        onSearchSubmit: handleSearch,
                        onTapCancel: loadData,
                        searchController: searchController,
                        hintText: 'Tìm kiếm bài viết...',
                      ),
                      Positioned(
                        bottom: 80.0,
                        right: 8.0,
                        child: RipplesAnimation(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const CustomDialog(
                                    title: 'Đi kết bạn nào!',
                                    description:
                                        'Hôm nay bạn sẽ kết bạn với Hmmie nào đây?',
                                    buttonText: 'Tìm hiểu',
                                  );
                                });
                          },
                          size: 20.0,
                          color: kPrimaryDarkColor,
                          child: Icon(Icons.face),
                          // style: ButtonStyle(
                          //   shape: MaterialStateProperty.all(CircleBorder()),
                          //   padding:
                          //       MaterialStateProperty.all(EdgeInsets.all(20)),
                          //   backgroundColor: MaterialStateProperty.all(
                          //       Colors.blue), // <-- Button color
                          //   overlayColor:
                          //       MaterialStateProperty.resolveWith<Color?>(
                          //           (states) {
                          //     if (states.contains(MaterialState.pressed))
                          //       return Colors.red; // <-- Splash color
                          //   }),
                          // ),
                        ),
                      )
                    ],
                  )));
          // RefreshIndicator(
          //     child: createTimeLine(), onRefresh: () => retrieveTimeline()));
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
