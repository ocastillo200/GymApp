import 'package:app_gym/models/draft.dart';

class Client {
  final String id;
  final String name;
  final String rut;
  final bool payment;
  final String email;
  final String phone;
  final List<String> routines = [];
  final Draft? draft;
  Client(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.rut,
      required this.payment,
      required this.draft});
}
