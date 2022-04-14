import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luanvanflutter/models/task.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/dimen.dart';

class TaskTile extends StatelessWidget {
  final TaskSchedule? task;
  const TaskTile({Key? key, this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimen.paddingCommon20),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(Dimen.paddingCommon15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _getColor(task!.color)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task?.title ?? "",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_rounded,
                          color: Colors.grey[200], size: 18),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        task!.startTime + " - " + task!.endTime,
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                fontSize: 13, color: Colors.grey[100])),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    task?.note ?? "",
                    style: GoogleFonts.lato(
                        textStyle:
                            TextStyle(fontSize: 15, color: Colors.grey[100])),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 0.5,
              color: Colors.grey[200]!.withOpacity(0.7),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                task!.isCompleted ? "HOÀN THÀNH" : "CẦN LÀM",
                style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getColor(int color) {
    switch (color) {
      case 0:
        return kPrimaryColor;
      case 1:
        return kPrimaryDarkColor;
      default:
        return kStudyColor;
    }
  }
}
