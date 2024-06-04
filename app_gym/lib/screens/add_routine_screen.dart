import 'package:app_gym/models/exercise.dart';
import 'package:app_gym/models/exercise_preset.dart';
import 'package:app_gym/models/lap.dart';
import 'package:app_gym/models/machine.dart';
import 'package:app_gym/models/routine.dart';
import 'package:flutter/material.dart';
import 'package:app_gym/services/database_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddRoutineScreen extends StatefulWidget {
  final String clientId;
  final Function updateRoutineList;

  const AddRoutineScreen(
      {super.key, required this.clientId, required this.updateRoutineList});

  @override
  // ignore: library_private_types_in_public_api
  _AddRoutineScreenState createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _repsController = TextEditingController();
  final _machineController = TextEditingController();
  final _commentsController = TextEditingController();
  final _durationController = TextEditingController();
  final _weightController = TextEditingController();
  bool? result = false;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _fetchMachines();
  }

  final List<Exercise> _exercises = [];
  final List<Lap> _laps = [];
  // ignore: non_constant_identifier_names
  List<ExercisePreset> exercises_suggestions = [];
  List<Machine> machine_suggestions = [];

  Future<void> _fetchExercises() async {
    final exercises = await DatabaseService.getExercises();
    setState(() {
      exercises_suggestions = exercises;
    });
  }

  Future<void> _fetchMachines() async {
    final exercises = await DatabaseService.getMachines();
    setState(() {
      machine_suggestions = exercises;
    });
  }

  List<String> get Esuggestions =>
      exercises_suggestions.map((e) => e.name).toList();

  List<String> get Msuggestions =>
      machine_suggestions.map((e) => e.name).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir nueva rutina'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color.fromARGB(255, 212, 212, 212),
                        width: 2),
                  ),
                  child: ExpansionTile(
                      title: const Text('Nuevo ejercicio'),
                      leading: const Icon(Icons.add),
                      initiallyExpanded: false,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownSearch<String>(
                                    selectedItem: _nameController.text,
                                    items: Esuggestions,
                                    popupProps: const PopupProps.menu(
                                        showSelectedItems: true,
                                        showSearchBox: false,
                                        constraints:
                                            BoxConstraints(maxHeight: 400)),
                                    dropdownDecoratorProps:
                                        const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Seleccionar ejercicio",
                                      ),
                                    ),
                                    onChanged: print,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Seleccionar ejercicio';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                DropdownSearch<String>(
                                  selectedItem: _machineController.text,
                                  items: Msuggestions,
                                  popupProps: const PopupProps.menu(
                                      showSelectedItems: true,
                                      showSearchBox: false,
                                      constraints:
                                          BoxConstraints(maxHeight: 400)),
                                  dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
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
                                TextFormField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Peso',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese el peso del ejercicio';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _repsController,
                                  decoration: const InputDecoration(
                                    labelText: 'Repeticiones',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese la cantidad de repeticiones';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _durationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Duracion',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese la duracion del ejercicio';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _exercises.add(Exercise(
                                            id: '',
                                            name: _nameController.text,
                                            weight: double.parse(
                                                _weightController.text),
                                            reps:
                                                int.parse(_repsController.text),
                                            duration: int.parse(
                                                _durationController.text),
                                            machine: ""));
                                      });
                                      _nameController.clear();
                                      _machineController.clear();
                                      _repsController.clear();

                                      final exercise = Exercise(
                                        id: '',
                                        name: _nameController.text,
                                        weight: double.parse(
                                            _weightController.text),
                                        reps: int.parse(_repsController.text),
                                        duration:
                                            int.parse(_durationController.text),
                                        machine: _machineController.text,
                                      );
                                      Routine routine = Routine(
                                          id: "",
                                          comments: "",
                                          date: DateTime.now().toString(),
                                          laps: _laps,
                                          trainer: "manejar con sesiones");
                                      DatabaseService.addRoutine(
                                          routine, widget.clientId);
                                      Lap lap = Lap(
                                          exercises: _exercises,
                                          id: "",
                                          sets: 1);
                                      //       DatabaseService.addLapToRoutine( , lap)
                                      //       DatabaseService.addExercisetoLap( , exercise);
                                    }
                                  },
                                  child: const Text('Agregar ejercicio'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                        title: Text(_exercises[index].name),
                        children: [
                          Card(
                            child: ListTile(
                              title: Text(_exercises[index].name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirmar eliminación'),
                                            content: const Text(
                                                '¿Estás seguro de que quieres eliminar este ejercicio?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Cancelar'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Eliminar'),
                                                onPressed: () {
                                                  setState(() {
                                                    _exercises.removeAt(index);
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _laps.add(Lap(exercises: _exercises, id: "", sets: 1));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Terminar circuito'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DateTime? date = DateTime.now();
          result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title:
                    const Text('¿Estás seguro que quieres añadir la rutina?'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      TextFormField(
                        controller: _commentsController,
                        decoration: const InputDecoration(
                          labelText: 'Comentario',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un comentario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime today = DateTime.now();
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: today,
                            firstDate: DateTime(today.year,
                                today.month - 1), // Primer día del mes anterior
                            lastDate: today, // Hoy
                          );
                          if (selectedDate != null) {
                            setState(() {
                              date = selectedDate;
                            });
                          }
                        },
                        child: const Text('Seleccionar fecha'),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.pop(context,
                          false); // Devolver false para indicar que no se realizó ninguna actualización
                    },
                  ),
                  TextButton(
                    child: const Text('Aceptar'),
                    onPressed: () async {
                      final routine = await DatabaseService.addRoutine(
                          Routine(
                              id: '',
                              date: date.toString(),
                              laps: _laps,
                              comments: _commentsController.text,
                              trainer: ""),
                          widget.clientId);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              );
            },
          );
          if (result == true) {
            setState(() {
              widget.updateRoutineList();
              _exercises.clear();
              _commentsController.clear();
            });
            ();
          }
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
