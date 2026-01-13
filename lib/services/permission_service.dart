import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/theme/app_theme.dart';

class PermissionService {
  /// Checks status and handles UI feedback based on user choice
  static Future<void> checkAndRequestPermissions(BuildContext context) async {
    // 1. Check Notification Status
    final notificationStatus = await Permission.notification.status;

    // 2. Check Exact Alarm Status (Required for Android 12+)
    final alarmStatus = await Permission.scheduleExactAlarm.status;

    if (!context.mounted) return;

    // Handle Notification UI feedback
    if (notificationStatus.isDenied) {
      _showPermissionDialog(context);
    } else if (notificationStatus.isPermanentlyDenied) {
      _showPersistentTopSnackbar(context);
    }

    // Handle Alarm Permission silently if possible, or include in dialog
    if (alarmStatus.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Enable Reminders",
          style: TextStyle(
            color: AppTheme.primaryTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "To ensure you never miss a dose, please allow the app to send you notifications.",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Not Now",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Permission.notification.request();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Allow",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static void _showPersistentTopSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.notifications_off, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Alarms are disabled. Enable them in settings.",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1), // Persistent
        margin: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).size.height - 140, // Positions at the top
          left: 10,
          right: 10,
        ),
        action: SnackBarAction(
          label: "SETTINGS",
          textColor: AppTheme.accentOrange,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }
}
