import 'package:eventual/eventual-notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';

class BottomBarButton extends StatefulWidget {
  final index;
  final EventualNotifier<int> currentIndex;
  final IconData icon;

  const BottomBarButton(
      {Key? key, required this.currentIndex, required this.icon, this.index})
      : super(key: key);

  @override
  State<BottomBarButton> createState() => _BottomBarButtonState();
}

class _BottomBarButtonState extends State<BottomBarButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      minWidth: 20,
      onPressed: () {
        widget.currentIndex.value = widget.index;
        widget.currentIndex.notifyChange();
      },
      child: Icon(
        widget.icon,
        color: widget.currentIndex.value == widget.index
            ? kPrimaryColor
            : Colors.white,
      ),
    );
  }
}
