import 'package:flutter/material.dart';
import 'package:luanvanflutter/views/admin/components/radial_painter.dart';
import 'package:luanvanflutter/views/admin/constants/constants.dart';

class UsersByDevice extends StatelessWidget {
  const UsersByDevice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: appPadding),
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(appPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thiết bị truy cập',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              margin: EdgeInsets.all(appPadding),
              padding: EdgeInsets.all(appPadding),
              height: 230,
              child: CustomPaint(
                foregroundPainter: RadialPainter(
                  bgColor: textColor.withOpacity(0.1),
                  lineColor: primaryColor,
                  percent: 0.9,
                  width: 18.0,
                ),
                child: Center(
                  child: Text(
                    '90%',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: appPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: primaryColor,
                        size: 10,
                      ),
                      SizedBox(
                        width: appPadding / 2,
                      ),
                      Text(
                        'Điện thoại',
                        style: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: textColor.withOpacity(0.2),
                        size: 10,
                      ),
                      SizedBox(
                        width: appPadding / 2,
                      ),
                      Text(
                        'Desktop',
                        style: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
