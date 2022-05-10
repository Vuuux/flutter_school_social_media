import 'package:luanvanflutter/views/admin/constants/constants.dart';
import 'package:luanvanflutter/views/admin/models/analytic_info_model.dart';
import 'package:luanvanflutter/views/admin/models/discussions_info_model.dart';
import 'package:luanvanflutter/views/admin/models/referal_info_model.dart';

List analyticData = [
  AnalyticInfo(
    title: "Người dùng",
    count: 15,
    svgSrc: "assets/icons/Subscribers.svg",
    color: primaryColor,
  ),
  AnalyticInfo(
    title: "Bài viết",
    count: 18,
    svgSrc: "assets/icons/Post.svg",
    color: purple,
  ),
  AnalyticInfo(
    title: "Báo cáo",
    count: 2,
    svgSrc: "assets/icons/Pages.svg",
    color: orange,
  ),
  AnalyticInfo(
    title: "Bình luận",
    count: 8,
    svgSrc: "assets/icons/Comments.svg",
    color: green,
  ),
];

List discussionData = [
  DiscussionInfoModel(
    imageSrc: "assets/images/student1.png",
    name: "Loc",
    date: "Jan 25,2021",
  ),
  DiscussionInfoModel(
    imageSrc: "assets/images/student2.png",
    name: "Huynh Thi Hai Yen",
    date: "Mar 25,2022",
  ),
  DiscussionInfoModel(
    imageSrc: "assets/images/student3.png",
    name: "Linh",
    date: "Jul 25,2021",
  ),
  DiscussionInfoModel(
    imageSrc: "assets/images/student6.png",
    name: "Vo Binh Tho",
    date: "Aug 25,2021",
  ),
  DiscussionInfoModel(
    imageSrc: "assets/images/student2.png",
    name: "Nguyen Chi Linh",
    date: "Jan 12,2022",
  ),
  DiscussionInfoModel(
    imageSrc: "assets/images/student3.png",
    name: "Thu",
    date: "Jan 23,2022",
  ),
  DiscussionInfoModel(
    imageSrc: "assets/images/student8.png",
    name: "Nguyen Thi Thuy Vy",
    date: "Jan 21,2022",
  ),
  DiscussionInfoModel(
    imageSrc: "assets/images/student7.png",
    name: "Vo Nhat Tri",
    date: "June 30,2022",
  ),
];

List referalData = [
  ReferalInfoModel(
    title: "Facebook",
    count: 0,
    svgSrc: "assets/icons/Facebook.svg",
    color: primaryColor,
  ),
  ReferalInfoModel(
    title: "Twitter",
    count: 0,
    svgSrc: "assets/icons/Twitter.svg",
    color: primaryColor,
  ),
  ReferalInfoModel(
    title: "Linkedin",
    count: 0,
    svgSrc: "assets/icons/Linkedin.svg",
    color: primaryColor,
  ),
  ReferalInfoModel(
    title: "Dribble",
    count: 0,
    svgSrc: "assets/icons/Dribbble.svg",
    color: red,
  ),
];
