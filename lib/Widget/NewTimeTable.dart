import 'package:flutter/material.dart';

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
      padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: _titleInputController,
              onSubmitted: (_) => _submitData(),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: RaisedButton(
                onPressed: _submitData,
                child: Text(
                  "Add",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
              ),
            )
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
