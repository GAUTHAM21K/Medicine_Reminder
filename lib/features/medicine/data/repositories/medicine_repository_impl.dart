import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine_model.dart';

class MedicineRepository {
  final Box<MedicineModel> _box;

  MedicineRepository(this._box);

  // Fetch all medicines
  List<MedicineModel> getAllMedicines() {
    return _box.values.toList();
  }

  //Save medicine to local storage
  Future<void> addMedicine(MedicineModel medicine) async {
    await _box.put(medicine.id, medicine);
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    await _box.put(medicine.id, medicine);
  }

  Future<void> deleteMedicine(String id) async {
    await _box.delete(id);
  }
}
