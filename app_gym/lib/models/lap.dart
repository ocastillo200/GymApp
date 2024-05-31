import 'package:app_gym/models/exercise.dart';

class Lap {
  final String id;
  final List<Exercise> exercises;
  final int sets;
  Lap({required this.id, required this.exercises, required this.sets});
}
