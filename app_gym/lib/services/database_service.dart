import 'dart:convert';
import 'package:app_gym/models/draft.dart';
import 'package:app_gym/models/exercise_preset.dart';
import 'package:app_gym/models/lap.dart';
import 'package:app_gym/models/machine.dart';
import 'package:app_gym/models/trainer.dart';
import 'package:http/http.dart' as http;
import 'package:app_gym/models/exercise.dart';
import 'package:app_gym/models/routine.dart';
import 'package:app_gym/models/client.dart';
import 'package:app_gym/models/user.dart';

class DatabaseService {
  static const String baseUrl =
      'http://localhost:8000'; //modificar ip acorde a la red

  static Future<List<Trainer>> getTrainers() async {
    final response = await http.get(Uri.parse('$baseUrl/trainers/'));
    final trainers = <Trainer>[];
    if (response.statusCode == 200) {
      final trainersData = json.decode(response.body);
      for (var trainerData in trainersData) {
        trainers.add(Trainer(
          id: trainerData['id'],
          name: trainerData['name'],
          clients: trainerData['clients'],
        ));
      }
    }
    return trainers;
  }

  static Future<void> addTrainer(Trainer trainer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trainers/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': trainer.name,
        'clients': trainer.clients,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add trainer');
    }
  }

  static Future<void> deleteTrainer(String trainerId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/trainers/$trainerId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete trainer');
    }
  }

  static Future<void> updateTrainer(Trainer trainer) async {
    final response = await http.put(
      Uri.parse('$baseUrl/trainers/${trainer.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': trainer.name, 'clients': trainer.clients}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update trainer');
    }
  }

  static Future<List<Client>> getClients() async {
    final response = await http.get(Uri.parse(baseUrl));
    final clients = <Client>[];
    if (response.statusCode == 200) {
      final clientsData = json.decode(response.body);
      for (var clientData in clientsData) {
        clients.add(
          Client(
              image: clientData['image'],
              id: clientData['id'],
              name: clientData['name'],
              rut: clientData['rut'],
              health: clientData['health'],
              email: clientData['email'],
              phone: clientData['phone'],
              draft: clientData['draft']),
        );
      }
    }
    return clients;
  }

  static Future<List<ExercisePreset>> getExercises() async {
    final response = await http.get(Uri.parse('$baseUrl/exercises_preset/'));
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
      Uri.parse('http://$baseUrl/api/exercises'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': exercise.name,
      }),
    );

    if (response.statusCode != 200) {}
  }

  static Future<List<Machine>> getMachines() async {
    final response = await http.get(Uri.parse('$baseUrl/machines/'));
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
    final response = await http.get(Uri.parse('$baseUrl/machines/$machineId'));
    if (response.statusCode == 200) {
      final machineData = json.decode(response.body);
      return machineData['name'];
    }
    return '';
  }

  static Future<Machine> getMachine(String machineId) async {
    final response = await http.get(Uri.parse('$baseUrl/machines/$machineId'));

    if (response.statusCode == 200) {
      final machineData = json.decode(response.body);

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
    final response =
        await http.get(Uri.parse('$baseUrl/clients/$clientId/routines'));
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
      Uri.parse('$baseUrl/clients/$clientId/routines/'),
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

  static Future<void> deleteClientRoutine(
      String clientId, String routineId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/clients/$clientId/routines/$routineId/'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete routine');
    }
  }

  static Future<void> createRoutineFromDraft(
      Routine routine, String clientId, String draftId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients/$clientId/routines/'),
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
    final response = await http.put(Uri.parse('$baseUrl/lap/$lapId/sets/'),
        headers: {'Content-Type': 'application/json'}, body: sets.toString());
    if (response.statusCode != 200) {}
  }

  static Future<String> addExercisePreset(ExercisePreset exercisePreset) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exercises_preset/'),
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

  static Future<List<String>> getFinishedLaps(String draftId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/laps/$draftId/drafts'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get draft laps');
    }
    final List<dynamic> lapsJson = jsonDecode(response.body);
    List<String> finishedLaps = [];

    for (var lapJson in lapsJson) {
      if (lapJson['sets'] != 0) {
        finishedLaps.add(lapJson['id']);
      }
    }
    return finishedLaps;
  }

  static Future<void> deleteExerciseFromLap(
      String lapId, String exerciseId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/exercises/$exerciseId/lap/$lapId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete exercise from lap');
    }
  }

  static Future<void> deleteLap(String lapId, String draftId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/laps/$lapId/draft/$draftId/'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete lap');
    }
  }

  static Future<void> deleteDraft(String draftId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/drafts/$draftId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete draft');
    }
  }

  static Future<void> deleteMachine(String machineId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/machines/$machineId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete machine');
    }
  }

  static Future<void> editMachine(Machine machine) async {
    final response = await http.put(
      Uri.parse('$baseUrl/machines/${machine.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': machine.name,
        'quantity': machine.quantity,
        'available': machine.available,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit machine');
    }
  }

  static Future<void> addMachine(Machine machine) async {
    final response = await http.post(
      Uri.parse('$baseUrl/machines/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': machine.name,
        'quantity': machine.quantity,
        'available': machine.available,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add machine');
    }
  }

  static Future<void> addClient(Client client) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'image': client.image,
        'name': client.name,
        'rut': client.rut,
        'health': client.health,
        'email': client.email,
        'phone': client.phone,
        'idDraft': "",
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add client');
    }
  }

  static Future<void> deleteClient(String clientId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$clientId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete client');
    }
  }

  static Future<void> updateClient(Client client) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${client.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': client.name,
        'rut': client.rut,
        'health': client.health,
        'email': client.email,
        'phone': client.phone,
        'idDraft': client.draft?.id,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update client');
    }
  }

  static Future<User?> login(String id, String password) async {
    final uri = Uri.parse('$baseUrl/user/login').replace(
      queryParameters: {
        'id': id,
        'password': password,
      },
    );

    // Send the HTTP GET request
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }
    final data = json.decode(response.body);
    final u = User(
        id: data['id'],
        name: data['name'],
        rut: data['rut'],
        password: data['password'],
        admin: data['admin']);
    return u;
  }
}
