import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventual/eventual-notifier.dart';
import 'package:eventual/eventual-single-builder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/chat_room.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/chat_utils.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/helper.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/utils/widget_extensions.dart';
import 'package:luanvanflutter/views/components/buttons/bottom_sheet_button.dart';
import 'package:luanvanflutter/views/home/chat/conversation_screen.dart';
import 'package:luanvanflutter/views/home/chat/group_conversation_screen.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:luanvanflutter/views/home/search/components/search_tile.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

class SearchScreen extends StatefulWidget {
  final String userId;
  final bool isMultipleSelect;
  final bool isFromChatScreen;
  final bool isAddExtraUser;
  final String? chatRoomId;
  final List<String>? memberIdList;
  final Function(String id)? onMemberCallback;

  const SearchScreen(
      {Key? key,
      required this.userId,
      this.isMultipleSelect = false,
      this.isFromChatScreen = false,
      this.isAddExtraUser = false,
      this.chatRoomId,
      this.memberIdList,
      this.onMemberCallback})
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
  String groupName = "";
  EventualNotifier<List<UserData>> _selectedUser =
      EventualNotifier<List<UserData>>([]);
  TextEditingController groupNameController = TextEditingController();

  _initiateSearch() async {
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
    } else {
      setState(() {
        isLoading = true;
      });

      Future<QuerySnapshot> users =
          DatabaseServices(uid: '').userReference.get();
      setState(() {
        searchSnapshot = users;
        isLoading = false;
        haveUserSearched = true;
      });
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
            if (widget.memberIdList != null &&
                widget.memberIdList!.length > 0) {
              widget.memberIdList!.forEach((memberId) {
                _users.removeWhere((element) => element.id == memberId);
              });
            }
            _users.removeWhere((element) => widget.userId == element.id);
            return MultiSelectContainer<UserData>(
              singleSelectedItem: !widget.isMultipleSelect,
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
                selectedItems.forEach((user) {
                  groupName += user.username;
                });
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
      "isGroup": false,
      "ownerId": "",
      "chatRoomId": resultChatRoomId,
      "timestamp": Timestamp.now(),
    };

    if (!isChatRoomExisted) {
      await DatabaseServices(uid: uid)
          .createChatRoom(resultChatRoomId, chatRoomMap);
      Get.back();
      Get.to(() => ConversationScreen(
          chatRoomId: resultChatRoomId, ctuer: userData, userId: uid));
    } else {
      Get.to(() => ConversationScreen(
          chatRoomId: existedChatRoomId, ctuer: userData, userId: uid));
    }
  }

  createGroupChatRoomAndStartConversation(
      BuildContext context, String uid, List<UserData> userData) async {
    String resultChatRoomId = Uuid().v4();

    List<String> users = [uid, ...userData.map((e) => e.id).toList()];
    String userAvatar = UserDataService().getUserData()!.avatar;
    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomId": resultChatRoomId,
      "isGroup": true,
      "groupAvatar": userAvatar,
      "groupName": groupName,
      "ownerId": uid,
      "timestamp": Timestamp.now(),
    };

    await DatabaseServices(uid: uid)
        .createChatRoom(resultChatRoomId, chatRoomMap);

    Get.back();
  }

  _onTapContinue() async {
    if (_selectedUser.value.length == 1 &&
        !widget.isMultipleSelect &&
        !widget.isAddExtraUser) {
      await createChatRoomAndStartConversation(
          context, widget.userId, _selectedUser.value[0]);
    } else if (widget.isAddExtraUser &&
        widget.chatRoomId != null &&
        widget.onMemberCallback != null) {
      await DatabaseServices(uid: widget.userId)
          .addUserToChatRoom(widget.chatRoomId!, _selectedUser.value[0].id);
      widget.onMemberCallback!(_selectedUser.value[0].id);
      Get.back();
    } else {
      Get.defaultDialog(
          title: '',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groupNameController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: InputDecoration(
                    labelText: 'Tên nhóm',
                    hintMaxLines: 1,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Get.isDarkMode
                                ? kPrimaryDarkColor
                                : kPrimaryColor,
                            width: 4.0))),
              ),
              SizedBox(
                height: 30.0,
              ),
              BottomSheetButton(
                onTap: () async {
                  if (groupNameController.text.isNotEmpty) {
                    groupName = groupNameController.text;
                    await createGroupChatRoomAndStartConversation(
                        context, widget.userId, _selectedUser.value);
                    Get.back();
                  } else {
                    Get.snackbar("Bắt buộc", "Vui lòng nhập tên nhóm");
                  }
                },
                label: 'Tạo nhóm',
                color: Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor,
              )
            ],
          ),
          radius: 10.0);
    }
  }

  @override
  void initState() {
    super.initState();
    _initiateSearch();
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
                          onChanged: (value) {
                            _initiateSearch();
                          },
                          controller: searchTextEditingController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                              hintText: "Tìm ctuer qua tên...",
                              hintStyle: TextStyle(color: Colors.black),
                              border: InputBorder.none),
                        )),
                        GestureDetector(
                          onTap: () {
                            _initiateSearch();
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
                  if (widget.isFromChatScreen)
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
                                textColor: Get.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                                onTap:
                                    result.isNotEmpty ? _onTapContinue : () {})
                            .marginOnly(top: Dimen.paddingCommon10);
                      },
                    ),
                ],
              ),
      ),
    );
  }
}
