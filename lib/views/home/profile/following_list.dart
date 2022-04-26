import 'package:flutter/cupertino.dart';
import 'package:luanvanflutter/models/user.dart';

class FollowingList extends StatefulWidget {
  final List<UserData> ctuerList;
  final UserData user;
  const FollowingList({Key? key, required this.ctuerList, required this.user})
      : super(key: key);

  @override
  _FollowingListState createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
