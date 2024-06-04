import 'package:app_gym/models/draft.dart';
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
  _AddRoutineScreenState createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nameController = "";
  String _machineController = "";
  final _repsController = TextEditingController();
  final _commentsController = TextEditingController();
  final _durationController = TextEditingController();
  final _weightController = TextEditingController();
  final _setsController = TextEditingController();
  bool? result = false;

  final List<Exercise> _exercises = [];
  List<dynamic> _laps = [];
  Draft _draft = Draft(id: '', laps: []);
  List<ExercisePreset> exercises_suggestions = [];
  List<Machine> machine_suggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _fetchMachines();
    _fetchDraft();
  }

  Future<void> _fetchExercises() async {
    final exercises = await DatabaseService.getExercises();
    setState(() {
      exercises_suggestions = exercises;
    });
  }

  Future<void> _fetchMachines() async {
    final machines = await DatabaseService.getMachines();
    setState(() {
      machine_suggestions = machines;
    });
  }

  Future<void> _fetchDraft() async {
    Draft? draft = await DatabaseService.getDraftOfClient(widget.clientId);
    if (draft != null) {
      _draft = draft;
      _laps = draft.laps;
      _exercises.clear();
      for (var lap in _laps) {
        Lap _lap = await DatabaseService.getLap(lap);
        _exercises.addAll(_lap.exercises!.cast<Exercise>());
      }
    }
    setState(() {});
  }

  Future<void> _addExercise(Exercise addedExercise) async {
    String idDraft = _draft.id;
    if (idDraft.isEmpty) {
      idDraft = await DatabaseService.createDraft(_draft, widget.clientId);
      Draft? draft = await DatabaseService.getDraftOfClient(widget.clientId);
      _draft = draft!;
      Lap lap = Lap(exercises: _exercises, id: "", sets: 0);
      String lapId =
          await DatabaseService.addLapToDraft(idDraft.replaceAll('"', ''), lap);
      _laps.add(lapId);
      await DatabaseService.addExercisetoLap(
          lapId.replaceAll('"', ''), addedExercise);
    } else {
      Lap lap = await DatabaseService.getLap(_laps.last.replaceAll('"', ''));
      if (lap.sets != 0) {
        Lap newLap = Lap(exercises: [], id: "", sets: 0);
        String newLapId =
            await DatabaseService.addLapToDraft(_draft.id, newLap);
        _laps.add(newLapId);
        DatabaseService.addExercisetoLap(
            newLapId.replaceAll('"', ''), addedExercise);
      } else {
        DatabaseService.addExercisetoLap(lap.id, addedExercise);
      }
    }
    setState(() {
      _exercises.add(addedExercise);
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
                                    enabled: true,
                                    selectedItem: _nameController,
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
                                    onChanged: (String? name) =>
                                        _nameController = name!,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Seleccionar ejercicio';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                DropdownSearch<String>(
                                  selectedItem: _machineController,
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
                                  onChanged: (String? name) =>
                                      _machineController = name!,
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
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      Exercise addedExercise = Exercise(
                                          id: exercises_suggestions
                                              .firstWhere((element) =>
                                                  element.name ==
                                                  _nameController)
                                              .id,
                                          name: _nameController,
                                          weight: _weightController.text.isEmpty
                                              ? 0
                                              : double.parse(
                                                  _weightController.text),
                                          reps: _repsController.text.isEmpty
                                              ? 0
                                              : int.parse(_repsController.text),
                                          duration:
                                              _durationController.text.isEmpty
                                                  ? 0
                                                  : int.parse(
                                                      _durationController.text),
                                          machine: machine_suggestions
                                              .firstWhere((element) =>
                                                  element.name ==
                                                  _machineController)
                                              .id);
                                      await _addExercise(addedExercise);
                                      _repsController.clear();
                                      _durationController.clear();
                                      _weightController.clear();
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
                                                onPressed: () async {
                                                  // Elimina el ejercicio de la base de datos
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
                          )
                        ]);
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_exercises.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('No puedes finalizar un circuito vacío.'),
                          ),
                        );
                        return;
                      }
                      bool? result = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                                '¿Seguro que deseas finalizar el circuito?'),
                            content: TextFormField(
                              controller: _setsController,
                              decoration: const InputDecoration(
                                labelText: 'Repeticiones del circuito',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese la cantidad de sets';
                                }
                                return null;
                              },
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: const Text('Agregar'),
                                onPressed: () {
                                  if (_setsController.text.isNotEmpty) {
                                    Navigator.of(context).pop(true);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Por favor ingrese la cantidad de sets.'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                      if (result == true) {
                        int sets = int.parse(_setsController.text);
                        String lapId = _laps.last.replaceAll('"', '');
                        await DatabaseService.updateLap(lapId, sets);
                        _setsController.clear();
                        setState(() {
                          _exercises.clear();
                        });
                      }
                    },
                    child: const Text('Finalizar circuito'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
