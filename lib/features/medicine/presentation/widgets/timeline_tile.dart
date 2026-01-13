import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/medicine_model.dart';
import '../providers/medicine_notifier.dart';
import '../widgets/medicine_details_popup.dart';

class MedicineTimelineTile extends ConsumerStatefulWidget {
  final MedicineModel medicine;
  final bool isNext;
  final bool isLast;
  final VoidCallback? onMarkAsTaken;
  final VoidCallback? onEdit;
  final Function(Duration)? onSnooze;
  final VoidCallback? onSkip;

  const MedicineTimelineTile({
    super.key,
    required this.medicine,
    required this.isNext,
    required this.isLast,
    this.onMarkAsTaken,
    this.onEdit,
    this.onSnooze,
    this.onSkip,
  });

  @override
  ConsumerState<MedicineTimelineTile> createState() =>
      _MedicineTimelineTileState();
}

class _MedicineTimelineTileState extends ConsumerState<MedicineTimelineTile> {
  bool _isEditingState = false;

  bool get _isOverdue =>
      !widget.medicine.isTaken &&
      !widget.medicine.isSkipped &&
      widget.medicine.scheduledTime.isBefore(DateTime.now());

  void _showMedicineDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicineDetailsPopup(
        medicine: widget.medicine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color cardBgColor = widget.medicine.isTaken
        ? Colors.white
        : widget.isNext
            ? AppTheme.accentOrange
            : _isOverdue
                ? const Color(0xFFFFF5F5)
                : Colors.white;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineIndicator(),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => _showMedicineDetails(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _isOverdue && !widget.isNext
                          ? Colors.red.withValues(alpha: 0.2)
                          : widget.isNext
                              ? Colors.transparent
                              : Colors.grey.shade100,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.isNext) _buildNextDoseLabel(),
                              Text(
                                widget.medicine.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isNext
                                      ? Colors.white
                                      : Colors.black87,
                                  decoration: widget.medicine.isSkipped
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.medicine.dosage,
                                style: TextStyle(
                                  color: widget.isNext
                                      ? Colors.white70
                                      : Colors.grey,
                                  decoration: widget.medicine.isSkipped
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('h:mm a')
                                  .format(widget.medicine.scheduledTime),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.isNext
                                    ? Colors.white
                                    : _isOverdue
                                        ? Colors.redAccent
                                        : AppTheme.primaryTeal,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildActionStatus(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionStatus() {
    // Show normal "Take" button for upcoming/unhandled doses
    if (!_isEditingState &&
        !widget.medicine.isTaken &&
        !widget.medicine.isSkipped) {
      return ElevatedButton(
        onPressed: widget.onMarkAsTaken,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isNext
              ? Colors.white
              : _isOverdue
                  ? Colors.redAccent
                  : AppTheme.primaryTeal,
          foregroundColor: widget.isNext ? AppTheme.accentOrange : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(60, 32),
          elevation: 0,
        ),
        child: Text(_isOverdue ? "Missed" : "Take",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      );
    }

    // Horizontal Expansion Selector for Handled Doses
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isEditingState ? Colors.grey.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isEditingState) ...[
            _stateActionButton(Icons.history, "Undo", Colors.blue, () {
              ref
                  .read(medicineProvider.notifier)
                  .markAsNotTaken(widget.medicine.id);
              setState(() => _isEditingState = false);
            }),
            const SizedBox(width: 12),
            _stateActionButton(
                Icons.check_circle, "Taken", AppTheme.primaryTeal, () {
              ref
                  .read(medicineProvider.notifier)
                  .markAsTaken(widget.medicine.id);
              setState(() => _isEditingState = false);
            }),
            const SizedBox(width: 12),
            _stateActionButton(Icons.cancel, "Missed", Colors.redAccent, () {
              ref
                  .read(medicineProvider.notifier)
                  .markAsMissed(widget.medicine.id);
              setState(() => _isEditingState = false);
            }),
          ] else ...[
            GestureDetector(
              onTap: () => setState(() => _isEditingState = true),
              child: widget.medicine.isTaken
                  ? _buildBadge(
                      Icons.check_circle, "Taken", AppTheme.primaryTeal)
                  : _buildBadge(Icons.skip_next, "Skipped", Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _stateActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return Column(
      children: [
        Container(
            width: 2,
            height: 20,
            color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.medicine.isTaken
                  ? AppTheme.primaryTeal
                  : widget.medicine.isSkipped
                      ? Colors.grey
                      : widget.isNext
                          ? AppTheme.accentOrange
                          : AppTheme.primaryTeal.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 6,
            backgroundColor: widget.medicine.isTaken
                ? AppTheme.primaryTeal
                : widget.medicine.isSkipped
                    ? Colors.grey
                    : widget.isNext
                        ? AppTheme.accentOrange
                        : Colors.white,
            child: widget.medicine.isTaken
                ? const Icon(Icons.check, size: 8, color: Colors.white)
                : widget.medicine.isSkipped
                    ? const Icon(Icons.close, size: 8, color: Colors.white)
                    : null,
          ),
        ),
        if (!widget.isLast)
          Expanded(
              child: Container(
                  width: 2,
                  color: AppTheme.primaryTeal.withValues(alpha: 0.2))),
      ],
    );
  }

  Widget _buildNextDoseLabel() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: Text("Next Dose",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }
}
