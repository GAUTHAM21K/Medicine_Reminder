import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/permission_service.dart';
import '../providers/medicine_notifier.dart';
import '../widgets/timeline_tile.dart';
import '../../data/models/medicine_model.dart';
import 'add_medicine_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Requirements: Trigger permission checks on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.checkAndRequestPermissions(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permission status when app comes back to focus
      ref.invalidate(notificationPermissionProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicines = ref.watch(medicineProvider);
    final isLoading = ref.watch(medicineLoadingProvider);
    final error = ref.watch(medicineErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400),
            ),
            const Text("Today's Schedule",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // Manual reset button for testing
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _showResetConfirmation(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Reset Day'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 0. Permission warning banner (Notification disabled)
              _buildPermissionWarningBanner(),

              // 0.5. Daily reset status (for debugging)
              if (kDebugMode) _buildResetStatusBanner(),

              // 1. Error banner logic (Existing feature)
              if (error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            ref.read(medicineProvider.notifier).clearError(),
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.red.shade600,
                      ),
                    ],
                  ),
                ),

              // 2. Medicine list with Timeline logic
              Expanded(
                child: medicines.isEmpty
                    ? _buildPlaceholder() // Requirement: Placeholder text if empty
                    : _buildTimelineList(medicines, ref),
              ),
            ],
          ),

          // 3. Loading overlay (Existing feature)
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentOrange,
        onPressed: isLoading
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
                ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPermissionWarningBanner() {
    return Consumer(
      builder: (context, ref, child) {
        final permissionStatus = ref.watch(notificationPermissionProvider);

        return permissionStatus.when(
          data: (status) {
            // Only show if permission is denied or permanently denied
            if (status.isDenied || status.isPermanentlyDenied) {
              return Container(
                width: double.infinity,
                color: const Color(0xFFE0F7FA), // Light Teal
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.notifications_off,
                        color: AppTheme.primaryTeal, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Reminders are off. You might miss your doses!",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        openAppSettings();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text(
                        "ENABLE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentOrange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTimelineList(List<MedicineModel> medicines, WidgetRef ref) {
    // Requirement: Sorted by time (9 AM before 2 PM)
    final sortedMeds = [...medicines];
    sortedMeds.sort((a, b) {
      final aTime = a.scheduledTime.hour * 60 + a.scheduledTime.minute;
      final bTime = b.scheduledTime.hour * 60 + b.scheduledTime.minute;
      return aTime.compareTo(bTime);
    });

    // logic to find the "Next Dose" to highlight
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    final nonTakenMedicines =
        sortedMeds.where((m) => !m.isTaken && !m.isSkipped).toList();

    MedicineModel? nextMedicine;
    if (nonTakenMedicines.isNotEmpty) {
      final upcomingToday = nonTakenMedicines.where((m) {
        final medTime = m.scheduledTime.hour * 60 + m.scheduledTime.minute;
        return medTime >= currentTime;
      }).toList();

      if (upcomingToday.isNotEmpty) {
        nextMedicine = upcomingToday.first;
      } else {
        nextMedicine = nonTakenMedicines.first;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: sortedMeds.length,
      itemBuilder: (context, index) {
        final med = sortedMeds[index];
        final bool isNext = nextMedicine?.id == med.id;

        return MedicineTimelineTile(
          medicine: med,
          isNext: isNext, // Requirement: Visually distinguish next due medicine
          isLast: index == sortedMeds.length - 1,
          onMarkAsTaken: () {
            ref.read(medicineProvider.notifier).markAsTaken(med.id);
          },
          onSnooze: (duration) {
            ref
                .read(medicineProvider.notifier)
                .snoozeMedicine(med.id, duration);
            _showSnackBar(
                context,
                '${med.name} snoozed for ${duration.inMinutes} minutes',
                Colors.orange);
          },
          onSkip: () {
            _showSkipConfirmation(context, ref, med);
          },
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No medicines scheduled for today",
            style: TextStyle(
                fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Tap the + button to add your first medicine",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showSkipConfirmation(
      BuildContext context, WidgetRef ref, MedicineModel medicine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Medicine'),
        content: Text('Are you sure you want to skip "${medicine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(medicineProvider.notifier).skipMedicine(medicine.id);
              _showSnackBar(context, '${medicine.name} skipped', Colors.grey);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Day'),
        content: const Text(
          'This will reset all medicines for today (mark as not taken, clear snoozes). '
          'This is mainly for testing the daily reset functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(medicineProvider.notifier).performManualReset();
              _showSnackBar(
                  context,
                  'Day reset successfully! All medicines are now pending.',
                  Colors.green);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStatusBanner() {
    return FutureBuilder<DateTime?>(
      future: _getLastResetDate(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final lastReset = snapshot.data!;
          final today = DateTime.now();
          final isToday = lastReset.year == today.year &&
              lastReset.month == today.month &&
              lastReset.day == today.day;

          return Container(
            width: double.infinity,
            color: isToday ? Colors.green.shade50 : Colors.orange.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              isToday
                  ? 'Daily reset: Today at ${DateFormat('HH:mm').format(lastReset)}'
                  : 'Last reset: ${DateFormat('MMM d, HH:mm').format(lastReset)}',
              style: TextStyle(
                fontSize: 12,
                color: isToday ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<DateTime?> _getLastResetDate() async {
    try {
      final box = Hive.box('app_settings');
      final timestamp = box.get('last_reset_date');
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }
}
