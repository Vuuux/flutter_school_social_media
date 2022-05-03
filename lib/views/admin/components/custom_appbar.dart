import 'package:flutter/material.dart';
import 'package:luanvanflutter/views/admin/components/profile_info.dart';
import 'package:luanvanflutter/views/admin/components/search_field.dart';
import 'package:luanvanflutter/views/admin/constants/constants.dart';
import 'package:luanvanflutter/views/admin/constants/responsive.dart';
import 'package:provider/provider.dart';

import '../controllers/controller.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            onPressed: context.read<Controller>().controlMenu,
            icon: Icon(
              Icons.menu,
              color: textColor.withOpacity(0.5),
            ),
          ),
        Expanded(child: SearchField()),
        ProfileInfo()
      ],
    );
  }
}
