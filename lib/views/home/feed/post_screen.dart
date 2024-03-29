import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/controller/post_controller.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/utils/widget_extensions.dart';
import 'package:luanvanflutter/views/components/aspect_video_player.dart';
import 'package:luanvanflutter/views/components/buttons/bottom_sheet_button.dart';
import 'package:luanvanflutter/views/components/rounded_input_field.dart';
import 'package:luanvanflutter/views/home/feed/post_detail.dart';
import 'package:provider/src/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';
import '../../../style/constants.dart';
import 'comment_screen.dart';

enum PlayerState { IDLE, PLAYING, PAUSED }

class PostItem extends StatefulWidget {
  final PostModel post;
  bool isLiked = false;

  PostItem({Key? key, required this.post}) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late UserData currentUser;
  TextEditingController _reasonController = TextEditingController();
  PostController _postController = Get.put(PostController());

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
    _videoController = VideoPlayerController.network(widget.post.url[0])
      ..initialize().then((_) {
        setState(() {});
      });
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    timeago.setLocaleMessages('vi_short', timeago.ViShortMessages());
    for (var val in widget.post.likes.values) {
      if (val == true) {
        likeCount += 1;
      }
    }
  }

  getCurrentUserData() async {
    currentUser = UserDataService().getUserData()!;
    return;
  }

  buildPostHeader(String uid, BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: DatabaseServices(uid: uid)
          .userReference
          .doc(widget.post.ownerId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData user = UserData.fromDocumentSnapshot(snapshot.data!);
          return ListTile(
            leading: CircleAvatar(
              child: ClipOval(
                child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Image.network(
                      user.avatar,
                      fit: BoxFit.fill,
                    )),
              ),
              //CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostDetail(
                      postId: widget.post.postId, ownerId: user.id))),
              child: Text(
                user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(widget.post.location +
                ' - ' +
                timeago.format(widget.post.timestamp.toDate(), locale: "vi")),
            trailing: IconButton(
              onPressed: () => onOpenPostOption(context),
              icon: const Icon(Icons.more_vert),
            ),
          );
        }
        return Loading();
      },
    );
  }

  onOpenPostOption(BuildContext nContext) {
    return currentUser.id == widget.post.ownerId
        ? showDialog(
            context: nContext,
            builder: (context) {
              return SimpleDialog(
                children: <Widget>[
                  SimpleDialogOption(
                      child: const Text(
                        "Xóa bài viết",
                      ),
                      onPressed: () async {
                        await DatabaseServices(uid: '').deletePost(
                            widget.post.postId, widget.post.ownerId);
                        _postController.getPosts();
                        Get.back();
                      }),
                  SimpleDialogOption(
                    child: const Text(
                      "Đóng",
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  )
                ],
              );
            })
        : showDialog(
            context: nContext,
            builder: (context) {
              return SimpleDialog(
                children: <Widget>[
                  SimpleDialogOption(
                      child: const Text(
                        "Báo cáo bài viết",
                      ),
                      onPressed: () async {
                        await Get.bottomSheet(Container(
                          padding: const EdgeInsets.only(top: 4),
                          height: MediaQuery.of(context).size.height * 0.40,
                          color: Get.isDarkMode ? darkGreyColor : Colors.white,
                          child: Column(
                            children: [
                              Container(
                                height: 6,
                                width: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Get.isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey[300]),
                              ),
                              RoundedInputField(
                                hintText: "Nhập lý do báo cáo bài viết này",
                                title: "Lý do báo cáo",
                                controller: _reasonController,
                              )
                                  .paddingSymmetric(
                                      horizontal: Dimen.paddingCommon15)
                                  .expand(),
                              BottomSheetButton(
                                  label: "Xác nhận",
                                  color: Get.isDarkMode
                                      ? kPrimaryDarkColor
                                      : kPrimaryColor,
                                  onTap: () async {
                                    await _validateReport();
                                    Get.back();
                                  }),
                              BottomSheetButton(
                                  label: "Đóng",
                                  color: Colors.white,
                                  isClose: true,
                                  onTap: () {
                                    Get.back();
                                  }),
                            ],
                          ),
                        ));
                      }),
                  SimpleDialogOption(
                    child: const Text(
                      "Đóng",
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  )
                ],
              );
            });
  }

  _validateReport() {
    if (_reasonController.text.isEmpty) {
      Get.defaultDialog(
          title: "Lỗi", middleText: "Vui lòng nhập lý do báo cáo bài viết");
    } else {
      DatabaseServices(uid: '').reportPost(widget.post, _reasonController.text);
      Get.defaultDialog(
          title: "Báo cáo thành công",
          middleText:
              "Cảm ơn bạn đã báo cáo, bài viết này sẽ được quản trị viên kiểm duyệt");
      Get.back();
    }
  }

  _buildPostImage() {
    return GestureDetector(
      onDoubleTap: () =>
          handleLikePost(widget.post.ownerId, widget.post.postId),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          widget.post.isVideo
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        playerState = PlayerState.PAUSED;
                        _videoController!.pause();
                      } else {
                        playerState = PlayerState.PLAYING;
                        _videoController!.play();
                      }

                      Timer(const Duration(milliseconds: 1000), () {
                        setState(() {
                          playerState = PlayerState.IDLE;
                        });
                      });
                    });
                  },
                  child: AspectRatioVideo(_videoController),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 400,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: false,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: widget.post.url.map((link) {
                        return Builder(
                          builder: (BuildContext context) {
                            return CachedNetworkImage(
                                imageUrl: link, width: Get.width);
                          },
                        );
                      }).toList(),
                    ),
                  )),
          showHeart
              ? Animator(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, anim, child) => Transform.scale(
                        scale: anim.animation.value as double,
                        child: const Icon(
                          Icons.favorite,
                          size: 80,
                          color: Colors.red,
                        ),
                      ))
              : const SizedBox.shrink(),
          if (playerState == PlayerState.PLAYING)
            Animator(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.8, end: 1.4),
                curve: Curves.elasticOut,
                cycles: 0,
                builder: (context, anim, child) => Transform.scale(
                      scale: anim.animation.value as double,
                      child: const Icon(
                        Icons.play_arrow,
                        size: 80,
                        color: Colors.white60,
                      ),
                    )),
          if (playerState == PlayerState.PAUSED)
            Animator(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.8, end: 1.4),
                curve: Curves.elasticOut,
                cycles: 0,
                builder: (context, anim, child) => Transform.scale(
                      scale: anim.animation.value as double,
                      child: const Icon(
                        Icons.pause,
                        size: 80,
                        color: Colors.white60,
                      ),
                    )),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        const Padding(padding: EdgeInsets.only(top: 10)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                widget.post.username + "  ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(widget.post.description))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () =>
                  handleLikePost(widget.post.ownerId, widget.post.postId),
              child: widget.isLiked
                  ? const Icon(
                      Icons.favorite,
                      size: 28.0,
                      color: Colors.pink,
                    )
                  : const Icon(
                      Icons.favorite_border,
                      size: 28.0,
                      color: Colors.pink,
                    ),
            ),
            const Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShowComments(
                          context: context,
                          postId: widget.post.postId,
                          ownerId: widget.post.ownerId,
                          //TODO: EDIT TO LIST IMAGE
                          mediaUrl: widget.post.url[0]))),
              child: Icon(
                Icons.sms_outlined,
                size: 28.0,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount lượt thích",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  CurrentUserId? user;
  int likeCount = 0;
  bool showHeart = false;
  PlayerState playerState = PlayerState.IDLE;

  @override
  Widget build(BuildContext context) {
    user = context.watch<CurrentUserId?>();
    widget.isLiked = (widget.post.likes[user!.uid] == true);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildPostHeader(user!.uid, context),
          SizedBox(
            height: Dimen.paddingCommon4,
          ),
          _buildPostImage(),
          buildPostFooter()
        ],
      ),
    );
  }

  handleLikePost(String ownerId, String postId) {
    bool _isLiked = (widget.post.likes[user!.uid] == true);

    if (_isLiked) {
      DatabaseServices(uid: user!.uid)
          .unlikePost(user!.uid, ownerId, postId)
          .then((value) {
        setState(() {
          likeCount -= 1;
          widget.post.likes[user!.uid] = false;
        });
      });
      if (currentUser.id != widget.post.ownerId) {
        DatabaseServices(uid: user!.uid)
            .removeLikeNotifications(ownerId, postId);
      }
    } else if (!_isLiked) {
      DatabaseServices(uid: user!.uid)
          .likePost(user!.uid, ownerId, postId)
          .then((value) {
        setState(() {
          likeCount += 1;
          widget.isLiked = true;
          widget.post.likes[user!.uid] = true;
          showHeart = true;
        });
      });

      if (currentUser.id != widget.post.ownerId) {
        DatabaseServices(uid: user!.uid).addLikeNotifications(
            ownerId,
            currentUser.username,
            user!.uid,
            currentUser.avatar,
            postId,
            widget.post.url[0],
            Timestamp.now());
      }
    }
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        showHeart = false;
      });
    });
  }

  buildCommentPage() {
    return ShowComments(
        context: context,
        postId: widget.post.postId,
        ownerId: widget.post.ownerId,
        mediaUrl: widget.post.url[0]);
  }
}
