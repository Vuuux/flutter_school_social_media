import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/theme_service.dart';

class CustomAppBar extends StatefulWidget {
  final String title;
  final bool enableBack;
  final Function()? onLeadingClick;
  final Function()? onTrailingClick;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? background;

  const CustomAppBar(
      {Key? key,
      required this.title,
      this.leadingIcon,
      this.trailingIcon,
      required this.onLeadingClick,
      required this.onTrailingClick,
      this.background,
      this.enableBack = false})
      : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(20),
      )),
      pinned: true,
      leading: GestureDetector(
        onTap: widget.onLeadingClick,
        child: widget.enableBack
            ? const Icon(Icons.arrow_back)
            : widget.leadingIcon != null
                ? Icon(widget.leadingIcon)
                : DayNightSwitcherIcon(
                    isDarkModeEnabled: ThemeService().isDarkTheme,
                    onStateChanged: (isDarkModeEnabled) {
                      ThemeService().switchTheme();
                    },
                  ),
      ),
      expandedHeight: Dimen.appBarHeightExpanded,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.title),
        centerTitle: true,
        background: widget.background ?? const FlutterLogo(),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimen.paddingCommon15),
          child: GestureDetector(
              onTap: widget.onTrailingClick,
              child: widget.trailingIcon != null
                  ? Icon(widget.trailingIcon)
                  : const SizedBox.shrink()),
        )
      ],
    );
  }
}
