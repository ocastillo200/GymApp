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
      return Machine(
        id: machineData['id'],
        name: machineData['name'],
        quantity: machineData['quantity'],
        available: machineData['available'],
      );
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
            id: exerciseData['preset_id'],
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

  static Future<void> addExercisetoLap(String lapId, Exercise exercise) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/lap/$lapId/exercise/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'exercise_preset_id': exercise.id,
        'duration': exercise.duration,
        'reps': exercise.reps,
        'weight': exercise.weight,
        'machine_id': exercise.machine,
      }),
    );
    if (response.statusCode != 200) {}
  }

  static Future<String> addLapToDraft(String draftId, Lap lap) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/draft/$draftId/lap/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'exercises': lap.exercises?.map((exercise) {
          return {
            'preset_id': exercise.id,
            'name': exercise.name,
            'duration': exercise.duration,
            'reps': exercise.reps,
            'weight': exercise.weight,
            'machine': exercise.machine,
          };
        }).toList(),
        'sets': lap.sets,
      }),
    );
    if (response.statusCode != 200) {}
    return response.body;
  }

  static Future<List<Lap>> getRoutineLaps(String routineId) async {
    final laps = <Lap>[];
    final response = await http.get(
      Uri.parse('http://localhost:8000/laps/routines/$routineId'),
    );
    if (response.statusCode == 200) {
      final lapsData = json.decode(response.body);
      for (var lapData in lapsData) {
        laps.add(
          Lap(
            id: lapData['id'],
            exercises: (lapData['exercises'] as List<dynamic>)
                .map<Exercise>((exerciseData) {
              return Exercise(
                id: exerciseData['preset_id'],
                name: exerciseData['name'],
                duration: exerciseData['duration'],
                reps: exerciseData['reps'],
                weight: exerciseData['weight'],
                machine: exerciseData['machine'],
              );
            }).toList(),
            sets: lapData['sets'],
          ),
        );
      }
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
      Uri.parse('http://localhost:8000/drafts/client/$clientId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Draft(
        id: data['id'],
        laps: data['laps'],
      );
    } else {
      return null;
    }
  }

  static Future<String> createDraft(Draft draft, String clientId) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/drafts/client/$clientId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'laps': draft.laps,
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
      Uri.parse('http://localhost:8000/laps/exercises/$lapId'),
    );
    final exercises = <Exercise>[];
    if (response.statusCode == 200) {
      final exercisesData = json.decode(response.body);
      for (var exerciseData in exercisesData) {
        exercises.add(
          Exercise(
            id: exerciseData['preset_id'],
            name: exerciseData['name'],
            duration: exerciseData['duration'],
            reps: exerciseData['reps'],
            weight: exerciseData['weight'],
            machine: exerciseData['machine'],
          ),
        );
      }
    }
    return exercises;
  }

  static Future<Lap> getLap(String lapId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/laps/$lapId'),
    );
    if (response.statusCode == 200) {
      final lapData = json.decode(response.body);
      return Lap(
        id: lapData['id'],
        exercises: (lapData['exercises'] as List<dynamic>)
            .map<Exercise>((exerciseData) {
          return Exercise(
            id: exerciseData['preset_id'],
            name: exerciseData['name'],
            duration: exerciseData['duration'],
            reps: exerciseData['reps'],
            weight: exerciseData['weight'],
            machine: exerciseData['machine'],
          );
        }).toList(),
        sets: lapData['sets'],
      );
    }
    throw Exception('Failed to get lap');
  }

  static Future<void> updateLap(String lapId, int sets) async {
    final response = await http.put(
        Uri.parse('http://localhost:8000/lap/$lapId/sets/'),
        headers: {'Content-Type': 'application/json'},
        body: sets.toString());
    if (response.statusCode != 200) {}
  }

  static Future<String> addExercisePreset(ExercisePreset exercisePreset) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/exercises_preset/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': exercisePreset.name,
        'machine_ids': exercisePreset.machines.toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create exercise preset');
    }

    return response.body;
  }
}
