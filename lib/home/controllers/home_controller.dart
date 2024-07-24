import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:task_management/widgets/custom_loader.dart';

import '../../database/database_helper.dart';
import '../../utilities/logger.dart';
import '../models/todo_model.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool hasData = false.obs;
  String? uid;
  RxList<ToDoModel> todos = <ToDoModel>[].obs;
  final _auth = FirebaseAuth.instance;
  final dbHelper = DatabaseHelper();

  late ToDoModel toDoModel;

  @override
  void onInit() {
    super.onInit();
    logger.i('on init called');
    loadToDos();
  }

  Future<void> loadToDos() async {
    logger.i('loadTODOs function');
    isLoading.value = true;
    List<ToDoModel> localToDos = await dbHelper.getToDos();
    if (localToDos.isNotEmpty) {
      todos.assignAll(localToDos);
      hasData.value = true;
      logger.i('it passed here');
      isLoading.value = false;
    } else {
      await getToDO();
    }
  }

  Future<void> getToDO() async {
    isLoading.value = true;
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/todos?userId=1'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      logger.i(data);
      hasData.value = true;
      List<ToDoModel> todoList = toDoModelFromMap(response.body);
      todos.assignAll(todoList);
      logger.i(todos.length);
      logger.i(todos);
      logger.i(_auth.currentUser);
      await dbHelper.insertToDoList(todoList);
      isLoading.value = false;
    } else {
      isLoading.value = false;
      hasData.value = false;
      throw Exception('Failed to load todos');
    }
  }

  void toggleCompletion(int index) async {
    todos[index].completed = !todos[index].completed;
    await dbHelper.updateToDo(todos[index]);
    todos.refresh();
  }

  Future<void> addTask(ToDoModel todo) async {
    await dbHelper.insertToDo(todo);
    todos.add(todo);
    todos.refresh();
  }

  Future<void> updateTask(ToDoModel todo) async {
    await dbHelper.updateToDo(todo);
    int index = todos.indexWhere((element) => element.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      todos.refresh();
    }
  }

  Future<void> deleteTask(int id) async {
    await dbHelper.deleteToDo(id);
    todos.removeWhere((element) => element.id == id);
    todos.refresh();
  }

  Future<void> logout(BuildContext context) async {
    //TODO: Implement logout
    customLoader.showLoader(context);
    await _auth.signOut();
    await DatabaseHelper().deleteUser();
    await DatabaseHelper().deleteToDos();
    customLoader.hideLoader();
    Get.offAllNamed('/login');
  }
}

class SheetController extends GetxController {
  RxBool isToday = true.obs;

  void changeIsToday() {
    isToday.value = !isToday.value;
  }
}
