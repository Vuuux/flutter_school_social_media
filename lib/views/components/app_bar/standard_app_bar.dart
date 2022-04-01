import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/theme_service.dart';

class StandardAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final bool enableBack;
  final Function()? onLeadingClick;
  final Function()? onTrailingClick;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? background;

  const StandardAppBar(
      {Key? key,
      required this.title,
      this.enableBack = false,
      this.onLeadingClick,
      this.onTrailingClick,
      this.leadingIcon,
      this.trailingIcon,
      this.background})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(15),
      )),
      title: Text(title),
      centerTitle: true,
      leading: GestureDetector(
        onTap: onLeadingClick,
        child: enableBack
            ? const Icon(Icons.arrow_back)
            : leadingIcon != null
                ? Icon(leadingIcon)
                : const SizedBox.shrink(),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimen.paddingCommon15),
          child: GestureDetector(
              onTap: onTrailingClick,
              child: trailingIcon != null
                  ? Icon(trailingIcon)
                  : const SizedBox.shrink()),
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(56.0);
}
