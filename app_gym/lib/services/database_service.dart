import 'dart:convert';
import 'package:app_gym/models/draft.dart';
import 'package:app_gym/models/exercise_preset.dart';
import 'package:app_gym/models/lap.dart';
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
              draft: clientData['draft']),
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

    if (response.statusCode != 200) {}
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

  static Future<Machine> getMachine(String machineId) async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/machines/$machineId'));

    if (response.statusCode == 200) {
      final machineData = json.decode(response.body);

      print('machineData: $machineData'); // Agrega esta línea para depuración

      if (machineData is Map<String, dynamic> &&
          machineData.containsKey('id')) {
        return Machine(
          id: machineData['id'],
          name: machineData['name'],
          quantity: machineData['quantity'],
          available: machineData['available'],
        );
      } else {
        throw Exception('Unexpected response format');
      }
    }

    throw Exception('Failed to get machine');
  }

  static Future<List<Routine>> getRoutines(String clientId) async {
    final response = await http
        .get(Uri.parse('http://localhost:8000/clients/$clientId/routines'));
    final List<Routine> routines = [];

    if (response.statusCode == 200) {
      final List<dynamic> routinesData = json.decode(response.body);

      for (var routineData in routinesData) {
        List<dynamic> exercisesData = routineData['exercises'] ?? [];
        List<Exercise> exercises = exercisesData.map<Exercise>((exerciseData) {
          return Exercise(
            id: exerciseData['id'],
            presetId: exerciseData['preset_id'],
            name: exerciseData['name'],
            duration: exerciseData['duration'],
            reps: exerciseData['reps'],
            weight: exerciseData['weight'],
            machine: exerciseData['machine'],
          );
        }).toList();
        Lap lap = Lap(
          id: routineData['id'],
          exercises: exercises,
          sets: routineData['sets'] ?? 0,
        );
        Routine routine = Routine(
          id: routineData['id'],
          date: routineData['date'],
          comments: routineData['comment'],
          laps: [lap],
          trainer: routineData['trainer'],
        );

        routines.add(routine);
      }
    }
    return routines;
  }

  static Future<void> addRoutine(Routine routine, String clientId) async {
    final lapsIds = routine.laps.map((lap) => lap.id).toList();
    final response = await http.post(
      Uri.parse('http://localhost:8000/clients/$clientId/routines/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'date': routine.date,
        'comment': routine.comments,
        'trainer': routine.trainer,
        'laps': lapsIds,
      }),
    );
    if (response.statusCode != 200) {}
  }

  static const String baseUrl = 'http://localhost:8000';

  static Future<void> addExercisetoLap(String lapId, Exercise exercise) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lap/$lapId/exercise/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'exercise_preset_id': exercise.presetId,
        'duration': exercise.duration,
        'reps': exercise.reps,
        'weight': exercise.weight,
        'machine_id': exercise.machine,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add exercise to lap');
    }
  }

  static Future<String> addLapToDraft(String draftId, Lap lap) async {
    final response = await http.post(
      Uri.parse('$baseUrl/draft/$draftId/lap/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'exercises': lap.exercises?.map((exercise) => exercise.id).toList(),
        'sets': lap.sets,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add lap to draft');
    }
    return response.body;
  }

  static Future<List<Lap>> getRoutineLaps(String routineId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/laps/routines/$routineId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get routine laps');
    }
    final List<dynamic> lapsData = json.decode(response.body);
    List<Lap> laps = [];
    for (var lapData in lapsData) {
      List<String> exerciseIds = List<String>.from(lapData['exercises']);
      List<Exercise> exercises = [];
      for (var exerciseId in exerciseIds) {
        final exerciseResponse = await http.get(
          Uri.parse('$baseUrl/exercises/$exerciseId'),
        );
        if (exerciseResponse.statusCode == 200) {
          final Map<String, dynamic> exerciseData =
              json.decode(exerciseResponse.body);
          exercises.add(Exercise(
            id: exerciseData['id'],
            presetId: exerciseData['preset'],
            name: exerciseData['name'],
            duration: exerciseData['duration'],
            reps: exerciseData['reps'],
            weight: exerciseData['weight'],
            machine: exerciseData['machine'],
          ));
        }
      }
      laps.add(Lap(
        id: lapData['id'],
        exercises: exercises,
        sets: lapData['sets'],
      ));
    }
    return laps;
  }

  static Future<void> createRoutineFromDraft(
      Routine routine, String clientId, String draftId) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/clients/$clientId/routines/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'routine': {
          'date': routine.date,
          'comment': routine.comments,
          'trainer': routine.trainer,
          'laps': routine.laps
        },
        'draft_id': draftId,
      }),
    );

    if (response.statusCode == 200) {
    } else {}
  }

  static Future<Draft?> getDraftOfClient(String clientId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/drafts/client/$clientId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      return null;
    }
    final data = json.decode(response.body);
    List<Lap> laps = [];
    for (var lapId in data['laps']) {
      final lapResponse = await http.get(
        Uri.parse('$baseUrl/laps/$lapId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (lapResponse.statusCode == 200) {
        final lapData = json.decode(lapResponse.body);
        List<Exercise> exercises = [];

        for (var exerciseId in lapData['exercises']) {
          final exerciseResponse = await http.get(
            Uri.parse('$baseUrl/exercises/$exerciseId'),
            headers: {'Content-Type': 'application/json'},
          );

          if (exerciseResponse.statusCode == 200) {
            final exerciseData = json.decode(exerciseResponse.body);
            exercises.add(Exercise(
              id: exerciseId,
              presetId: exerciseData['preset'],
              name: exerciseData['name'],
              duration: exerciseData['duration'],
              reps: exerciseData['reps'],
              weight: exerciseData['weight'],
              machine: exerciseData['machine'],
            ));
          }
        }

        laps.add(Lap(
          id: lapId,
          exercises: exercises,
          sets: lapData['sets'],
        ));
      }
    }

    return Draft(
      id: data['id'],
      laps: laps,
    );
  }

  static Future<String> createDraft(Draft draft, String clientId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/drafts/client/$clientId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'laps': draft.laps.map((lap) {
          return {
            'exercises': lap.exercises?.map((exercise) => exercise.id).toList(),
            'sets': lap.sets,
          };
        }).toList(),
      }),
    );
    if (response.statusCode == 400) {
      throw Exception('Client already has a draft');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to create draft');
    }
    return response.body;
  }

  static Future<List<Exercise>> getExercisesFromLap(String lapId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/laps/exercises/$lapId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get exercises from lap');
    }
    final List<dynamic> exercisesData = json.decode(response.body);
    return exercisesData.map((exerciseData) {
      return Exercise(
        id: exerciseData['id'],
        presetId: exerciseData['preset'],
        name: exerciseData['name'],
        duration: exerciseData['duration'],
        reps: exerciseData['reps'],
        weight: exerciseData['weight'],
        machine: exerciseData['machine'],
      );
    }).toList();
  }

  static Future<Lap> getLap(String lapId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/laps/$lapId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get lap');
    }
    final lapData = json.decode(response.body);
    List<String> exerciseIds = List<String>.from(lapData['exercises']);
    List<Exercise> exercises = [];
    for (var exerciseId in exerciseIds) {
      final exerciseResponse = await http.get(
        Uri.parse('$baseUrl/exercises/$exerciseId'),
      );
      if (exerciseResponse.statusCode == 200) {
        final Map<String, dynamic> exerciseData =
            json.decode(exerciseResponse.body);
        exercises.add(Exercise(
          id: exerciseData['id'],
          presetId: exerciseData['preset'],
          name: exerciseData['name'],
          duration: exerciseData['duration'],
          reps: exerciseData['reps'],
          weight: exerciseData['weight'],
          machine: exerciseData['machine'],
        ));
      }
    }
    return Lap(
      id: lapData['id'],
      exercises: exercises,
      sets: lapData['sets'],
    );
  }

  static Future<void> updateLap(String lapId, int sets) async {
    final response = await http.put(
        Uri.parse('http://localhost:8000/lap/$lapId/sets/'),
        headers: {'Content-Type': 'application/json'},
        body: sets.toString());
    if (response.statusCode != 200) {}
  }

  static Future<void> deleteExerciseFromLap(
      String lapId, String exerciseId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8000/exercises/$exerciseId/lap/$lapId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete exercise from lap');
    }
  }
}
