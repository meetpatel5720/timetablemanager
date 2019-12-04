import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final appBar = AppBar(
      title: Text('Courses'),
    );
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    path = routeArgs['path'];

    courseList = getCoursesList();

    return Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                height: 200,
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          TextField(
                            decoration:
                                InputDecoration(labelText: 'Course code'),
                            controller: _courseCodeInputController,
                          ),
                          TextField(
                            decoration:
                                InputDecoration(labelText: 'Course title'),
                            controller: _courseTitleInputController,
                          ),
                          RaisedButton(
                            child: Text(isEdit ? "Edit" : "Add"),
                            onPressed: _addCourse,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              courseList.isEmpty
                  ? Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text("No courses found")),
                          )
                        ],
                      ),
                    )
                  : Container(
                      height: mediaQuery.height -
                          appBar.preferredSize.height -
                          MediaQuery.of(context).padding.top -
                          200,
                      child: ListView.builder(
                          itemCount: courseList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Text(courseList[index]['course_code'] +
                                        " - "),
                                    Expanded(
                                        child: Text(
                                            courseList[index]['course_title'])),
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
                                          isEdit = true;
                                          editIndex = index;
                                        });
                                      },
                                      color: Colors.blue,
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.only(right: 10),
                                      alignment: Alignment.centerRight,
                                      icon: Icon(Icons.delete),
                                      iconSize: 25,
                                      onPressed: () => _deleteCourse(index),
                                      color: Colors.red,
                                    )
                                  ],
                                ),
                              ),
                            );
                          })),
            ]),
          ),
        ));
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
    var newData = {'courses': courseList, 'days': timeTable};
    file.writeAsStringSync(jsonEncode(newData));
  }
}
