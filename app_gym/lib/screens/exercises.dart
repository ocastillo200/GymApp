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
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent.shade400,
        title: const Text('Ejercicios',
            style: TextStyle(fontFamily: 'Product Sans')),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _exercises.length,
          itemBuilder: (context, index) {
            final exercise = _exercises[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans'),
                      ),
                      FutureBuilder<List<String>>(
                        future: _getMachineNames(exercise),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(height: 8);
                          } else if (snapshot.hasData) {
                            return Text(snapshot.data!.join(', '),
                                style: const TextStyle(
                                    fontFamily: 'Product Sans'));
                          } else {
                            return const Text(
                                'Error obteniendo los nombres de las máquinas',
                                style: TextStyle(fontFamily: 'Product Sans'));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
