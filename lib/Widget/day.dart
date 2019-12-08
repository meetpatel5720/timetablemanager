import 'package:flutter/material.dart';
import 'package:timetablemanager/Widget/lecture.dart';
import 'package:timetablemanager/constant_data.dart';
import 'package:timetablemanager/constant_data.dart' as prefix0;

class Day extends StatefulWidget {
  final snapshot;
  final BuildContext context;
  final Function _openAddNewLecture;

  Day(this.context, this.snapshot, this._openAddNewLecture);

  @override
  _DayState createState() => _DayState();
}

class _DayState extends State<Day> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 6, bottom: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.all(8),
                child: Text(
                  widget.snapshot['day_name'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 24,
                      color: prefix0.dark,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              height: 140,
              margin: EdgeInsets.only(bottom: 5),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.snapshot['lectures'].length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onLongPress: () => widget._openAddNewLecture(
                            context,
                            true,
                            index,
                            dayList.indexOf(widget.snapshot['day_name'])),
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Lecture(widget.snapshot['lectures'][index]));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
