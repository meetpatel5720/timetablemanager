import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timetablemanager/constant_data.dart';

class TimeTableCard extends StatelessWidget {
  final String title;
  final File filePath;

  TimeTableCard(this.title, this.filePath);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openTimeTable(context),
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.blue, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(
            title.split("/").last.split(".").first,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void openTimeTable(BuildContext ctx) {
    Navigator.of(ctx).pushNamed('/timetableview', arguments: {
      'title': title.split("/").last.split(".").first,
      'path': filePath.path.toString(),
    });
  }
}
