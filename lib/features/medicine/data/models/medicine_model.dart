import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 0)
class MedicineModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final DateTime scheduledTime;

  @HiveField(4)
  final bool isTaken;

  @HiveField(5)
  final DateTime? takenAt;

  @HiveField(6)
  final DateTime? snoozedUntil;

  @HiveField(7)
  final bool isSkipped;

  MedicineModel({
    String? id,
    required this.name,
    required this.dosage,
    required this.scheduledTime,
    this.isTaken = false,
    this.takenAt,
    this.snoozedUntil,
    this.isSkipped = false,
  }) : id = id ?? const Uuid().v4();

  MedicineModel copyWith({
    String? id,
    String? name,
    String? dosage,
    DateTime? scheduledTime,
    bool? isTaken,
    DateTime? takenAt,
    DateTime? snoozedUntil,
    bool? isSkipped,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isTaken: isTaken ?? this.isTaken,
      takenAt: takenAt ?? this.takenAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  bool get isSnoozed =>
      snoozedUntil != null && DateTime.now().isBefore(snoozedUntil!);
}
