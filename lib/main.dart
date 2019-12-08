import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timetablemanager/Widget/TimeTableCard.dart';
import 'package:timetablemanager/Widget/no_time_table.dart';
import 'package:timetablemanager/constant_data.dart';
import 'package:timetablemanager/courses_page.dart';
import 'package:timetablemanager/timetable_page.dart';

import 'Widget/NewTimeTable.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Table',
      theme: ThemeData(
        splashColor: darkSplash,
        appBarTheme: AppBarTheme(
            elevation: 0,
            color: dark,
            actionsIconTheme: IconThemeData(color: Colors.black),
            iconTheme: IconThemeData(color: lightBackground),
            textTheme: TextTheme(
                title: TextStyle(
                    color: lightBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.bold))),
        primarySwatch: darkSwatch,
      ),
      home: MyHomePage(),
      routes: {
        '/timetableview': (ctx) => TimeTablePage(),
        '/viewCourses': (ctx) => CoursesPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PermissionStatus _status;
  Directory baseDir;
  Future<List> jsonFileList;
  String path;

  List<String> choice = ["Create", "Import"];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      centerTitle: true,
      title: Text("TimeTable"),
    );
    return Scaffold(
      backgroundColor: dark,
      appBar: appBar,
      body: _buildPage(mediaQuery, appBar),
    );
  }

  void openAddNewTimeTable(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            color: lightBackground,
          ),
          height: 350 + MediaQuery.of(context).viewInsets.bottom,
          child: GestureDetector(
            onTap: () {},
            child: NewTimeTable(_addNewTimeTable),
            behavior: HitTestBehavior.opaque,
          ),
        );
      },
    );
  }

  void _addNewTimeTable(String title) {
    File jsonFile = new File(baseDir.path + "/" + title + ".json");
    jsonFile.createSync();

    var days = [];
    for (String day in dayList) {
      days.add({'day_name': day, 'lectures': []});
    }
    var map = {"courses": [], "days": days};
    jsonFile.writeAsStringSync(json.encode(map));
    setState(() {
      jsonFileList = getTimeTableList();
    });
  }

  Future<List> getTimeTableList() async {
    List list = baseDir.listSync();
    return list.isNotEmpty ? list : [];
  }

  Widget _buildPage(var mediaQuery, AppBar appBar) {
    return FutureBuilder(
      future: checkPermission(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Align(
                alignment: Alignment.center, child: new Text('Loading...'));
          default:
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                color: lightBackground,
              ),
              child: snapshot.data != true
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Please grant requested permission"),
                          RaisedButton(
                            color: dark,
                            elevation: 0,
                            highlightElevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Text("Grant permission",
                                style: TextStyle(
                                    color: lightBackground, fontSize: 16)),
                            onPressed: () => requestPermission(),
                          )
                        ],
                      ),
                    )
                  : FutureBuilder(
                      future: getTimeTableList(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Align(
                                alignment: Alignment.center,
                                child: new Text('Loading...'));
                          default:
                            return Column(
                              children: <Widget>[
                                snapshot.data.isEmpty
                                    ? NoTimeTable(openAddNewTimeTable)
                                    : Container(
                                        height: mediaQuery.size.height -
                                            appBar.preferredSize.height -
                                            60 -
                                            mediaQuery.viewInsets.bottom -
                                            mediaQuery.padding.top,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24)),
                                          child: GridView.builder(
                                              padding: EdgeInsets.all(8),
                                              itemCount: snapshot.data.length,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      crossAxisSpacing: 10,
                                                      mainAxisSpacing: 10),
                                              itemBuilder: (context, index) {
                                                return TimeTableCard(
                                                    snapshot.data[index]
                                                        .toString(),
                                                    snapshot.data[index]);
                                              }),
                                        ),
                                      ),
                                bottomBarBuilder(),
                              ],
                            );
                        }
                      }),
            );
        }
      },
    );
  }

  Widget bottomBarBuilder() {
    return Container(
      decoration: BoxDecoration(
        color: lightBackground,
      ),
      height: 60,
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
                          "Time table",
                          style: TextStyle(fontSize: 12, color: dark),
                        ),
                      ],
                    ),
                    onPressed: () => openAddNewTimeTable(context),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.import_export,
                          size: 32,
                          color: dark,
                        ),
                        Text(
                          "Import",
                          style: TextStyle(fontSize: 12, color: dark),
                        ),
                      ],
                    ),
                    onPressed: () => null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void requestPermission() async {
    PermissionHandler().requestPermissions([PermissionGroup.storage]).then(
        (Map<PermissionGroup, PermissionStatus> statuses) {
      final status = statuses[PermissionGroup.storage];
      if (status != PermissionStatus.granted) {
        SystemNavigator.pop();
//            PermissionHandler().openAppSettings();
      } else {
        setState(() {
          _status = status;
        });
      }
    });
  }

  Future<bool> checkPermission() async {
    PermissionStatus status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (status == PermissionStatus.granted) {
      baseDir = await getApplicationDocumentsDirectory();
      baseDir = await Directory(baseDir.path + "/" + "timeTable")
          .create(recursive: true);
      return true;
    } else
      return false;
  }
}
