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
import 'package:luanvanflutter/views/components/aspect_video_player.dart';
import 'package:luanvanflutter/views/components/buttons/ripple_animation.dart';
import 'package:luanvanflutter/views/components/dialog/custom_dialog.dart';
import 'package:luanvanflutter/views/components/search_bar.dart';
import 'package:luanvanflutter/views/home/feed/post_screen.dart';
import 'package:luanvanflutter/views/home/feed/post_review_screen.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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
  final _picker = ImagePicker(); //API chọn hình ảnh
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<QuerySnapshot>? postFuture;
  List<XFile>? _imageFileList;
  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  bool isVideo = false;
  String? _retrieveDataError;

  @override
  void initState() {
    super.initState();
    String userId = auth.currentUser!.uid;
    currentUser = CurrentUserId(uid: userId);
    Future.delayed(Duration.zero, () {
      _postController.getPosts();
    });
  }

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

  circularProgress() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 12),
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.redAccent),
      ),
    );
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context,
      bool isMultiImage = false,
      required UserData userData}) async {
    if (isVideo) {
      final XFile? file = await _picker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      if (file != null) {
        await Get.to(() => PreviewPostScreen(
            files: [file],
            userData: userData,
            isVideo: true,
            isMultipleImage: false));
        _postController.getPosts();
      }
    } else if (isMultiImage) {
      try {
        final List<XFile>? pickedFileList = await _picker.pickMultiImage(
          maxWidth: 680,
          maxHeight: 970,
          imageQuality: 50,
        );
        setState(() {
          _imageFileList = pickedFileList;
        });
        if (pickedFileList != null) {
          await Get.to(() => PreviewPostScreen(
                files: pickedFileList,
                userData: userData,
                isVideo: false,
                isMultipleImage: true,
              ));
          _postController.getPosts();
        }
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    } else {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 680,
          maxHeight: 970,
          imageQuality: 50,
        );
        setState(() {
          _setImageFileListFromFile(pickedFile);
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  // _pickVideo() async {
  //   XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
  //   File _video = File(pickedFile!.path);
  //   _videoPlayerController = VideoPlayerController.file(_video)
  //     ..initialize().then((_) {
  //       setState(() {});
  //       _videoPlayerController.play();
  //     });
  // }

  //lấy ảnh từ thư viện
  _pickImageFromGallery(UserData userData) async {
    Navigator.pop(context);

    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxHeight: 680, maxWidth: 970);
    File imageFile = File(
      pickedFile!.path,
    );
    if (pickedFile == null) {
    } else {
      await Get.to(
          () => PreviewPostScreen(files: [pickedFile], userData: userData));
      _postController.getPosts();
    }
  }

  _captureImageWithCamera(UserData userData) async {
    Navigator.pop(context);
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
    File imageFile = File(pickedFile!.path);

    if (pickedFile == null) {
      // Navigator.of(context).pushAndRemoveUntil(
      //     FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
    } else {
      await Get.to(
          () => PreviewPostScreen(files: [pickedFile], userData: userData));
      _postController.getPosts();
    }
  }

  _takeImage(UserData userData) {
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
                onPressed: () {
                  isVideo = false;
                  _captureImageWithCamera(userData);
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  "Chọn ảnh từ thư viện",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  isVideo = false;
                  _onImageButtonPressed(ImageSource.gallery,
                      context: context, isMultiImage: true, userData: userData);
                },
                //onPressed: () => _pickImageFromGallery(userData),
              ),
              SimpleDialogOption(
                child: const Text(
                  "Chọn video từ thư viện",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  isVideo = true;
                  _onImageButtonPressed(ImageSource.gallery,
                      userData: userData);
                },
              ),
              SimpleDialogOption(
                child: const Text(
                  "Quay video",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  isVideo = true;
                  _onImageButtonPressed(ImageSource.camera, userData: userData);
                },
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
    return StreamBuilder<UserData?>(
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
                                  await _takeImage(userData!);
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
                            Get.dialog(const CustomDialog(
                              title: 'Đi kết bạn nào!',
                              description:
                                  'Hôm nay bạn sẽ kết bạn với Hmmie nào đây?',
                              buttonText: 'Tìm hiểu',
                            ));
                          },
                          size: 20.0,
                          color: kPrimaryDarkColor,
                          child: Icon(Icons.face),
                        ),
                      )
                    ],
                  )));
        });
  }

  @override
  void dispose() {
    Get.delete<PostController>();
    super.dispose();
  }
}
