import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/views/admin/constants/constants.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostInfoDetail extends StatelessWidget {
  const PostInfoDetail(
      {Key? key, required this.postInfo, required this.onTapMore})
      : super(key: key);

  final PostModel postInfo;
  final Function onTapMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: postInfo.isVideo
              ? Container(
                  child: Icon(Icons.play_circle),
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(color: Colors.black12),
                )
              : CachedNetworkImage(
                  imageUrl: postInfo.url[0],
                  height: 38,
                  width: 38,
                  fit: BoxFit.cover,
                ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: appPadding, vertical: Dimen.paddingCommon10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postInfo.description,
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Người đăng: " + postInfo.username,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                Text(
                  postInfo.location +
                      ' - ' +
                      timeago.format(postInfo.timestamp.toDate(), locale: "vi"),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onTapMore();
          },
          child: Icon(
            Icons.more_vert_rounded,
            color: textColor.withOpacity(0.5),
            size: 18,
          ),
        )
      ],
    );
  }
}
