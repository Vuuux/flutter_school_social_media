// Flutter imports:
import 'package:flutter/material.dart';

extension WidgetModifier on Widget {
  Widget align([AlignmentGeometry alignment = Alignment.center]) {
    return Align(
      alignment: alignment,
      child: this,
    );
  }

  Widget expand([int flex = 1]) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }

  Widget flexible() {
    return Flexible(
      child: this,
    );
  }

  Widget background(Color color) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
      ),
      child: this,
    );
  }

  Widget backgroundImage(String image) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: this,
    );
  }

  Widget cornerRadius(BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: this,
    );
  }

  Widget padding([EdgeInsetsGeometry value = const EdgeInsets.all(0)]) {
    return Padding(
      padding: value,
      child: this,
    );
  }

  Widget opacity([double value = 1]) {
    return Opacity(
      opacity: value,
      child: this,
    );
  }

  Widget shadow(
      {required EdgeInsetsGeometry padding,
      required BorderRadiusGeometry radius}) {
    return Container(
      margin: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: this,
    );
  }
}
