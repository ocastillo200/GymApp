import 'dart:convert';
// Remove the unused import 'dart:html'
import 'package:http/http.dart' as http;
import 'package:app_gym/models/client.dart';

class AuthService {
  static Future<Client?> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      return Client(
        id: userData['_id'],
        name: userData['name'],
        rut: userData['rut'],
        payment: userData['payment'],
        email: userData['email'],
        phone: userData['phone'],
      );
    }
    return null;
  }
}