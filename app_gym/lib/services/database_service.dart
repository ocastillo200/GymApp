import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_gym/models/exercise.dart';
import 'package:app_gym/models/routine.dart';
import 'package:app_gym/models/client.dart';

class DatabaseService {
  static Future<List<Client>> getClients() async {
    final response = await http.get(Uri.parse('http://localhost:8000'));
    final clients = <Client>[];
    if (response.statusCode == 200) {
      final clientsData = json.decode(response.body);
      for (var clientData in clientsData) {
        clients.add(
          Client(
        id: clientData['id'],
        name: clientData['name'],
        rut: clientData['rut'],
        payment: clientData['payment'],
        email: clientData['email'],
        phone: clientData['phone'],
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
            duration: exerciseData['duration'],
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
        await http.get(Uri.parse('http://localhost:8000/clients/$clientId/routines'));
    final routines = <Routine>[];
    if (response.statusCode == 200) {
      final routinesData = json.decode(response.body);
      for (var routineData in routinesData) {
        final exercises = <Exercise>[     
    Exercise(id: '1', name: 'Sentadillas', description: 'asi se hace este', sets: 3, reps: 10, duration: 0),
    Exercise(id: '2', name: 'Flexiones', description: 'asi se hace este otro', sets: 3, reps: 10, duration: 0),
    Exercise(id: '3', name: 'Estocadas', description: 'dsadas', sets: 3, reps: 10, duration: 0), 
    Exercise(id: '4', name: 'Dominadas', description: 'nosenose',  sets: 3, reps: 10, duration: 0),
    Exercise(id: '5', name: 'Press Banca', description: 'dsadas', sets: 3, reps: 10, duration: 0),
    Exercise(id: '6', name: 'Peso muerto', description: 'muybuenosesestes', sets: 3, reps: 10, duration: 0),
        ];
        routines.add(
          Routine(
            id: routineData['id'],
            comments: routineData['comment'],
            exercises: exercises,
            date: routineData['date'],
          ),
        );
      }
    }
    return routines;
  }

  static Future<void> addRoutine(Routine routine, String clientId) async {
  final exerciseIds = routine.exercises.map((exercise) => exercise.id).toList();
  final response = await http.post(
    Uri.parse('http://localhost:8000/clients/$clientId/routines/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'date': routine.date,
      'comment': routine.comments,
      'exercises': exerciseIds,
    }),
  );
  if (response.statusCode != 200) {
    print('Error agregando la rutina');
  }
}
}