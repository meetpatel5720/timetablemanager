import 'package:flutter/material.dart';

class NoTimeTable extends StatelessWidget {
  final Function _openAddNewTimeTable;

  NoTimeTable(this._openAddNewTimeTable);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("No time table found..."),
          RaisedButton(
            onPressed: () => _openAddNewTimeTable(context),
            child: Text("Create New"),
          )
        ],
      ),
    );
  }
}
