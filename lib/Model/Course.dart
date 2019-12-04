import 'dart:convert';

class Course {
  final String courseCode;
  final String courseTitle;

  Course({this.courseCode, this.courseTitle});

  factory Course.fromJson(Map json) => new Course(
        courseCode: json["course_code"],
        courseTitle: json["course_title"],
      );
}

Course courseFromJson(String str) {
  final jsonData = json.decode(str);
  return Course.fromJson(jsonData);
}
