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
        // Handle daily reset notification
        if (response.id == 999999) {
          _handleDailyResetNotification();
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
          sound: RawResourceAndroidNotificationSound('medicine_reminder'),
        ));

    // Create the daily reset channel for Android
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'daily_reset_channel',
          'Daily Reset',
          description: 'Used for daily medicine status reset',
          importance: Importance.low,
          playSound: false,
        ));
  }

  /// Schedules a notification with high priority and exact timing
  static Future<void> scheduleAlarm(MedicineModel medicine,
      {String? customSound}) async {
    final now = DateTime.now();
    final scheduledDate = medicine.scheduledTime;

    // Create a DateTime for today with the medicine's time
    var todayScheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledDate.hour,
      scheduledDate.minute,
      scheduledDate.second,
    );

    // If the time has already passed today, schedule for the next day
    if (todayScheduledTime.isBefore(now)) {
      todayScheduledTime = todayScheduledTime.add(const Duration(days: 1));
    }

    // Convert to TZDateTime
    var tzScheduledDate = tz.TZDateTime.from(todayScheduledTime, tz.local);

    // Configure sound settings
    String? soundFile =
        customSound ?? 'medicine_reminder.mp3'; // Default sound file

    await _notificationsPlugin.zonedSchedule(
      medicine.id.hashCode,
      'Medicine Reminder',
      'Time to take ${medicine.dosage} of ${medicine.name}',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminder_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          sound: soundFile.isNotEmpty
              ? RawResourceAndroidNotificationSound(soundFile.split('.').first)
              : null,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: soundFile,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // This makes it repeat daily
    );

    if (kDebugMode) {
      debugPrint(
          "Recurring alarm scheduled for: $tzScheduledDate (${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}) with sound: $soundFile");
    }
  }

  static Future<void> cancelAlarm(String id) async {
    await _notificationsPlugin.cancel(id.hashCode);
  }

  /// Handle daily reset notification response
  static void _handleDailyResetNotification() async {
    if (kDebugMode) {
      debugPrint("Daily reset notification received, triggering reset");
    }
    // We'll handle this through the main app lifecycle instead
    // to avoid circular dependencies
  }
}
