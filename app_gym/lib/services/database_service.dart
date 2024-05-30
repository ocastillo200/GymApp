import 'dart:convert';
import 'package:app_gym/models/exercise_preset.dart';
import 'package:app_gym/models/machine.dart';
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

  static Future<List<ExercisePreset>> getExercises() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/exercises_preset/'));
    final exercises = <ExercisePreset>[];
    if (response.statusCode == 200) {
      final exercisesData = json.decode(response.body);
      for (var exerciseData in exercisesData) {
        if (exerciseData['machine_ids'] == null) {
          exerciseData['machine_ids'] = [""];
        }
        exercises.add(
          ExercisePreset(
            id: exerciseData['id'],
            name: exerciseData['name'],
            machines: (exerciseData['machine_ids'] as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
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
      }),
    );

    if (response.statusCode != 200) {
      print('Error agregando el ejercicio');
    }
  }

  static Future<List<Machine>> getMachines() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/machines/'));
    final machines = <Machine>[];
    if (response.statusCode == 200) {
      final machinesData = json.decode(response.body);
      for (var machineData in machinesData) {
        machines.add(
          Machine(
            id: machineData['id'],
            name: machineData['name'],
            quantity: machineData['quantity'],
            available: machineData['available'],
          ),
        );
      }
    }
    return machines;
  }

  static Future<String> getMachineName(String machineId) async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/machines/$machineId'));
    if (response.statusCode == 200) {
      final machineData = json.decode(response.body);
      return machineData['name'];
    }
    return '';
  }

  static Future<List<Routine>> getRoutines(String clientId) async {
    final response = await http
        .get(Uri.parse('http://localhost:8000/clients/$clientId/routines'));
    final routines = <Routine>[];
    if (response.statusCode == 200) {
      final routinesData = json.decode(response.body);
      for (var routineData in routinesData) {
        routines.add(
          Routine(
            id: routineData['id'],
            comments: routineData['comment'],
            laps: routineData['exercises'],
            date: routineData['date'],
            trainer: routineData['trainer'],
          ),
        );
      }
    }
    return routines;
  }

  static Future<void> addRoutine(Routine routine, String clientId) async {
    final lapsIds =
        routine.laps.map((lap) => lap.id).toList();
    final response = await http.post(
      Uri.parse('http://localhost:8000/clients/$clientId/routines/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'date': routine.date,
        'comment': routine.comments,
        'trainer': routine.trainer,
        'laps' : lapsIds,
      }),
    );
    if (response.statusCode != 200) {
      print('Error agregando la rutina');
    }
  }
  
  static Future<void> addLapToRoutine(String routineId) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/routines/$routineId/lap/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        
        
      }),
    );
    if (response.statusCode != 200) {
      print('Error agregando la vuelta a la rutina');
    }
  }
}





