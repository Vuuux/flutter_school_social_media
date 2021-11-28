import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/anon_home/profile/others_anon_profile.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:provider/src/provider.dart';

class AnonSimpleSearch extends StatefulWidget {
  AnonSimpleSearch({Key? key}) : super(key: key);
  CurrentUser? currentUserData;
  @override
  _AnonSimpleSearchState createState() => _AnonSimpleSearchState();
}

class _AnonSimpleSearchState extends State<AnonSimpleSearch> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users = DatabaseServices(uid: '').ctuerRef
        .where("username", isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Nhập tên ctuer bạn muốn tìm...",
          filled: true,
          prefixIcon: const Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            const Text(
              "Tìm Ctuer",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        }
        List<UserResult> searchResults = [];
        snapshot.data!.docs.forEach((doc) {
          UserData user = UserData.fromDocumentSnapshot(doc);
          if(user.id != widget.currentUserData!.uid){
            searchResults.add(UserResult(user: user));
          }
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.currentUserData = context.watch<CurrentUser?>();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:
      searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final UserData user;

  const UserResult({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child:
      Column(
        children: <Widget>[
          GestureDetector(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.avatar),
                backgroundColor: kPrimaryColor,
              ),
              title: Text(user.username,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),),
              subtitle: Text(user.username, style: const TextStyle(
                color: kPrimaryColor,
              ),),
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)
            => OthersAnonProfile(ctuerId: user.id))),
          ),
          const Divider(height: 2.0,
          )
        ],
      ),
    );
  }
}