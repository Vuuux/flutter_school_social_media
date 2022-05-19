import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/report.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/views/admin/constants/constants.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReportInfoDetail extends StatelessWidget {
  const ReportInfoDetail(
      {Key? key, required this.reportInfo, required this.onTapMore})
      : super(key: key);

  final ReportModel reportInfo;
  final Function onTapMore;

  String _getReportStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.PENDING:
        return "Chưa xử lý";
      case ReportStatus.APPROVED:
        return "Đã thông qua";
      default:
        return "Đã xóa";
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.PENDING:
        return Colors.blue;
      case ReportStatus.APPROVED:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: reportInfo.isVideo
              ? Container(
                  child: Icon(Icons.play_circle),
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(color: Colors.black12),
                )
              : CachedNetworkImage(
                  imageUrl: reportInfo.media[0],
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Lý do: " + reportInfo.reason,
                      style: const TextStyle(
                          color: textColor, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      _getReportStatus(reportInfo.status),
                      style: TextStyle(
                          color: _getStatusColor(reportInfo.status),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  "Người đăng: " + reportInfo.ownerName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                Text(
                  timeago.format(reportInfo.timestamp.toDate(), locale: "vi"),
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
