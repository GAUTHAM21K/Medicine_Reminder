import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/medicine_model.dart';
import '../providers/medicine_notifier.dart';
import '../../../../services/notification_service.dart';
import '../widgets/time_slider.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();

  // Default to today at the current time
  DateTime _selectedTime = DateTime.now();

  /// Logic to save to local storage and schedule the high-priority alarm
  void _saveMedicine() async {
    if (_formKey.currentState!.validate()) {
      final newMed = MedicineModel(
        name: _nameController.text.trim(),
        dosage: _doseController.text.trim(),
        scheduledTime: _selectedTime,
      );

      try {
        // 1. Persist data to Hive through the Riverpod Notifier
        await ref.read(medicineProvider.notifier).addMedicine(newMed);

        // 2. Schedule the exact high-priority alarm

        await NotificationService.scheduleAlarm(newMed);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Medicine reminder saved successfully!")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving reminder: $e")),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Medicine"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Medicine Name"),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration("e.g., Ibuprofen"),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter a name"
                    : null,
              ),
              const SizedBox(height: 24),
              _buildLabel("Dosage"),
              TextFormField(
                controller: _doseController,
                decoration: _inputDecoration("e.g., 1 tablet or 5ml"),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter the dose"
                    : null,
              ),
              const SizedBox(height: 40),
              // _buildLabel("Reminder Time"),
              // const SizedBox(height: 12),

              // Custom interactive timeline slider for time selection
              Center(
                child: TimeSliderPicker(
                  value: _selectedTime,
                  onChanged: (newTime) {
                    setState(() {
                      _selectedTime = newTime;
                    });
                  },
                ),
              ),

              const SizedBox(height: 60),

              // Save Button using strictly Orange as per design requirements
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Save Reminder",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}
