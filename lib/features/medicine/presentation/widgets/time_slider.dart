import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class TimeSliderPicker extends StatefulWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const TimeSliderPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TimeSliderPicker> createState() => _TimeSliderPickerState();
}

class _TimeSliderPickerState extends State<TimeSliderPicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late bool isAM;

  @override
  void initState() {
    super.initState();
    int hour = widget.value.hour;
    isAM = hour < 12;
    // Calculate 0-based index for 1-12 hours
    int initialHour = (hour == 0) ? 11 : (hour > 12 ? hour - 13 : hour - 1);

    _hourController = FixedExtentScrollController(initialItem: initialHour);
    _minuteController =
        FixedExtentScrollController(initialItem: widget.value.minute);
  }

  void _onTimeChanged() {
    HapticFeedback.selectionClick();
    int hour = _hourController.selectedItem + 1;
    int minute = _minuteController.selectedItem;

    int hour24 = hour;
    if (!isAM && hour != 12) hour24 += 12;
    if (isAM && hour == 12) hour24 = 0;

    final newTime = DateTime(
      widget.value.year,
      widget.value.month,
      widget.value.day,
      hour24,
      minute,
    );
    widget.onChanged(newTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- The Wheel Picker (Header Removed) ---
        Stack(
          alignment: Alignment.center,
          children: [
            // Center Selection Highlight (Matches image 2 style)
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            SizedBox(
              height: 220,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hours Wheel
                  _buildWheel(
                    controller: _hourController,
                    itemCount: 12,
                    labelBuilder: (index) => (index + 1).toString(),
                  ),

                  // Separator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      ":",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ),

                  // Minutes Wheel
                  _buildWheel(
                    controller: _minuteController,
                    itemCount: 60,
                    labelBuilder: (index) => index.toString().padLeft(2, '0'),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // --- AM/PM Toggle ---
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAmPmButton("AM", isAM),
              _buildAmPmButton("PM", !isAM),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelBuilder,
  }) {
    return SizedBox(
      width: 60,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        perspective: 0.006, // Adds 3D depth
        diameterRatio: 1.5,
        overAndUnderCenterOpacity:
            0.4, // Automatically fades non-selected items
        magnification: 1.2, // Makes selected item slightly larger
        useMagnifier: true,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (_) => setState(() => _onTimeChanged()),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return Center(
              child: Text(
                labelBuilder(index),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
          setState(() {
            isAM = label == "AM";
            _onTimeChanged();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.accentOrange.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [],
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

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }
}
