import 'dart:convert';

class Task {
  int id;
  String title;
  DateTime date;
  String priority;
  String author;
  String userDonated;
  String emailDonated;

  String imageEncoded;

  int status; // 0 = Incomplete, 1 - Complete

  Task imgFromJson(String str) => Task.fromMap(json.decode(str));

  String imgToJson(Task data) => json.encode(data.toMap());

  Task(
      {this.id,
      this.title,
      this.date,
      this.priority,
      this.imageEncoded,
      this.author,
      this.userDonated,
      this.emailDonated});

  Task.withId({this.id,
    this.title,
    this.date,
    this.priority,
    this.status,
    this.imageEncoded,
    this.author,
    this.userDonated,
    this.emailDonated});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    if (date == null)
      date = DateTime.now();
    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    map['image'] = imageEncoded;
    map['author'] = author;
    map['userDonated'] = userDonated;
    map['emailDonated'] = emailDonated;

    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    if (map['date'] == null || map['date'] == "")
      map['date'] = DateTime.now().toIso8601String();

    if (map['id'].runtimeType == String) map['id'] = int.parse(map['id']);

    if (map['status'].runtimeType == String)
      map['status'] = int.parse(map['status']);

    return Task.withId(
        id: (map['id']),
        title: map['title'],
        date: DateTime.parse(map['date']),
        priority: map['priority'],
        status: (map['status']),
        imageEncoded: map['image'],
        emailDonated: map['emailDonated'],
        userDonated: map['userDonated'],
        author: map['author']);
  }
}
