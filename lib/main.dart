import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/medicine/data/models/medicine_model.dart';
import 'features/medicine/presentation/screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  // Ensure Flutter framework is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Local Storage (Hive)
  await Hive.initFlutter();
  Hive.registerAdapter(MedicineModelAdapter());
  await Hive.openBox<MedicineModel>('medicines_box');

  // 2. Initialize Notifications & Timezones
  await NotificationService.init();

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
