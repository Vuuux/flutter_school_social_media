
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'feed.dart';

class CommentsPage extends StatefulWidget {
  final String description;
  final Ctuer ctuer;

  CommentsPage({required this.description, required this.ctuer});
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("B Ì N H   L U Ậ N",
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100)),
        leading: IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            icon: const Icon(LineAwesomeIcons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, top: 15),
        child: Text(
          widget.description,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
    // RefreshIndicator(
    //     child: createTimeLine(), onRefresh: () => retrieveTimeline()));
  }
}
