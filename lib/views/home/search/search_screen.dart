import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventual/eventual-notifier.dart';
import 'package:eventual/eventual-single-builder.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/chat_utils.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/helper.dart';
import 'package:luanvanflutter/utils/widget_extensions.dart';
import 'package:luanvanflutter/views/components/buttons/bottom_sheet_button.dart';
import 'package:luanvanflutter/views/home/chat/conversation_screen.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:luanvanflutter/views/home/search/components/search_tile.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class SearchScreen extends StatefulWidget {
  final String userId;
  final bool isMultipleSelect;
  const SearchScreen(
      {Key? key, required this.userId, this.isMultipleSelect = false})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchTextEditingController = TextEditingController();
  final MultiSelectController<UserData> _controller = MultiSelectController();
  Future<QuerySnapshot>? searchSnapshot;
  bool isLoading = false;
  bool haveUserSearched = false;
  late Stream chatsScreenStream;
  EventualNotifier<List<UserData>> _selectedUser =
      EventualNotifier<List<UserData>>([]);
  initiateSearch() async {
    if (searchTextEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      Future<QuerySnapshot> users = DatabaseServices(uid: '')
          .userReference
          .where("username",
              isGreaterThanOrEqualTo: searchTextEditingController.text)
          .get();
      setState(() {
        searchSnapshot = users;
        isLoading = false;
        haveUserSearched = true;
      });

      // await DatabaseServices(uid: '')
      //     .getUserByUsername(searchTextEditingController.text)
      //     .then((val) {
      //   searchSnapshot = val;
      //   setState(() {
      //     isLoading = false;
      //     haveUserSearched = true;
      //   });
      // });
    }
  }

  Widget getChild(UserData user) {
    return SearchTile(ctuer: user);
  }

  Widget searchResult() {
    return FutureBuilder<QuerySnapshot>(
        future: searchSnapshot,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }
          if (snapshot.hasData) {
            List<UserData> _users = snapshot.data!.docs
                .map((user) => UserData.fromDocumentSnapshot(user))
                .toList();
            _users.removeWhere((element) => widget.userId == element.id);
            return MultiSelectContainer<UserData>(
              showInListView: true,
              listViewSettings: ListViewSettings(
                  shrinkWrap: true,
                  separatorBuilder: (_, __) => const SizedBox(
                        width: 10,
                      )),
              controller: _controller,
              items: _users
                  .map((user) =>
                      MultiSelectCard(value: user, child: getChild(user)))
                  .toList(),
              itemsPadding: const EdgeInsets.all(5),
              itemsDecoration: MultiSelectDecorations(
                decoration:
                    BoxDecoration(color: Colors.indigo.withOpacity(0.1)),
                selectedDecoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [kPrimaryColor, kPrimaryDarkColor]),
                ),
              ),
              onChange: (selectedItems, selectedItem) {
                _selectedUser.value = selectedItems;
              },
              onMaximumSelected: (allSelectedItems, selectedItem) {
                Get.snackbar(
                    "Quá nhiều người!", "Bạn đã chọn quá số người cho phép!");
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  createChatRoomAndStartConversation(
      BuildContext context, String uid, UserData userData) async {
    List<String> chatRoomID =
        ChatUtils.createChatRoomIdFromUserId(uid, userData.id);
    String existedChatRoomId =
        await DatabaseServices(uid: uid).checkIfChatRoomExisted(chatRoomID);
    bool isChatRoomExisted = existedChatRoomId.isEmpty ? false : true;
    String resultChatRoomId =
        isChatRoomExisted ? existedChatRoomId : chatRoomID[0];

    List<String> users = [uid, userData.id];

    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomId": resultChatRoomId,
      "timestamp": Timestamp.now(),
    };

    if (!isChatRoomExisted) {
      await DatabaseServices(uid: uid)
          .createChatRoom(resultChatRoomId, chatRoomMap);
      Get.to(() => ConversationScreen(
          chatRoomId: resultChatRoomId, ctuer: userData, userId: uid));
    } else {
      Get.to(() => ConversationScreen(
          chatRoomId: existedChatRoomId, ctuer: userData, userId: uid));
    }
  }

  _onTapContinue() async {
    if (_selectedUser.value.length == 1) {
      await createChatRoomAndStartConversation(
          context, widget.userId, _selectedUser.value[0]);
    } else {}
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          )),
          leading: IconButton(
              icon: const Icon(LineAwesomeIcons.home),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
              }),
          centerTitle: true,
          title: const Text("T Ì M   B Ạ N",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
        ),
        body: isLoading
            ? Center(child: Loading())
            : Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.grey)),
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimen.paddingCommon20,
                        vertical: Dimen.paddingCommon10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                          controller: searchTextEditingController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                              hintText: "Tìm ctuer qua tên...",
                              hintStyle: TextStyle(color: Colors.black),
                              border: InputBorder.none),
                        )),
                        GestureDetector(
                          onTap: () {
                            initiateSearch();
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            padding: const EdgeInsets.all(12),
                            child:
                                Image.asset("assets/images/search_white.png"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  searchResult().expand(),
                  EventualSingleBuilder(
                    notifier: _selectedUser,
                    builder: (context, notifier, _) {
                      List<UserData> result = notifier.value;
                      return BottomSheetButton(
                              label: "Tiếp tục" +
                                  (result.isNotEmpty
                                      ? "(${notifier.value.length})"
                                      : ""),
                              color: notifier.value.length <= 0
                                  ? Colors.grey
                                  : Get.isDarkMode
                                      ? kPrimaryDarkColor
                                      : kPrimaryColor,
                              textColor:
                                  Get.isDarkMode ? Colors.black : Colors.white,
                              onTap: result.isNotEmpty ? _onTapContinue : () {})
                          .marginOnly(top: Dimen.paddingCommon10);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
