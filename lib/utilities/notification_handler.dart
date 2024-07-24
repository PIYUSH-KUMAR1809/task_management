import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;

import '../home/models/todo_model.dart';
import 'logger.dart';

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationHandler extends GetxController {
  RxString notificationPayload = ''.obs;
  static final NotificationHandler _instance = NotificationHandler._internal();
  NotificationHandler._internal();

  static NotificationHandler get instance => _instance;

  AndroidInitializationSettings androidInitializationSettings =
      const AndroidInitializationSettings("@mipmap/ic_launcher");

  DarwinInitializationSettings iosSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestCriticalPermission: true,
    requestSoundPermission: true,
  );

  late InitializationSettings initializationSettings;

  Future<void> notificationInit() async {
    initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosSettings);
    bool? initialized = await notificationsPlugin.initialize(
        initializationSettings, onDidReceiveNotificationResponse: (response) {
      logger.i(response.payload.toString());
      notificationPayload.value = response.payload ?? '';
    });
    logger.i(initialized);
  }

  void showNotifications(ToDoModel todo) async {
    logger.i('function called');
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "notifications_task",
      "task-notifications",
      priority: Priority.max,
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
    );
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    // DateTime scheduleDate = DateTime.now().add(Duration(seconds: 5));

    await notificationsPlugin.zonedSchedule(
      todo.id,
      'Task Manager',
      todo.title,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: todo.id.toString(),
    );
  }

  void checkForNotification() async {
    NotificationAppLaunchDetails? details =
        await notificationsPlugin.getNotificationAppLaunchDetails();

    if (details != null) {
      if (details.didNotificationLaunchApp) {
        NotificationResponse? response = details.notificationResponse;

        if (response != null) {
          String? payload = response.payload;
          logger.i(payload);
          notificationPayload.value = response.payload ?? '';
          // _showTaskDialogFromNotification(payload!);
        }
      }
    }
  }
}
