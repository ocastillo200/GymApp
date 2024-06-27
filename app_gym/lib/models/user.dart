class User {
  final String id;
  final String name;
  final String username;
  final String password;
  final String rut;
  final bool admin;

  User(
      {required this.admin,
      required this.id,
      required this.name,
      required this.password,
      required this.rut,
      required this.username});
}
