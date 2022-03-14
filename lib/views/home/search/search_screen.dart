import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/authenticate/helper.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:luanvanflutter/views/home/search/components/search_tile.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class SearchScreen extends StatefulWidget {
  final String userId;

  const SearchScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? searchSnapshot;
  bool isLoading = false;
  bool haveUserSearched = false;
  late Stream chatsScreenStream;

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

  Widget searchResult() {
    return FutureBuilder<QuerySnapshot>(
        future: searchSnapshot,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  UserData user =
                      UserData.fromDocumentSnapshot(snapshot.data!.docs[index]);
                  return SearchTile(userData: user);
                });
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  getUserInfo() async {
    // print(Constants.myName);
    // DatabaseServices(uid: '').getAnonymousChatRooms(Constants.myEmail).then((val) {
    //   setState(() {
    //     chatsScreenStream = val;
    //   });
    // });
  }

  @override
  void initState() {
    getUserInfo();
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: Colors.grey)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
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
                            ),
                          ),
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
                    searchResult(),
                  ],
                ),
              ),
      ),
    );
  }
}
