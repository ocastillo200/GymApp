class Exercise {
  final String id;
  final String name;
  final int reps;
  final double weight;
  final int duration;
  final String? machine;

  Exercise(
      {required this.id,
      required this.name,
      required this.machine,
      required this.duration,
      required this.reps,
      required this.weight});
}
