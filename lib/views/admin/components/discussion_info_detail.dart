import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/admin/constants/constants.dart';
import 'package:luanvanflutter/views/admin/models/discussions_info_model.dart';
import 'package:luanvanflutter/views/components/buttons/bottom_sheet_button.dart';
import 'package:luanvanflutter/views/home/feed/components/custom_snackbar.dart';

class DiscussionInfoDetail extends StatelessWidget {
  const DiscussionInfoDetail(
      {Key? key, required this.info, required this.onTapMore})
      : super(key: key);

  final UserData info;
  final Function onTapMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: appPadding),
      padding: EdgeInsets.all(appPadding / 2),
      color: info.enabled ? null : Colors.black12,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: CachedNetworkImage(
              imageUrl: info.avatar,
              height: 38,
              width: 38,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: appPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.username,
                    style: TextStyle(
                        color: info.enabled ? textColor : disabledTextColor,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    info.major,
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
      ),
    );
  }
}
