import 'package:app_gym/models/lap.dart';

class Draft {
  final String id;
  final List<Lap>? laps;

  Draft({
    required this.id,
    required this.laps,
  });
}
