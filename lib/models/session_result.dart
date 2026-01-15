import 'package:hive/hive.dart';

part 'session_result.g.dart';

@HiveType(typeId: 0)
class SessionResult extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String instrument;

  @HiveField(2)
  final int score;

  @HiveField(3)
  final int totalNotes;

  SessionResult({
    required this.date,
    required this.instrument,
    required this.score,
    required this.totalNotes,
  });

  String get accuracy {
    if (totalNotes == 0) return "0%";
    return "${((score / totalNotes) * 100).toStringAsFixed(1)}%";
  }
}
