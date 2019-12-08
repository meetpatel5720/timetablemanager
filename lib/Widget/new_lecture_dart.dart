import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetablemanager/constant_data.dart';

class AddNewLecture extends StatefulWidget {
  final Function addNewLecture;
  String path;
  final isEdit;
  final lectureEditIndex;
  final dayIndex;

  AddNewLecture(this.addNewLecture, this.path, this.isEdit,
      this.lectureEditIndex, this.dayIndex);

  @override
  _AddNewLectureState createState() => _AddNewLectureState();
}

class _AddNewLectureState extends State<AddNewLecture> {
  var _batchInputController = TextEditingController();

  List<DropdownMenuItem<String>> _dayMenuItems;
  List<DropdownMenuItem<String>> _typeMenuItems;
  List<DropdownMenuItem<Map>> _coursesMenuItems;

  String _selectedDay;
  String _selectedType;
  Map _selectedCourse;

  bool isCourse = true;
  bool isLab = false;
  bool isBreak = false;

  bool isLabEdit = false;
  int labEditIndex = 0;

  DateTime startTime = DateTime.parse("0000-00-00 09:00:00.000");
  DateTime endTime = DateTime.parse("0000-00-00 10:00:00.000");

  Map<String, dynamic> jsonFileContent;
  List coursesList;
  List timeTable;

  List labList = [];

  @override
  void initState() {
    getTimeTable();
    _dayMenuItems = buildMenuList(dayList);
    _typeMenuItems = buildMenuList(lecTypes);
    _coursesMenuItems = buildCourseList(coursesList);

    if (widget.isEdit && widget.lectureEditIndex >= 0 && widget.dayIndex >= 0) {
      var temp =
          timeTable[widget.dayIndex]['lectures'][widget.lectureEditIndex];
      _selectedDay = _dayMenuItems[widget.dayIndex].value;
      _selectedType = temp['type'];

      startTime = DateTime.parse("0000-00-00 " + temp['start_time']);
      endTime = DateTime.parse("0000-00-00 " + temp['end_time']);
      labList = temp['lab'];
      if (temp['type'] == "Lab" || temp['type'] == "Tutorial") {
        isLab = true;
        _selectedCourse = _coursesMenuItems[0].value;
      } else if (temp['type'] == "Break") {
        isBreak = true;
      } else {
        _selectedCourse = findCourse(temp['course_code']);
      }
    } else {
      _selectedDay = _dayMenuItems[0].value;
      _selectedType = _typeMenuItems[0].value;
      _selectedCourse = _coursesMenuItems[0].value;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              "Day",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: dark),
                            )),
                        DropdownButton(
                          items: _dayMenuItems,
                          onChanged: (String newValue) {
                            setState(() {
                              _selectedDay = newValue;
                            });
                          },
                          value: _selectedDay,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Text(
                              "Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: dark),
                            )),
                        DropdownButton(
                          items: _typeMenuItems,
                          onChanged: (String newValue) {
                            setState(() {
                              _selectedType = newValue;
                              if (_selectedType == "Lecture") {
                                isCourse = true;
                                isLab = false;
                                isBreak = false;
                              } else if (_selectedType == "Break") {
                                isBreak = true;
                                isCourse = false;
                                isLab = false;
                              } else if (_selectedType == "Lab" ||
                                  _selectedType == "Tutorial") {
                                isBreak = false;
                                isCourse = true;
                                isLab = true;
                              }
                            });
                          },
                          value: _selectedType,
                        ),
                        SizedBox(
                          width: 32,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              "Start:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: dark),
                            )),
                        FlatButton(
                          child: Text(
                            DateFormat.jm().format(startTime),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colorList[2],
                            ),
                          ),
                          onPressed: () => _presentTimePicker("start"),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                            child: Text(
                          "End:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: dark),
                        )),
                        FlatButton(
                          child: Text(DateFormat.jm().format(endTime),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: colorList[2],
                              )),
                          onPressed: () => _presentTimePicker("end"),
                        ),
                        SizedBox(
                          width: 32,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Visibility(
                visible: !isBreak,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                "Course",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: dark),
                              )),
                          DropdownButton(
                            items: _coursesMenuItems,
                            onChanged: _onChangeSelectedCourse,
                            value: _selectedCourse,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Visibility(
                        visible: isLab,
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Batch",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: dark),
                            ),
                            Container(
                              height: 32,
                              margin: EdgeInsets.only(left: 16),
                              width: 50,
                              child: TextField(
                                cursorColor: dark,
                                cursorRadius: Radius.circular(4),
                                style: TextStyle(color: colorList[2]),
                                decoration: InputDecoration(
                                    hintText: "Batch",
                                    hintStyle: TextStyle(color: colorList[2])),
                                controller: _batchInputController,
                              ),
                            ),
                            Visibility(
                              visible: isLab,
                              child: IconButton(
                                icon: Icon(
                                  isLabEdit ? Icons.done : Icons.add,
                                  color: colorList[2],
                                  size: 28,
                                ),
                                onPressed: addLab,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !isBreak & isLab & (labList.length > 0),
                child: Container(
                  height: 100,
                  child: GridView.builder(
                    itemCount: labList.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: dark,
                        ),
                        margin: EdgeInsets.all(4),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(
                                  labList[index]['course_code'] +
                                      " - " +
                                      labList[index]['batch'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: lightBackground),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: lightBackground,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedCourse = findCourse(
                                        labList[index]['course_code']);
                                    _batchInputController.text =
                                        labList[index]['batch'];
                                    labEditIndex = index;
                                    isLabEdit = true;
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 40,
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: lightBackground,
                                ),
                                onPressed: () {
                                  setState(() {
                                    labList.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 4 / 1),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: dark,
                      elevation: 0,
                      highlightElevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        widget.isEdit ? "Edit" : "Add",
                        style: TextStyle(color: lightBackground, fontSize: 16),
                      ),
                      onPressed: addLectureToFile,
                    ),
                    Visibility(
                      visible: widget.isEdit,
                      child: Container(
                        margin: EdgeInsets.only(left: 16),
                        child: RaisedButton(
                          color: dark,
                          elevation: 0,
                          highlightElevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text("Delete",
                              style: TextStyle(
                                  color: lightBackground, fontSize: 16)),
                          onPressed: deleteLecture,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> buildMenuList(List itemList) {
    List<DropdownMenuItem<String>> items = List();

    for (String item in itemList) {
      items.add(DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(color: colorList[2]),
        ),
      ));
    }
    return items;
  }

  void _presentTimePicker(String select) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        if (select == "start") {
          startTime = DateTime(0, 0, 0, pickedDate.hour, pickedDate.minute);
        } else if (select == "end") {
          endTime = DateTime(0, 0, 0, pickedDate.hour, pickedDate.minute);
        }
      });
    });
  }

  void getTimeTable() {
    File file = File(widget.path);
    jsonFileContent = jsonDecode(file.readAsStringSync());
    coursesList = jsonFileContent['courses'];
    timeTable = jsonFileContent['days'];
  }

  List<DropdownMenuItem<Map>> buildCourseList(List coursesList) {
    List<DropdownMenuItem<Map>> items = List();

    for (Map item in coursesList) {
      items.add(DropdownMenuItem(
        value: item,
        child: Container(
            width: 80,
            child: Text(
              item['course_code'],
              maxLines: 1,
              style: TextStyle(color: colorList[2]),
              overflow: TextOverflow.fade,
              softWrap: false,
            )),
      ));
    }
    return items;
  }

  void _onChangeSelectedCourse(Map value) {
    setState(() {
      _selectedCourse = value;
    });
  }

  void addLab() {
    final batch = _batchInputController.text;
    if (batch.isEmpty) return;

    setState(() {
      if (isLabEdit) {
        labList[labEditIndex] = {
          'batch': batch,
          'course_code': _selectedCourse['course_code']
        };
        isLabEdit = false;
      } else {
        labList.add(
            {'batch': batch, 'course_code': _selectedCourse['course_code']});
      }
    });
    _batchInputController.clear();
  }

  Map findCourse(String title) {
    for (var item in coursesList) {
      if (item['course_code'] == title) return item;
    }
    return coursesList[0];
  }

  void addLectureToFile() {
    if (isLab && labList.length == 0) return;
    var temp = {
      'type': _selectedType,
      'start_time': DateFormat.Hm().format(startTime),
      'end_time': DateFormat.Hm().format(endTime),
      'course_code': isBreak || isLab ? "" : _selectedCourse['course_code'],
      'course_title': isBreak || isLab ? "" : _selectedCourse['course_title'],
      'lab': !isBreak & isLab ? labList : []
    };
    int dayIndex = dayList.indexOf(_selectedDay);

    if (widget.isEdit) {
      timeTable[widget.dayIndex]['lectures'].removeAt(widget.lectureEditIndex);
      timeTable[dayIndex]['lectures'].add(temp);
    } else {
      timeTable[dayIndex]['lectures'].add(temp);
    }
    updateFile(dayIndex);
  }

  void deleteLecture() {
    timeTable[widget.dayIndex]['lectures'].removeAt(widget.lectureEditIndex);
    updateFile(widget.dayIndex);
  }

  void updateFile(int dayIndex) {
    timeTable[dayIndex]['lectures'].sort((a, b) {
      return DateTime.parse("0000-00-00 " + a['start_time'])
          .compareTo(DateTime.parse("0000-00-00 " + b['start_time']));
    });
    var newData = {'courses': coursesList, 'days': timeTable};
    widget.addNewLecture(newData);
    Navigator.of(context).pop();
  }
}
