import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_gym/models/exercise.dart';
import 'package:app_gym/models/routine.dart';
import 'package:app_gym/models/client.dart';

class DatabaseService {
  static Future<List<Client>> getClients() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/clients'));
    final clients = <Client>[];

    if (response.statusCode == 200) {
      final clientsData = json.decode(response.body);
      for (var clientData in clientsData) {
        clients.add(
          Client(
        id: clientData['_id'],
        name: clientData['name'],
        rut: clientData['rut'],
        payment: clientData['payment'],
        email: clientData['email'],
        phone: clientData['phone'],
        routines: List<String>.from(clientData['routines']),
      ),
        );
      }
    }

    return clients;
  }

  static Future<List<Exercise>> getExercises() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/exercises'));
    final exercises = <Exercise>[];

    if (response.statusCode == 200) {
      final exercisesData = json.decode(response.body);
      for (var exerciseData in exercisesData) {
        exercises.add(
          Exercise(
            id: exerciseData['_id'],
            name: exerciseData['name'],
            description: exerciseData['description'],
            sets: exerciseData['sets'],
            reps: exerciseData['reps'],
          ),
        );
      }
    }

    return exercises;
  }

  static Future<void> addExercise(Exercise exercise) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/exercises'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': exercise.name,
        'description': exercise.description,
      }),
    );

    if (response.statusCode != 200) {
      // Handle error
    }
  }

  static Future<List<Routine>> getRoutines(String clientId) async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/routines/$clientId'));
    final routines = <Routine>[];

    if (response.statusCode == 200) {
      final routinesData = json.decode(response.body);
      for (var routineData in routinesData) {
        final exercises = <Exercise>[];
        for (var exerciseData in routineData['exercises']) {
          exercises.add(
            Exercise(
              id: exerciseData['_id'],
              name: exerciseData['name'],
              description: exerciseData['description'],
              sets: exerciseData['sets'],
              reps: exerciseData['reps'],
            ),
          );
        }

        routines.add(
          Routine(
            id: routineData['_id'],
            clientId: routineData['clientId'],
            exercises: exercises,
            
            comments: routineData['comments'],
          ),
        );
      }
    }

    return routines;
  }

  static Future<void> addRoutine(Routine routine) async {
    final exerciseIds = routine.exercises.map((exercise) => exercise.id).toList();

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/routines'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'clientId': routine.clientId,
        'exercises': exerciseIds,
      
        'comments': routine.comments,
      }),
    );

    if (response.statusCode != 200) {
      // Handle error
    }
  }
}