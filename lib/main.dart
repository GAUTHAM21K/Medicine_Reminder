import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/medicine/data/models/medicine_model.dart';
import 'features/medicine/presentation/screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/daily_reset_service.dart';

void main() async {
  // Ensure Flutter framework is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Local Storage (Hive)
  await Hive.initFlutter();
  Hive.registerAdapter(MedicineModelAdapter());
  await Hive.openBox<MedicineModel>('medicines_box');
  await Hive.openBox(
      'app_settings'); // For storing app-level settings like last reset date

  // 2. Initialize Notifications & Timezones
  await NotificationService.init();

  // 3. Initialize Daily Reset Service
  await DailyResetService.init();

  // 4. Check if we need to perform a reset on app startup
  await DailyResetService.checkAndPerformResetIfNeeded();

  runApp(const ProviderScope(child: MedicineApp()));
}

class MedicineApp extends StatelessWidget {
  const MedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Reminder',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
