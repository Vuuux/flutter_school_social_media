import 'package:flutter/cupertino.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';

class FollowerList extends StatefulWidget {
  final List<Ctuer> ctuerList;
  final UserData user;
  const FollowerList({Key? key, required this.ctuerList, required this.user}) : super(key: key);

  @override
  _FollowerListState createState() => _FollowerListState();
}

class _FollowerListState extends State<FollowerList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
