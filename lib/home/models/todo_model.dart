import 'dart:convert';

List<ToDoModel> toDoModelFromMap(String str) =>
    List<ToDoModel>.from(json.decode(str).map((x) => ToDoModel.fromMap(x)));

String toDoModelToMap(List<ToDoModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ToDoModel {
  int userId;
  int id;
  String title;
  bool completed;
  bool isReminderSet = false;

  ToDoModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  factory ToDoModel.fromMap(Map<String, dynamic> json) => ToDoModel(
        userId: json["userId"],
        id: json["id"],
        title: json["title"],
        completed: json["completed"] is bool
            ? json["completed"]
            : json["completed"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "userId": userId,
        "id": id,
        "title": title,
        "completed": completed ? 1 : 0,
      };
}
