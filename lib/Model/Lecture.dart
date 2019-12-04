import 'dart:convert';

class Lecture {
  final String type;
  final String startTime;
  final String endTime;
  final String courseCode;
  final String courseTitle;
  final String day;

  Lecture(
      {this.type,
      this.startTime,
      this.endTime,
      this.courseCode,
      this.courseTitle,
      this.day});

  factory Lecture.fromJson(Map<String, dynamic> json) => new Lecture(
        day: json["day"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        courseCode: json["course_code"],
        courseTitle: json["course_title"],
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "start_time": startTime,
        "end_time": endTime,
        "course_code": courseCode,
        "course_title": courseTitle,
      };
}

Lecture lectureFromJson(String str) {
  final jsonData = json.decode(str);
  return Lecture.fromJson(jsonData);
}

String lectureToJson(Lecture data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
