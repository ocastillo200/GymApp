import 'package:app_gym/models/lap.dart';

class Routine {
  final String id;
  final String date;
  final String comments;
  final List<Lap> laps;
  final String trainer;
  
  Routine({
    required this.id,
    required this.laps,
    required this.comments,
    required this.date,
    required this.trainer
  });
}