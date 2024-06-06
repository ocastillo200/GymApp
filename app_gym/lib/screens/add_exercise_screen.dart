import 'package:app_gym/models/exercise_preset.dart';
import 'package:app_gym/models/machine.dart';
import 'package:app_gym/services/database_service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
//import 'package:app_gym/models/exercise.dart';
//import 'package:app_gym/services/database_service.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<Machine> _machineController = [];
  // ignore: non_constant_identifier_names
  List<Machine> machine_suggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchMachines();
  }

  Future<void> _fetchMachines() async {
    final exercises = await DatabaseService.getMachines();
    setState(() {
      machine_suggestions = exercises;
    });
  }

  List<String> get suggestions =>
      machine_suggestions.map((e) => e.name).toList();
  bool compareMachines(Machine a, Machine b) {
    return a.id == b.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent.shade400,
        title: const Text(
          'Añadir ejercicio ',
          style: TextStyle(fontFamily: 'Product Sans'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nombre del ejercicio',
                    labelStyle: TextStyle(fontFamily: 'Product Sans')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresar nombre';
                  }
                  return null;
                },
              ),
              DropdownSearch<Machine>.multiSelection(
                asyncItems: (String? text) async {
                  return Future.value(machine_suggestions
                      .where((element) => element.name
                          .toLowerCase()
                          .contains(text?.toLowerCase() ?? ''))
                      .toList());
                },
                enabled: true,
                itemAsString: (Machine? machine) => machine?.name ?? '',
                popupProps: const PopupPropsMultiSelection.menu(
                  showSelectedItems: true,
                  showSearchBox: false,
                  constraints: BoxConstraints(maxHeight: 400),
                ),
                compareFn: compareMachines,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    labelText: "Seleccionar máquina",
                  ),
                ),
                onChanged: (List<Machine> selectedMachines) {
                  setState(() {
                    _machineController = selectedMachines;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ExercisePreset exercisePreset = ExercisePreset(
                      id: '',
                      name: _nameController.text,
                      machines: _machineController.map((e) => e.id).toList(),
                    );
                    DatabaseService.addExercisePreset(exercisePreset);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Agregar ejercicio',
                    style: TextStyle(fontFamily: 'Product Sans')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
