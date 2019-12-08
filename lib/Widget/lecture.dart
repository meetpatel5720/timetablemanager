import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetablemanager/constant_data.dart';

class Lecture extends StatelessWidget {
  final lecture;
  DateTime startTime;
  DateTime endTime;
  Lecture(this.lecture);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (lecture['type'] == "Lecture") {
      backgroundColor = colorList[0];
    } else if (lecture['type'] == "Lab") {
      backgroundColor = colorList[1];
    } else if (lecture['type'] == "Tutorial") {
      backgroundColor = colorList[2];
    } else if (lecture['type'] == "Break") {
      backgroundColor = colorList[3];
    }
    startTime = DateTime.parse("0000-00-00 " + lecture['start_time']);
    endTime = DateTime.parse("0000-00-00 " + lecture['end_time']);
    return Container(
      width: 172,
      margin: EdgeInsets.only(left: 5, right: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.all(const Radius.circular(12))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            DateFormat.jm().format(startTime) +
                ' - ' +
                DateFormat.jm().format(endTime),
            style: TextStyle(
                color: backgroundColor,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      lecture['course_code'] == ""
                          ? lecture['type']
                          : lecture['course_code'],
                      style: TextStyle(
                          color: backgroundColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Visibility(
                    visible: lecture['course_title'] != "",
                    child: Text(
                      lecture['course_title'],
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        color: backgroundColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Visibility(
                    visible: lecture['type'] == 'Lab' ||
                        lecture['type'] == 'Tutorial',
                    child: Align(
                      alignment: Alignment.center,
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: lecture['lab'].length,
                        itemBuilder: (ctx, index) {
                          return Text(
                            lecture['lab'][index]['batch'] +
                                " - " +
                                lecture['lab'][index]['course_code'],
                            style: TextStyle(
                              color: backgroundColor,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: lecture['lab'].length > 1 ? 2 : 1,
                          childAspectRatio:
                              lecture['lab'].length > 1 ? 4.5 : 10,
                        ),
                        scrollDirection: Axis.vertical,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
