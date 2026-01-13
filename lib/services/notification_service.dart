import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../features/medicine/data/models/medicine_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print("Notification tapped: ${response.payload}");
        }
      },
    );

    // Create the high-priority channel for Android
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'med_reminder_channel',
          'Medicine Reminders',
          description: 'Used for scheduled medicine alarms',
          importance: Importance.max,
          playSound: true,
        ));
  }

  /// Schedules a notification with high priority and exact timing
  static Future<void> scheduleAlarm(MedicineModel medicine) async {
    final now = DateTime.now();
    final scheduledDate = medicine.scheduledTime;

    // Convert to TZDateTime
    var tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // If the time has already passed today, schedule for the next day
    if (tzScheduledDate.isBefore(now)) {
      tzScheduledDate = tzScheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      medicine.id.hashCode,
      'Medicine Reminder',
      'Time to take ${medicine.dosage} of ${medicine.name}',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminder_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Note: uiLocalNotificationDateInterpretation is REMOVED for v17+ compatibility
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (kDebugMode) {
      debugPrint("Alarm scheduled for: $tzScheduledDate");
    }
  }

  static Future<void> cancelAlarm(String id) async {
    await _notificationsPlugin.cancel(id.hashCode);
  }
}
