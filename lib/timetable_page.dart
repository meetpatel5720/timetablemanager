import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timetablemanager/Widget/new_lecture_dart.dart';
import 'package:timetablemanager/constant_data.dart' as prefix0;

import 'Widget/day.dart';
import 'constant_data.dart';

class TimeTablePage extends StatefulWidget {
  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  String path;
  Map<String, dynamic> jsonFileContent;
  List coursesList;
  List timeTable;
  List nonEmptyDays = List();

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final String title = routeArgs['title'];

    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      centerTitle: true,
      title: Text(title[0].toUpperCase() + title.substring(1)),
    );
    path = routeArgs['path'];

    getTimeTable();

    return Scaffold(
      backgroundColor: dark,
      appBar: appBar,
      body: _buildPage(mediaQuery, appBar),
    );
  }

  void getTimeTable() {
    File file = File(path);
    jsonFileContent = jsonDecode(file.readAsStringSync());
    coursesList = jsonFileContent['courses'];
    timeTable = jsonFileContent['days'];
  }

  Widget _buildPage(var mediaQuery, AppBar appBar) {
    if (coursesList.length == 0) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          color: lightBackground,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("First add some couses"),
              RaisedButton(
                color: dark,
                elevation: 0,
                highlightElevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Text("Add",
                    style: TextStyle(color: lightText, fontSize: 16)),
                onPressed: () => _viewCourses(context),
              )
            ],
          ),
        ),
      );
    } else if (isTimeTableEmpty()) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          color: lightBackground,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Add lectures"),
                    RaisedButton(
                      color: dark,
                      elevation: 0,
                      highlightElevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text("Add",
                          style: TextStyle(color: lightText, fontSize: 16)),
                      onPressed: () =>
                          _openAddNewLecture(context, false, -1, -1),
                    ),
                  ],
                ),
              ),
              bottomBarBuilder()
            ],
          ),
        ),
      );
    } else {
      getNonEmptyList();
      return Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              color: lightBackground,
            ),
            height: mediaQuery.size.height -
                appBar.preferredSize.height -
                60 -
                mediaQuery.padding.top -
                mediaQuery.viewInsets.bottom,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              child: ListView.builder(
                  padding:
                      EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
                  scrollDirection: Axis.vertical,
                  itemCount: nonEmptyDays.length,
                  itemBuilder: (context, index) {
                    return Day(
                        context, nonEmptyDays[index], _openAddNewLecture);
                  }),
            ),
          ),
          bottomBarBuilder()
        ],
      );
    }
  }

  Widget bottomBarBuilder() {
    return Visibility(
      visible: coursesList.length > 0,
      child: Container(
        height: 60,
        decoration: BoxDecoration(color: lightBackground),
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Container(
                color: dark,
              ),
              height: 0.7,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add,
                            size: 32,
                            color: dark,
                          ),
                          Text(
                            "Lecture",
                            style: TextStyle(fontSize: 12, color: dark),
                          ),
                        ],
                      ),
                      onPressed: () =>
                          _openAddNewLecture(context, false, -1, -1),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.list,
                            size: 32,
                            color: dark,
                          ),
                          Text(
                            "Courses",
                            style: TextStyle(fontSize: 12, color: dark),
                          ),
                        ],
                      ),
                      onPressed: () => _viewCourses(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewCourses(BuildContext ctx) {
    Navigator.of(ctx).pushNamed('/viewCourses', arguments: {
      'path': path,
    });
  }

  void _addLecture(var newData) {
    File file = File(path);
    file.writeAsStringSync(jsonEncode(newData));
    setState(() {
      getTimeTable();
    });
  }

  void _openAddNewLecture(
      BuildContext ctx, bool isEdit, int editLecIndex, int dayIndex) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: ctx,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            color: lightBackground,
          ),
          height: 600 + MediaQuery.of(context).viewInsets.bottom,
          child: GestureDetector(
            onTap: () {},
            child: AddNewLecture(
                _addLecture, path, isEdit, editLecIndex, dayIndex),
            behavior: HitTestBehavior.opaque,
          ),
        );
      },
    );
  }

  bool isTimeTableEmpty() {
    for (Map day in timeTable) {
      if (day['lectures'].length > 0) {
        return false;
      }
    }
    return true;
  }

  void getNonEmptyList() {
    nonEmptyDays.clear();
    for (Map item in timeTable) {
      if (item['lectures'].length > 0) {
        nonEmptyDays.add(item);
      }
    }
  }
}
