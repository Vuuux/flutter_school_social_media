import 'package:flutter/material.dart';
import 'package:luanvanflutter/views/home/feed/post_screen.dart';

class PostDetail extends StatefulWidget {
  final PostItem post;
  const PostDetail({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: widget.post));
  }
}
