import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/medicine_model.dart';
import '../../data/repositories/medicine_repository_impl.dart';

// Provide the repository
final medicineRepositoryProvider = Provider((ref) {
  final box = Hive.box<MedicineModel>('medicines_box');
  return MedicineRepository(box);
});

// Loading state provider
final medicineLoadingProvider = StateProvider<bool>((ref) => false);

// Error state provider
final medicineErrorProvider = StateProvider<String?>((ref) => null);

// Notification permission status provider - rebuilds on demand
final notificationPermissionProvider =
    FutureProvider<PermissionStatus>((ref) async {
  return await Permission.notification.status;
});

// Time picker state providers for edit popup
final selectedHourProvider =
    StateNotifierProvider<_IntNotifier, int>((ref) => _IntNotifier(12));
final selectedMinuteProvider =
    StateNotifierProvider<_IntNotifier, int>((ref) => _IntNotifier(0));
final isPmProvider =
    StateNotifierProvider<_BoolNotifier, bool>((ref) => _BoolNotifier(false));

class _IntNotifier extends StateNotifier<int> {
  _IntNotifier(int initialValue) : super(initialValue);

  void update(int value) => state = value;
}

class _BoolNotifier extends StateNotifier<bool> {
  _BoolNotifier(bool initialValue) : super(initialValue);

  void update(bool value) => state = value;
}

// Update the notifier to use the repository
class MedicineNotifier extends StateNotifier<List<MedicineModel>> {
  final MedicineRepository _repository;
  final Ref _ref;

  MedicineNotifier(this._repository, this._ref) : super([]) {
    _loadAndSort();
  }

  void _loadAndSort() {
    final list = _repository.getAllMedicines();
    // Filter out snoozed medicines that are still in snooze period
    final filteredList = list.where((med) => !med.isSnoozed).toList();
    // Requirement: Sorted by time (earlier first)
    filteredList.sort((a, b) {
      final aTime = a.scheduledTime.hour * 60 + a.scheduledTime.minute;
      final bTime = b.scheduledTime.hour * 60 + b.scheduledTime.minute;
      return aTime.compareTo(bTime);
    });
    state = filteredList;
  }

  void markAsMissed(String id) {
    state = [
      for (final med in state)
        if (med.id == id) med.copyWith(isTaken: false, isSkipped: true) else med
    ];
    _repository.updateMedicine(state.firstWhere((m) => m.id == id));
  }

  void markAsNotTaken(String id) {
    state = [
      for (final med in state)
        if (med.id == id)
          med.copyWith(isTaken: false, isSkipped: false)
        else
          med
    ];
    _repository.updateMedicine(state.firstWhere((m) => m.id == id));
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    try {
      _ref.read(medicineLoadingProvider.notifier).state = true;
      _ref.read(medicineErrorProvider.notifier).state = null;

      await _repository.addMedicine(medicine);
      _loadAndSort();
    } catch (e) {
      _ref.read(medicineErrorProvider.notifier).state =
          'Failed to add medicine: ${e.toString()}';
    } finally {
      _ref.read(medicineLoadingProvider.notifier).state = false;
    }
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    try {
      _ref.read(medicineLoadingProvider.notifier).state = true;
      _ref.read(medicineErrorProvider.notifier).state = null;

      await _repository.updateMedicine(medicine);
      _loadAndSort();
    } catch (e) {
      _ref.read(medicineErrorProvider.notifier).state =
          'Failed to update medicine: ${e.toString()}';
    } finally {
      _ref.read(medicineLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    try {
      _ref.read(medicineLoadingProvider.notifier).state = true;
      _ref.read(medicineErrorProvider.notifier).state = null;

      await _repository.deleteMedicine(medicineId);
      _loadAndSort();
    } catch (e) {
      _ref.read(medicineErrorProvider.notifier).state =
          'Failed to delete medicine: ${e.toString()}';
    } finally {
      _ref.read(medicineLoadingProvider.notifier).state = false;
    }
  }

  Future<void> markAsTaken(String medicineId) async {
    try {
      _ref.read(medicineLoadingProvider.notifier).state = true;
      _ref.read(medicineErrorProvider.notifier).state = null;

      final medicine = state.firstWhere((med) => med.id == medicineId);
      final updatedMedicine = medicine.copyWith(
        isTaken: true,
        takenAt: DateTime.now(),
      );
      await _repository.updateMedicine(updatedMedicine);
      _loadAndSort();
    } catch (e) {
      _ref.read(medicineErrorProvider.notifier).state =
          'Failed to mark medicine as taken: ${e.toString()}';
    } finally {
      _ref.read(medicineLoadingProvider.notifier).state = false;
    }
  }

  Future<void> snoozeMedicine(
      String medicineId, Duration snoozeDuration) async {
    try {
      _ref.read(medicineLoadingProvider.notifier).state = true;
      _ref.read(medicineErrorProvider.notifier).state = null;

      final medicine = state.firstWhere((med) => med.id == medicineId);
      final updatedMedicine = medicine.copyWith(
        snoozedUntil: DateTime.now().add(snoozeDuration),
      );
      await _repository.updateMedicine(updatedMedicine);
      _loadAndSort();
    } catch (e) {
      _ref.read(medicineErrorProvider.notifier).state =
          'Failed to snooze medicine: ${e.toString()}';
    } finally {
      _ref.read(medicineLoadingProvider.notifier).state = false;
    }
  }

  Future<void> skipMedicine(String medicineId) async {
    try {
      _ref.read(medicineLoadingProvider.notifier).state = true;
      _ref.read(medicineErrorProvider.notifier).state = null;

      final medicine = state.firstWhere((med) => med.id == medicineId);
      final updatedMedicine = medicine.copyWith(
        isSkipped: true,
      );
      await _repository.updateMedicine(updatedMedicine);
      _loadAndSort();
    } catch (e) {
      _ref.read(medicineErrorProvider.notifier).state =
          'Failed to skip medicine: ${e.toString()}';
    } finally {
      _ref.read(medicineLoadingProvider.notifier).state = false;
    }
  }

  void clearError() {
    _ref.read(medicineErrorProvider.notifier).state = null;
  }
}

final medicineProvider =
    StateNotifierProvider<MedicineNotifier, List<MedicineModel>>((ref) {
  final repo = ref.watch(medicineRepositoryProvider);
  return MedicineNotifier(repo, ref);
});
