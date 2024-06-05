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
  final String _machineController = '';
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresar nombre';
                  }
                  return null;
                },
              ),
              DropdownSearch<String>(
                selectedItem: _machineController,
                items: suggestions,
                popupProps: const PopupProps.menu(
                    showSelectedItems: true,
                    showSearchBox: false,
                    constraints: BoxConstraints(maxHeight: 400)),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Seleccionar máquina",
                  ),
                ),
                onChanged: print,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccionar máquina';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ExercisePreset exercisePreset = ExercisePreset(
                      id: '',
                      name: _nameController.text,
                      machines: [_machineController],
                    );
                    String response = await DatabaseService.addExercisePreset(exercisePreset);
                    print(response);
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
