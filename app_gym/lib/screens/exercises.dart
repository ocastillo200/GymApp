import 'package:app_gym/models/exercise_preset.dart';
import 'package:flutter/material.dart';
import 'package:app_gym/screens/add_exercise_screen.dart';
import 'package:app_gym/services/database_service.dart';

// ignore: constant_identifier_names
enum ViewType { Grid, List }

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<ExercisePreset> _exercises = [];
  final Map<String, List<String>> _exerciseMachineNames = {};
  bool _isLoading = true;
  ViewType _viewType = ViewType.Grid;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    try {
      final exercises = await DatabaseService.getExercises();
      setState(() {
        _exercises = exercises;
        _mapExerciseMachineNames();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _mapExerciseMachineNames() async {
    for (var exercise in _exercises) {
      List<String> machineNames = [];
      for (var machineId in exercise.machines) {
        String machineName = await DatabaseService.getMachineName(machineId);
        machineNames.add(machineName);
      }
      _exerciseMachineNames[exercise.id] = machineNames;
    }
  }

  List<ExercisePreset> _filteredExercises(String searchText) {
    return _exercises
        .where((exercise) =>
            exercise.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent.shade400,
        title: _viewType == ViewType.Grid
            ? const Text('Ejercicios',
                style: TextStyle(fontFamily: 'Product Sans'))
            : TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar ejercicios',
                  hintStyle: TextStyle(
                      color: Colors.white70, fontFamily: 'Product Sans'),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {});
                },
              ),
        actions: [
          IconButton(
            icon: _viewType == ViewType.Grid
                ? const Icon(Icons.view_list)
                : const Icon(Icons.view_module),
            onPressed: () {
              setState(() {
                _viewType =
                    _viewType == ViewType.Grid ? ViewType.List : ViewType.Grid;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _viewType == ViewType.Grid
                      ? _buildGridView()
                      : _buildListView(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExerciseScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGridView() {
    final filteredExercises = _filteredExercises(_searchController.text);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = filteredExercises[index];
        final machineNames = _exerciseMachineNames[exercise.id] ?? [];
        return _buildExerciseCard(exercise, machineNames);
      },
    );
  }

  Widget _buildListView() {
    final filteredExercises = _filteredExercises(_searchController.text);
    return ListView.builder(
      itemCount: filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = filteredExercises[index];
        final machineNames = _exerciseMachineNames[exercise.id] ?? [];
        return _buildExerciseCard(exercise, machineNames);
      },
    );
  }

  Widget _buildExerciseCard(
      ExercisePreset exercise, List<String> machineNames) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.fitness_center,
                color: Colors.blueAccent,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                exercise.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Product Sans',
                ),
              ),
              if (machineNames.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  'Equipamiento: ${machineNames.join(', ')}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Product Sans',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
