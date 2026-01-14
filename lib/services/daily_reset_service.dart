import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';
import '../features/medicine/data/models/medicine_model.dart';
import 'notification_service.dart';

class DailyResetService {
  static const int _dailyResetNotificationId = 999999;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the daily reset service
  static Future<void> init() async {
    await _scheduleDailyReset();
    if (kDebugMode) {
      debugPrint("DailyResetService initialized");
    }
  }

  /// Schedule a daily reset at midnight
  static Future<void> _scheduleDailyReset() async {
    // Cancel any existing daily reset notification
    await _notificationsPlugin.cancel(_dailyResetNotificationId);

    // Calculate next midnight
    final now = DateTime.now();
    var nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);

    // Convert to timezone-aware datetime
    final tzNextMidnight = tz.TZDateTime.from(nextMidnight, tz.local);

    // Schedule the daily reset notification
    await _notificationsPlugin.zonedSchedule(
      _dailyResetNotificationId,
      'Daily Reset',
      'Resetting medicine reminders for new day',
      tzNextMidnight,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reset_channel',
          'Daily Reset',
          importance: Importance.low,
          priority: Priority.low,
          showWhen: false,
          silent: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    if (kDebugMode) {
      debugPrint("Daily reset scheduled for: $tzNextMidnight");
    }
  }

  /// Perform the daily reset of all medicines
  static Future<void> performDailyReset() async {
    try {
      final box = Hive.box<MedicineModel>('medicines_box');
      final medicines = box.values.toList();

      if (kDebugMode) {
        debugPrint("Performing daily reset for ${medicines.length} medicines");
      }

      for (final medicine in medicines) {
        // Reset the medicine status for the new day
        final resetMedicine = medicine.copyWith(
          isTaken: false,
          isSkipped: false,
          takenAt: null,
          snoozedUntil: null,
        );

        // Update in storage
        await box.put(medicine.id, resetMedicine);

        // Cancel existing notification and reschedule for today
        await NotificationService.cancelAlarm(medicine.id);
        await NotificationService.scheduleAlarm(resetMedicine);

        if (kDebugMode) {
          debugPrint("Reset medicine: ${medicine.name}");
        }
      }

      // Schedule the next daily reset
      await _scheduleDailyReset();

      if (kDebugMode) {
        debugPrint("Daily reset completed successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error during daily reset: $e");
      }
    }
  }

  /// Manual reset for testing purposes
  static Future<void> manualReset() async {
    if (kDebugMode) {
      debugPrint("Manual daily reset triggered");
    }
    await performDailyReset();
  }

  /// Check if it's a new day and perform reset if needed
  static Future<void> checkAndPerformResetIfNeeded() async {
    final box = Hive.box<MedicineModel>('medicines_box');
    final medicines = box.values.toList();

    if (medicines.isEmpty) return;

    // Check if any medicine has a takenAt date from a previous day
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool needsReset = false;

    // Check if we have any medicines that were taken/skipped on a previous day
    for (final medicine in medicines) {
      if (medicine.takenAt != null) {
        final takenDate = DateTime(
          medicine.takenAt!.year,
          medicine.takenAt!.month,
          medicine.takenAt!.day,
        );
        if (takenDate.isBefore(today)) {
          needsReset = true;
          break;
        }
      }

      // Also check if medicine is marked as taken/skipped but we're in a new day
      if (medicine.isTaken || medicine.isSkipped) {
        // If it's a new day and medicine is still marked as taken/skipped, reset it
        final lastResetDate = await _getLastResetDate();
        if (lastResetDate == null || lastResetDate.isBefore(today)) {
          needsReset = true;
          break;
        }
      }
    }

    if (needsReset) {
      if (kDebugMode) {
        debugPrint("New day detected, performing reset");
      }
      await performDailyReset();
      await _saveLastResetDate(today);
    }
  }

  /// Get the last reset date from storage
  static Future<DateTime?> _getLastResetDate() async {
    try {
      final box = await Hive.openBox('app_settings');
      final timestamp = box.get('last_reset_date');
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error getting last reset date: $e");
      }
    }
    return null;
  }

  /// Save the last reset date to storage
  static Future<void> _saveLastResetDate(DateTime date) async {
    try {
      final box = await Hive.openBox('app_settings');
      await box.put('last_reset_date', date.millisecondsSinceEpoch);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error saving last reset date: $e");
      }
    }
  }
}
