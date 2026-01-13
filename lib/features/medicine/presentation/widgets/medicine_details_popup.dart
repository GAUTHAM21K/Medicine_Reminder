import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/medicine_model.dart';
import '../providers/medicine_notifier.dart';

class MedicineDetailsPopup extends ConsumerStatefulWidget {
  final MedicineModel medicine;

  const MedicineDetailsPopup({
    super.key,
    required this.medicine,
  });

  @override
  ConsumerState<MedicineDetailsPopup> createState() => _MedicineDetailsPopupState();
}

class _MedicineDetailsPopupState extends ConsumerState<MedicineDetailsPopup> {
  late TextEditingController nameController;
  late TextEditingController dosageController;

  // Controllers for the updated wheel picker
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController amPmController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.medicine.name);
    dosageController = TextEditingController(text: widget.medicine.dosage);

    final time = widget.medicine.scheduledTime;
    final selectedHour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final selectedMinute = time.minute;
    final isPm = time.hour >= 12;

    // Initialize providers with the medicine's current time
    ref.read(selectedHourProvider.notifier).update(selectedHour);
    ref.read(selectedMinuteProvider.notifier).update(selectedMinute);
    ref.read(isPmProvider.notifier).update(isPm);

    hourController = FixedExtentScrollController(initialItem: selectedHour - 1);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    amPmController = FixedExtentScrollController(initialItem: isPm ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildMinimalField(
                controller: nameController, label: "MEDICINE NAME"),
            const SizedBox(height: 24),
            _buildMinimalField(
                controller: dosageController,
                label: "DOSAGE",
                hint: "e.g., 1 pill"),

            const SizedBox(height: 40),

            Text(
              "REMINDER TIME",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // --- Updated Time Wheel Section ---
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(
                  height: 180, // Slightly more compact for popup
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWheelWithProvider(
                        controller: hourController,
                        itemCount: 12,
                        labelBuilder: (index) => (index + 1).toString(),
                        intProvider: selectedHourProvider,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(":",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.2))),
                      ),
                      _buildWheelWithProvider(
                        controller: minuteController,
                        itemCount: 60,
                        labelBuilder: (index) =>
                            index.toString().padLeft(2, '0'),
                        intProvider: selectedMinuteProvider,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- AM/PM Pill Toggle ---
            Center(
              child: Consumer(
                builder: (context, ref, child) {
                  final isPm = ref.watch(isPmProvider);
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAmPmButton("AM", !isPm),
                        _buildAmPmButton("PM", isPm),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _deleteMedicine,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Delete",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Save Changes",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelWithProvider({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelBuilder,
    required StateNotifierProvider<dynamic, int> intProvider,
  }) {
    return SizedBox(
      width: 60,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        perspective: 0.006,
        diameterRatio: 1.5,
        overAndUnderCenterOpacity: 0.4,
        magnification: 1.2,
        useMagnifier: true,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          HapticFeedback.lightImpact();
          ref.read(intProvider.notifier).update(index);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return Center(
              child: Text(
                labelBuilder(index),
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAmPmButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          ref.read(isPmProvider.notifier).update(label == "PM");
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalField(
      {required TextEditingController controller,
      required String label,
      String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
        TextField(
          controller: controller,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 16),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade100)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
          ),
        ),
      ],
    );
  }

  void _saveChanges() async {
    final selectedHour = ref.read(selectedHourProvider);
    final selectedMinute = ref.read(selectedMinuteProvider);
    final isPm = ref.read(isPmProvider);

    int hour24 = selectedHour;
    if (isPm && selectedHour != 12) hour24 += 12;
    if (!isPm && selectedHour == 12) hour24 = 0;

    final now = DateTime.now();
    final updated = widget.medicine.copyWith(
      name: nameController.text.trim(),
      dosage: dosageController.text.trim(),
      scheduledTime:
          DateTime(now.year, now.month, now.day, hour24, selectedMinute),
    );
    await ref.read(medicineProvider.notifier).updateMedicine(updated);
    if (mounted) Navigator.pop(context);
  }

  void _deleteMedicine() async {
    await ref
        .read(medicineProvider.notifier)
        .deleteMedicine(widget.medicine.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }
}
