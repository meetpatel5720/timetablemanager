import 'package:timetablemanager/Model/Lecture.dart';

class Day {
  final List<Lecture> lectureList;
  final String day;

  Day({this.day, this.lectureList});
}
