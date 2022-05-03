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
import 'package:luanvanflutter/controller/post_controller.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/components/app_bar/custom_sliver_app_bar.dart';
import 'package:luanvanflutter/views/components/buttons/ripple_animation.dart';
import 'package:luanvanflutter/views/components/dialog/custom_dialog.dart';
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
  final _postController = Get.put(PostController());
  final timelineReference = FirebaseFirestore.instance.collection('posts');
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  late CurrentUserId currentUser;
  final picker = ImagePicker(); //API chọn hình ảnh
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<QuerySnapshot>? postFuture;
  //lấy time từ post
  _handleSearch(String query) {
    _postController.searchPost(query);
  }

  clearSearch() {
    searchController.clear();
  }

  Widget _buildPostList() => Obx(
        () {
          return ListView.separated(
            shrinkWrap: true,
            controller: scrollController,
            itemCount: _postController.postList.length,
            itemBuilder: (context, index) {
              final PostModel post = _postController.postList[index];
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
        },
      );

  Widget postList(CurrentUserId currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: Stream.fromFuture(postFuture!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<PostModel> listPost = snapshot.data!.docs
              .map((doc) => PostModel.fromDocumentSnapshot(doc))
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
    currentUser = CurrentUserId(uid: userId);
    _postController.getPosts();
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
      await Get.to(() => UploadImage(file: imageFile, userData: userData));
      _postController.getPosts();
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
      await Get.to(() => UploadImage(file: imageFile, userData: userData));
      _postController.getPosts();
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
    CurrentUserId? user = context.watch<CurrentUserId?>();
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
                                onTrailingClick: () async {
                                  await takeImage(userData!);
                                }),
                          ],
                  body: Stack(
                    children: [
                      Obx(() => _postController.requestStatus.value ==
                              RequestStatus.LOADING
                          ? Loading()
                          : RefreshIndicator(
                              onRefresh: () async {
                                await _postController.getPosts();
                                return;
                              },
                              child: _buildPostList())).paddingOnly(top: 55),
                      CustomSearchBar(
                        onSearchSubmit: (query) => _handleSearch(query),
                        onTapCancel: () => _postController.getPosts(),
                        searchController: searchController,
                        hintText: 'Tìm kiếm bài viết...',
                      ),
                      //Obx(() => _postController.requestStatus.value == RequestStatus.LOADING ? Loading() : _buildPostList()),
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
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
