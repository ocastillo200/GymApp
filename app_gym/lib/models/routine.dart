import 'package:app_gym/models/exercise.dart';

class Routine {
  final String id;
  final String clientId;
  final List<Exercise> exercises;
  final String comments;
  final String date = DateTime.now().toString();

  Routine({
    required this.id,
    required this.clientId,
    required this.exercises,
    required this.comments,
  });
}