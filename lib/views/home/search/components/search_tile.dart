import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/views/home/profile/others_profile.dart';
import 'package:provider/src/provider.dart';

class SearchTile extends StatelessWidget {
  final UserData ctuer;

  const SearchTile({Key? key, required this.ctuer}) : super(key: key);

  Widget buildSearchTile(BuildContext context, String uid) {
    if (uid != ctuer.id) {
      return Container(
        width: Get.width * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: ListTile(
          leading: ClipOval(
            child: SizedBox(
              width: 32,
              height: 32,
              child: ctuer.avatar.isNotEmpty
                  ? Image.network(
                      ctuer.avatar,
                      fit: BoxFit.fill,
                    )
                  : Image.asset('assets/images/profile1.png', fit: BoxFit.fill),
            ),
          ),
          title: Text(
            ctuer.username,
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            ctuer.major + " K${ctuer.course}",
          ),
          trailing: GestureDetector(
            onTap: () {
              Get.to(() => OthersProfile(ctuerId: ctuer.id));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor,
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                'Thông tin',
                style: TextStyle(
                    color: Get.isDarkMode ? Colors.black : Colors.white),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    return buildSearchTile(context, user!.uid);
  }
}
