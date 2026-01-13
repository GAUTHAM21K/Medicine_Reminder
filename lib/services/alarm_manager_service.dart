import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import '../features/medicine/data/models/medicine_model.dart';

class AlarmManagerService {
  static Future<void> init() async {
    // Initialize notification service instead of alarm manager
    await NotificationService.init();
    if (kDebugMode) {
      debugPrint("AlarmManagerService initialized with notifications");
    }
  }

  // Schedule medicine reminder using notifications
  static Future<void> scheduleAlarm(MedicineModel medicine) async {
    await NotificationService.scheduleAlarm(medicine);
    if (kDebugMode) {
      debugPrint("Alarm scheduled for medicine: ${medicine.name}");
    }
  }

  // Cancel medicine reminder
  static Future<void> cancelAlarm(String medicineId) async {
    await NotificationService.cancelAlarm(medicineId);
    if (kDebugMode) {
      debugPrint("Alarm cancelled for medicine ID: $medicineId");
    }
  }

  // This would be triggered by the notification system
  static void onAlarmTriggered() {
    // Logic handled by notification service
    if (kDebugMode) {
      debugPrint("Alarm fired via notification");
    }
  }
}
