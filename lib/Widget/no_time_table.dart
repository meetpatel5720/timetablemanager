import 'package:flutter/material.dart';
import 'package:timetablemanager/constant_data.dart';

class NoTimeTable extends StatelessWidget {
  final Function _openAddNewTimeTable;

  NoTimeTable(this._openAddNewTimeTable);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("No time table found..."),
          RaisedButton(
            color: dark,
            elevation: 0,
            highlightElevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Text("Create new",
                style: TextStyle(color: lightText, fontSize: 16)),
            onPressed: () => _openAddNewTimeTable(context),
          )
        ],
      ),
    );
  }
}
