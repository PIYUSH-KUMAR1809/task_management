import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:task_management/home/controllers/home_controller.dart';

import '../../utilities/logger.dart';
import '../../utilities/notification_handler.dart';
import '../models/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController homeController = Get.put(HomeController());
  NotificationHandler notificationController =
      Get.put(NotificationHandler.instance);
  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    homeController.loadToDos();
    notificationController.checkForNotification();
    // if (widget.notificationPayload != null) {
    //   _showTaskDialogFromNotification(widget.notificationPayload!);
    // }
  }

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) {
      logger.i("Notification permission granted");
    } else if (status.isDenied) {
      logger.i("Notification permission denied");
    } else if (status.isPermanentlyDenied) {
      logger.i(
          "Notification permission permanently denied, please enable it from settings.");
      openAppSettings();
    }
  }

  // void _showTaskDialogFromNotification(String payload) {
  //   int taskId = int.parse(payload);
  //   int taskIndex =
  //       homeController.todos.indexWhere((element) => element.id == taskId);
  //
  //   if (taskIndex != -1) {
  //     ToDoModel todo = homeController.todos[taskIndex];
  //     _showTaskDialog(todo);
  //   }
  // }

  Future<void> _showTaskDialog(String id) async {
    notificationController.notificationPayload.value = '';
    Future.delayed(Duration.zero, () async {
      print("id: $id");
      if (id.isEmpty) {
        return;
      }
      int index = homeController.todos
          .indexWhere((element) => int.parse(id) == element.id);
      print("index = $index");
      if (index == -1) {
        return;
      }
      final todo = homeController.todos[index];
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Task Details',
            style: GoogleFonts.poppins(),
          ),
          content: Text(todo.title),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                homeController.logout(context);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Tasks for you',
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout),
              color: Colors.red,
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              children: [
                Obx(() {
                  print(notificationController.notificationPayload.value);
                  _showTaskDialog(
                      notificationController.notificationPayload.value);
                  if (homeController.isLoading.value) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: 100.0,
                        ),
                        Center(
                          child: Container(
                              child: Center(
                                  child: CircularProgressIndicator(
                            color: Colors.red,
                          ))),
                        ),
                      ],
                    );
                  } else if (homeController.hasData.value == false) {
                    return Column(
                      children: [
                        Center(
                          child: Text(
                            'No ToDos for this user',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => ListView.builder(
                                    physics: const ScrollPhysics(
                                      parent: NeverScrollableScrollPhysics(),
                                    ),
                                    shrinkWrap: true,
                                    itemCount: homeController.todos.length,
                                    itemBuilder: (context, index) {
                                      final todo = homeController.todos[index];
                                      return Card(
                                        color: Colors.grey[900],
                                        child: ListTile(
                                          title: Text(
                                            homeController.todos[index].title,
                                            style: GoogleFonts.poppins(
                                              decoration: homeController
                                                      .todos[index].completed
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              color: homeController
                                                      .todos[index].completed
                                                  ? Colors.white
                                                      .withOpacity(0.7)
                                                  : Colors.white,
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: todo.completed,
                                                onChanged: (value) {
                                                  homeController
                                                      .toggleCompletion(index);
                                                },
                                                activeColor: Colors.white,
                                                checkColor: Colors.black,
                                                side: BorderSide(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  NotificationHandler.instance
                                                      .showNotifications(todo);
                                                  //notificationService                                                      .showNotifications(todo);
                                                },
                                                icon: const Icon(
                                                  Icons.notification_add,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                iconColor: Colors.white,
                                                color: Colors.black,
                                                onSelected: (value) async {
                                                  if (value == 'edit') {
                                                    await _showEditTaskDialog(
                                                        context, todo);
                                                  } else if (value ==
                                                      'delete') {
                                                    homeController
                                                        .deleteTask(todo.id);
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text(
                                                      'Edit',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text(
                                                      'Delete',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _showAddTaskDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ToDoModel newTodo = ToDoModel(
                userId: 1, // Assuming userId is 1 for this example
                id: DateTime.now().millisecondsSinceEpoch, // Use a unique id
                title: titleController.text,
                completed: false,
              );
              homeController.addTask(newTodo);
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTaskDialog(BuildContext context, ToDoModel todo) async {
    TextEditingController titleController =
        TextEditingController(text: todo.title);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              todo.title = titleController.text;
              homeController.updateTask(todo);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
