import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine_model.dart';
import '../../../../services/notification_service.dart';

class MedicineRepository {
  final Box<MedicineModel> _box;

  MedicineRepository(this._box);

  // Fetch all medicines
  List<MedicineModel> getAllMedicines() {
    return _box.values.toList();
  }

  //Save medicine to local storage
  Future<void> addMedicine(MedicineModel medicine,
      {String? customSound}) async {
    await _box.put(medicine.id, medicine);
    // Schedule notification for the medicine
    await NotificationService.scheduleAlarm(medicine, customSound: customSound);
  }

  Future<void> updateMedicine(MedicineModel medicine,
      {String? customSound}) async {
    await _box.put(medicine.id, medicine);
    // Cancel existing notification and reschedule with new settings
    await NotificationService.cancelAlarm(medicine.id);
    if (!medicine.isTaken && !medicine.isSkipped) {
      await NotificationService.scheduleAlarm(medicine,
          customSound: customSound);
    }
  }

  Future<void> deleteMedicine(String id) async {
    await _box.delete(id);
    // Cancel the notification when medicine is deleted
    await NotificationService.cancelAlarm(id);
  }
}
