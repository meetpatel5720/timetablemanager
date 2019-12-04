import 'package:flutter/material.dart';

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
            color: Colors.blue,
            elevation: 0,
            highlightElevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () => _openAddNewTimeTable(context),
            child: Text(
              "Create New",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
