import 'package:flutter/material.dart';
import 'package:timetablemanager/constant_data.dart';

class NewTimeTable extends StatefulWidget {
  final Function addNewTimeTable;

  NewTimeTable(this.addNewTimeTable);

  @override
  _NewTimeTableState createState() => _NewTimeTableState();
}

class _NewTimeTableState extends State<NewTimeTable> {
  final _titleInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(8),
              child: TextField(
                cursorColor: dark,
                cursorRadius: Radius.circular(4),
                style: TextStyle(color: colorList[2]),
                decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                controller: _titleInputController,
                onSubmitted: (_) => _submitData(),
              ),
            ),
            RaisedButton(
              elevation: 0,
              highlightElevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: _submitData,
              child: Text(
                "Add",
                style: TextStyle(color: lightBackground, fontSize: 16),
              ),
              color: dark,
            ),
          ],
        ),
      ),
    );
  }

  void _submitData() {
    final title = _titleInputController.text;
    if (title.isEmpty) return;
    widget.addNewTimeTable(title);
    Navigator.of(context).pop();
  }
}
