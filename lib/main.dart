import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timetablemanager/Widget/no_time_table.dart';

import 'Widget/NewTimeTable.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeTable',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
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
    print("Calling build..................................................");
    return Scaffold(
        appBar: AppBar(
            title: Text("TimeTable"),
            actions: Platform.isAndroid
                ? <Widget>[
                    PopupMenuButton<String>(
                      padding: EdgeInsets.all(0),
                      onSelected: (value) => choiceAction(value, context),
                      itemBuilder: (BuildContext context) {
                        return choice.map((String choice) {
                          return PopupMenuItem(
                              value: choice, child: Text(choice));
                        }).toList();
                      },
                    )
                  ]
                : <Widget>[
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.ellipsis,
                        color: Colors.white,
                      ),
                      iconSize: 30,
                      tooltip: 'New Record',
                      onPressed: () {},
                    ),
                  ]),
        body: _buildPage());
  }

  void openAddNewTimeTable(BuildContext ctx) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      )),
      context: ctx,
      builder: (_) {
        return Container(
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
    var map = {"courses": [], "days": []};
    jsonFile.writeAsStringSync(json.encode(map));
    setState(() {
      jsonFileList = getTimeTableList();
    });
  }

  Future<List> getTimeTableList() async {
    List list = baseDir.listSync();
    return list.isNotEmpty ? list : [];
  }

  Widget _buildPage() {
    return FutureBuilder(
      future: checkPermission(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Align(
                alignment: Alignment.center, child: new Text('Loading...'));
          default:
            return snapshot.data != true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Please grant requested permission"),
                        RaisedButton(
                          child: Text("Grant permission"),
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
                          return snapshot.data.isEmpty
                              ? NoTimeTable(openAddNewTimeTable)
                              : ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                        elevation: 2,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          child: Text(snapshot.data[index]
                                              .toString()
                                              .split("/")
                                              .last
                                              .split(".")
                                              .first),
                                        ));
                                  });
                      }
                    });
        }
      },
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

  void choiceAction(String value, BuildContext context) {
    if (value == "Create") {
      openAddNewTimeTable(context);
    }
  }

  void cupertinoActionSheet(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text("Create"),
                onPressed: () => openAddNewTimeTable(context),
              ),
              CupertinoActionSheetAction(
                child: Text("Import"),
                onPressed: () => null,
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          );
        });
  }
}
