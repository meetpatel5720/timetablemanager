import 'dart:convert';

class Course {
  final String courseCode;
  final String courseTitle;

  Course({this.courseCode, this.courseTitle});

  factory Course.fromJson(Map<String, dynamic> json) => new Course(
        courseCode: json["course_code"],
        courseTitle: json["course_title"],
      );

  Map<String, dynamic> toJson() => {
        "course_code": courseCode,
        "course_title": courseTitle,
      };
}

Course courseFromJson(String str) {
  final jsonData = json.decode(str);
  return Course.fromJson(jsonData);
}

String courseToJson(Course data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
