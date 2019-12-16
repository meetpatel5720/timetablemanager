import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timetablemanager/constant_data.dart';

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String path;
  var _courseCodeInputController = TextEditingController();
  var _courseTitleInputController = TextEditingController();
  List courseList;
  bool isEdit = false;
  var editIndex = 0;

  String oldCode = "";

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: Text('Courses'),
    );
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    path = routeArgs['path'];

    courseList = getCoursesList();

    return Scaffold(
      backgroundColor: dark,
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            color: lightBackground),
        child: Column(children: <Widget>[
          Container(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  cursorColor: dark,
                  cursorRadius: Radius.circular(4),
                  style: TextStyle(color: colorList[2]),
                  decoration: InputDecoration(
                      labelText: 'Course code',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      hintText: "Enter course code",
                      hintStyle: TextStyle(color: colorList[2])),
                  controller: _courseCodeInputController,
                ),
                TextField(
                  cursorColor: dark,
                  cursorRadius: Radius.circular(4),
                  style: TextStyle(color: colorList[2]),
                  decoration: InputDecoration(
                      labelText: 'Course title',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      hintText: "Enter course title",
                      hintStyle: TextStyle(color: colorList[2])),
                  controller: _courseTitleInputController,
                ),
                SizedBox(
                  height: 12,
                ),
                RaisedButton(
                  color: dark,
                  elevation: 0,
                  highlightElevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    isEdit ? "Edit" : "Add",
                    style: TextStyle(color: lightBackground, fontSize: 16),
                  ),
                  onPressed: _addCourse,
                )
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    color: dark.withOpacity(0.08)),
                height: mediaQuery.size.height -
                    appBar.preferredSize.height -
                    mediaQuery.padding.top -
                    mediaQuery.viewInsets.bottom -
                    200,
                child: courseList.isEmpty
                    ? Center(
                        child: Text(
                          "No courses found...",
                          style: TextStyle(
                              color: dark,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                            left: 12, right: 12, top: 6, bottom: 6),
                        itemCount: courseList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(top: 6, bottom: 6),
                            decoration: BoxDecoration(
                                color: lightBox,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Text(
                                  courseList[index]['course_code'] +
                                      " - " +
                                      courseList[index]['course_title'],
                                  style: TextStyle(
                                    color: dark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                )),
                                IconButton(
                                  padding: EdgeInsets.only(right: 10),
                                  alignment: Alignment.centerRight,
                                  icon: Icon(Icons.edit),
                                  iconSize: 25,
                                  onPressed: () {
                                    setState(() {
                                      _courseCodeInputController.text =
                                          courseList[index]['course_code'];
                                      _courseTitleInputController.text =
                                          courseList[index]['course_title'];
                                      oldCode =
                                          courseList[index]['course_code'];
                                      isEdit = true;
                                      editIndex = index;
                                    });
                                  },
                                  color: colorList[1],
                                ),
                                IconButton(
                                  padding: EdgeInsets.only(right: 10),
                                  alignment: Alignment.centerRight,
                                  icon: Icon(Icons.delete),
                                  iconSize: 25,
                                  onPressed: () => _deleteCourse(index),
                                  color: colorList[2],
                                )
                              ],
                            ),
                          );
                        })),
          ),
        ]),
      ),
    );
  }

  List getCoursesList() {
    File file = File(path);
    Map<String, dynamic> jsonFileContent = jsonDecode(file.readAsStringSync());
    return jsonFileContent['courses'];
  }

  void _addCourse() {
    final courseCode = _courseCodeInputController.text;
    final courseTitle = _courseTitleInputController.text;
    if (courseCode.isEmpty || courseTitle.isEmpty) return;

    if (isEdit) {
      courseList[editIndex] = {
        'course_code': courseCode,
        'course_title': courseTitle
      };
    } else {
      courseList.add({'course_code': courseCode, 'course_title': courseTitle});
    }

    updateFile();
    setState(() {
      isEdit = false;
      editIndex = 0;
      courseList = getCoursesList();
    });

    _courseCodeInputController.clear();
    _courseTitleInputController.clear();
  }

  void _deleteCourse(int index) {
    courseList.removeAt(index);
    updateFile();
    setState(() {
      isEdit = false;
      editIndex = 0;
      courseList = getCoursesList();
    });
  }

  void updateFile() {
    File file = File(path);
    Map<String, dynamic> jsonFileContent = jsonDecode(file.readAsStringSync());
    var timeTable = jsonFileContent['days'];

    if (isEdit) {
      timeTable.asMap().forEach((i, value) {
        value['lectures'].asMap().forEach((j, lecValue) {
          if (lecValue['type'] == "Lecture" &&
              lecValue['course_code'] == oldCode) {
            timeTable[i]['lectures'][j]['course_code'] =
                _courseCodeInputController.text;
            timeTable[i]['lectures'][j]['course_title'] =
                _courseTitleInputController.text;
          } else if (lecValue['type'] == "Lab" ||
              lecValue['type'] == "Tutorial") {
            lecValue['lab'].asMap().forEach((k, lab) {
              if (lab['course_code'] == oldCode) {
                var temp = timeTable[i]['lectures'][j]['lab'][k];
                temp['course_code'] = _courseCodeInputController.text;
              }
            });
          }
        });
      });
    }
    var newData = {'courses': courseList, 'days': timeTable};
    file.writeAsStringSync(jsonEncode(newData));
  }

  void updateCourseInTimeTable() {}
}
