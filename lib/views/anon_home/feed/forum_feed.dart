import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/forum.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/theme_service.dart';
import 'package:luanvanflutter/views/anon_home/feed/create_forum_screen.dart';
import 'package:luanvanflutter/views/anon_home/feed/forum_item.dart';
import 'package:luanvanflutter/views/components/chips/data/choice_chip_data.dart';
import 'package:luanvanflutter/views/components/chips/model/choice_chips.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:provider/provider.dart';

class AnonForumFeed extends StatefulWidget {
  const AnonForumFeed({Key? key}) : super(key: key);

  @override
  _AnonForumFeedState createState() => _AnonForumFeedState();
}

class _AnonForumFeedState extends State<AnonForumFeed> {
  Stream<QuerySnapshot>? forumsStream;
  final timelineReference = FirebaseFirestore.instance.collection('posts');
  ScrollController scrollController = ScrollController();
  Ctuer currentCtuer = Ctuer();
  final picker = ImagePicker();
  late Stream<QuerySnapshot> forumStream;
  bool isGrid = true;

  Widget forumList(CurrentUser currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: forumsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Expanded(
                child: isGrid
                    ? GridView.builder(
                        controller: scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = ForumModel.fromDocument(
                              snapshot.data!.docs[index]);

                          return ForumItem(forum: post);
                        },
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 0.9,
                          crossAxisCount: 2,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          String forumId =
                              snapshot.data!.docs[index].get('forumId');
                          String ownerId =
                              snapshot.data!.docs[index].get('ownerId');
                          String username =
                              snapshot.data!.docs[index].get('username');
                          String category =
                              snapshot.data!.docs[index].get('category');
                          String title =
                              snapshot.data!.docs[index].get('title');
                          String description =
                              snapshot.data!.docs[index].get('description');
                          Timestamp timestamp =
                              snapshot.data!.docs[index].get('timestamp');
                          String url =
                              snapshot.data!.docs[index].get('mediaUrl');
                          Map<String, dynamic> upVotes =
                              snapshot.data!.docs[index].get('upVotes');
                          Map<String, dynamic> downVotes =
                              snapshot.data!.docs[index].get('downVotes');
                          final post = ForumModel(
                              forumId: forumId,
                              ownerId: ownerId,
                              username: username,
                              title: title,
                              description: description,
                              mediaUrl: url,
                              upVotes: upVotes,
                              downVotes: downVotes,
                              timestamp: timestamp,
                              category: category);

                          return ForumItem(forum: post);
                        },
                      ),
              )
            : Container(
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
    forumsStream = Stream.fromFuture(DatabaseServices(uid: '').getForums());
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

  pickImageFromGallery(UserData userData) async {
    Navigator.pop(context);

    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxHeight: 680, maxWidth: 970);
    File imageFile = File(
      pickedFile!.path,
    );
    if (imageFile == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Wrapper()),
          ModalRoute.withName('Wrapper'));
    } else {
      final String result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CreateForum(file: imageFile, userData: userData),
        ),
      );

      if (result == "UPLOADED") {
        setState(() {
          forumsStream =
              Stream.fromFuture(DatabaseServices(uid: '').getForums());
        });
      }
    }
  }

  captureImageWithCamera(UserData userData) async {
    Navigator.pop(context);
    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
    File imageFile = File(pickedFile!.path);

    if (imageFile == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Wrapper()),
          ModalRoute.withName('Wrapper'));
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CreateForum(file: imageFile, userData: userData),
        ),
      );

      if (result == "UPLOADED") {
        setState(() {
          forumsStream =
              Stream.fromFuture(DatabaseServices(uid: '').getForums());
        });
      }
    }
  }

  List<ChoiceChipData> choiceChips = ChoiceChips.allOption;

  Widget buildChoiceChips() => Wrap(
        runSpacing: 5.0,
        spacing: 5.0,
        alignment: WrapAlignment.center,
        children: choiceChips
            .map((choiceChip) => ChoiceChip(
                  label: Text(choiceChip.label!),
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeService().isDarkTheme ? white : black),
                  onSelected: (isSelected) => setState(() {
                    choiceChips = choiceChips.map((otherChip) {
                      final newChip = otherChip.copy(isSelected: false);

                      return choiceChip == newChip
                          ? newChip.copy(isSelected: isSelected)
                          : newChip;
                    }).toList();

                    switch (choiceChip.label) {
                      case 'Hỏi đáp':
                        forumsStream = Stream.fromFuture(
                            DatabaseServices(uid: '')
                                .getForumsByCategory('questions'));
                        break;
                      case 'Học tập':
                        forumsStream = Stream.fromFuture(
                            DatabaseServices(uid: '')
                                .getForumsByCategory('studying'));
                        break;
                      case 'Tư vấn':
                        forumsStream = Stream.fromFuture(
                            DatabaseServices(uid: '')
                                .getForumsByCategory('advise'));
                        break;
                      case 'Thầm kín':
                        forumsStream = Stream.fromFuture(
                            DatabaseServices(uid: '')
                                .getForumsByCategory('secret'));
                        break;
                      case 'Hỗ trợ':
                        forumsStream = Stream.fromFuture(
                            DatabaseServices(uid: '')
                                .getForumsByCategory('support'));
                        break;
                      default:
                        forumsStream = Stream.fromFuture(
                            DatabaseServices(uid: '').getForums());
                        break;
                    }
                  }),
                  selected: choiceChip.isSelected,
                  selectedColor: ThemeService().isDarkTheme
                      ? kPrimaryDarkColor
                      : kPrimaryColor,
                  backgroundColor: kSelectedBackgroudColor,
                ))
            .toList(),
      );

  createForum(UserData userData) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Thêm diễn đàn mới"),
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
                title: const Text("D I Ễ N   Đ À N",
                    textAlign: TextAlign.right,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
                centerTitle: true,
                leading: IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: !isGrid
                        ? const Icon(Icons.grid_on)
                        : const Icon(Icons.table_rows_outlined),
                    onPressed: () {
                      setState(() {
                        isGrid = !isGrid;
                      });
                      ;
                    }),
                actions: <Widget>[
                  IconButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      icon: const Icon(Icons.image),
                      onPressed: () {
                        createForum(userData!);
                      }),
                ],
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(child: Center(child: buildChoiceChips())),
                  forumList(user)
                ],
              ));
          // RefreshIndicator(
          //     child: createTimeLine(), onRefresh: () => retrieveTimeline()));
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
