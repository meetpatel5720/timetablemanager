import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Lecture extends StatelessWidget {
  final lecture;
  DateTime startTime;
  DateTime endTime;
  Lecture(this.lecture);

  @override
  Widget build(BuildContext context) {
    startTime = DateTime.parse("0000-00-00 " + lecture['start_time']);
    endTime = DateTime.parse("0000-00-00 " + lecture['end_time']);
    return Container(
      width: 180,
      margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(const Radius.circular(5))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            DateFormat.jm().format(startTime) +
                ' - ' +
                DateFormat.jm().format(endTime),
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Visibility(
                    visible: lecture['course_title'] != "",
                    child: Text(
                      lecture['course_title'],
                      style: TextStyle(
                        color: Colors.white,
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
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: lecture['lab'].length > 1 ? 2 : 1,
                          childAspectRatio: 4.5,
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
