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

    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      centerTitle: true,
      title: Text(title[0].toUpperCase() + title.substring(1)),
    );
    path = routeArgs['path'];

    getTimeTable();

    return Scaffold(
      backgroundColor: Colors.white,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("First add some couses"),
            RaisedButton(
              color: Colors.blue,
              elevation: 0,
              highlightElevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () => _viewCourses(context),
              child: Text(
                "Add",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      );
    } else if (isTimeTableEmpty()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Add lectures"),
                  RaisedButton(
                    color: Colors.blue,
                    elevation: 0,
                    highlightElevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () => _openAddNewLecture(context, false, -1, -1),
                    child: Text(
                      "Add",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            bottomBarBuilder()
          ],
        ),
      );
    } else {
      getNonEmptyList();
      return Column(
        children: <Widget>[
          Container(
            height: mediaQuery.size.height -
                appBar.preferredSize.height -
                60 -
                mediaQuery.padding.top,
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: nonEmptyDays.length,
                itemBuilder: (context, index) {
                  return Day(context, nonEmptyDays[index], _openAddNewLecture);
                }),
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
        child: Column(
          children: <Widget>[
            Container(
              height: 1,
              color: Colors.blue,
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 32,
                    ),
                    onPressed: () => _openAddNewLecture(context, false, -1, -1),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.list,
                      size: 32,
                    ),
                    onPressed: () => _viewCourses(context),
                  ),
                ),
              ],
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
