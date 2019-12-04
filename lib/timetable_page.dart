import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timetablemanager/Widget/new_lecture_dart.dart';

import 'Widget/day.dart';

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
    path = routeArgs['path'];

    getTimeTable();

    return Scaffold(
      appBar: AppBar(
        title: Text(title.toUpperCase()),
        actions: coursesList.length > 0
            ? <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  iconSize: 30,
                  tooltip: 'New lecture',
                  onPressed: () => _openAddNewLecture(context, false, -1, -1),
                ),
                FlatButton(
                  child: Text(
                    "Courses",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  onPressed: () => _viewCourses(context),
                ),
              ]
            : <Widget>[],
      ),
      body: _buildPage(),
    );
  }

  void getTimeTable() {
    File file = File(path);
    jsonFileContent = jsonDecode(file.readAsStringSync());
    coursesList = jsonFileContent['courses'];
    timeTable = jsonFileContent['days'];
  }

  Widget _buildPage() {
    if (coursesList.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("First add some couses"),
            RaisedButton(
              onPressed: () => _viewCourses(context),
              child: Text("Add"),
            )
          ],
        ),
      );
    } else if (isTimeTableEmpty()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Add lectures"),
            RaisedButton(
              onPressed: () => _openAddNewLecture(context, false, -1, -1),
              child: Text("Add"),
            )
          ],
        ),
      );
    } else {
      getNonEmptyList();
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: nonEmptyDays.length,
          itemBuilder: (context, index) {
            return Day(context, nonEmptyDays[index], _openAddNewLecture);
          });
    }
  }

  void _viewCourses(BuildContext ctx) {
    Navigator.of(ctx).pushNamed('/viewCourses', arguments: {
      'path': path,
    });
  }

  void choiceAction(String value, BuildContext context) {
    if (value == "Courses") {
      _viewCourses(context);
    }
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      )),
      context: ctx,
      builder: (_) {
        return Container(
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
