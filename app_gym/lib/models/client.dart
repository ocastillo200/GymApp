import 'package:app_gym/models/draft.dart';

class Client {
  final String? image;
  final String id;
  final String name;
  final String rut;
  final bool health;
  final String email;
  final String phone;
  final List<String> routines = [];
  final Draft? draft;
  Client(
      {required this.image,
      required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.rut,
      required this.health,
      required this.draft});
}
