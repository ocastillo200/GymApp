import 'package:app_gym/models/exercise.dart';

class Lap{
  final String id;
  final List<Exercise> exercises;
  final int series;
  Lap({required this.id, required this.exercises, required this.series});
}