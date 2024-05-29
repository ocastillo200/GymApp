import 'package:app_gym/models/exercise_preset.dart';
import 'package:flutter/material.dart';
import 'package:app_gym/screens/add_exercise_screen.dart';
import 'package:app_gym/services/database_service.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<ExercisePreset> _exercises = [];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    final exercises = await DatabaseService.getExercises();
    setState(() {
      _exercises = exercises;
    });
  }

  Future<List<String>> _getMachineNames(ExercisePreset exercise) async {
    List<String> machineNames = [];
    for (int i = 0; i < exercise.machines.length; i++) {
      String machineName =
          await DatabaseService.getMachineName(exercise.machines[i]);
      machineNames.add(machineName);
    }
    return machineNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
      ),
      body: ListView.builder(
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          return ListTile(
            title: Text(exercise.name),
            subtitle: FutureBuilder<List<String>>(
              future: _getMachineNames(exercise),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(' ');
                } else if (snapshot.hasData) {
                  return Text(snapshot.data!.join(', '));
                } else {
                  return const Text(
                      'Error obteniendo los nombres de las máquinas');
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExerciseScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
