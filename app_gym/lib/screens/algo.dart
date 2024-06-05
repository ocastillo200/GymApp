import 'package:app_gym/models/draft.dart';
import 'package:app_gym/models/exercise.dart';
import 'package:app_gym/models/exercise_preset.dart';
import 'package:app_gym/models/lap.dart';
import 'package:app_gym/models/machine.dart';
import 'package:app_gym/models/routine.dart';
import 'package:flutter/material.dart';
import 'package:app_gym/services/database_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

class FinishedLap extends StatefulWidget {
  final String lapId;

  FinishedLap({
    super.key,
    required this.lapId,
  });

  @override
  State<StatefulWidget> createState() => _FinishedLapState();
}

class _FinishedLapState extends State<FinishedLap> {
  List<Exercise> _exercises = [];
  int sets = 0;

  @override
  void initState() {
    super.initState();
    _fetchLap();
  }

  Future<void> _fetchLap() async {
    Lap lap = await DatabaseService.getLap(widget.lapId.replaceAll('"', ''));
    setState(() {
      sets = lap.sets;
      _exercises = lap.exercises!.cast<Exercise>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ExpansionTile(
            title: const Text(
              'Circuito finalizado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.repeat,
                  size: 35.0,
                ),
                Text(
                  "$sets", // Texto que muestra el número de series
                  style: const TextStyle(
                    fontSize: 12, // Tamaño del texto
                    color: Colors.black, // Color del texto
                    fontWeight: FontWeight.bold, // Estilo del texto
                  ),
                ),
              ],
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (exercise.reps != 0 ||
                            exercise.duration != 0 ||
                            exercise.weight != 0 ||
                            exercise.machine != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exercise.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              if (exercise.reps != 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text('Repeticiones: ${exercise.reps}'),
                                ),
                              if (exercise.duration != 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                      'Duración: ${exercise.duration} minutos'),
                                ),
                              if (exercise.weight != 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text('Peso: ${exercise.weight} kg'),
                                ),
                              if (exercise.machine != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text('Máquina: ${exercise.machine}'),
                                ),
                              const SizedBox(height: 8.0),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
  final _durationController = TextEditingController();
  final _weightController = TextEditingController();
  final _commentsController = TextEditingController();
  bool? result = false;

  final List<Exercise> _currentExercises = [];
  final List<String> _completedLaps = [];
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
      setState(() {
        _draft = draft;
        _completedLaps.addAll(draft.laps as Iterable<String>);
      });
    }
  }

  Future<void> _addExercise(Exercise addedExercise) async {
    String idDraft = _draft.id;
    if (idDraft.isEmpty) {
      idDraft = await DatabaseService.createDraft(_draft, widget.clientId);
      _draft = (await DatabaseService.getDraftOfClient(widget.clientId))!;
    }
    setState(() {
      _currentExercises.add(addedExercise);
    });
  }

  Future<void> _finalizeLap() async {
    if (_currentExercises.isEmpty) return;
    String lapId = await DatabaseService.addLapToDraft(
        _draft.id, Lap(exercises: _currentExercises, id: "", sets: 1));
    setState(() {
      _completedLaps.add(lapId);
      _currentExercises.clear();
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
                                        labelText: "Ejercicio",
                                        hintText: "Selecciona un ejercicio",
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _nameController = value!;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor selecciona un ejercicio';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownSearch<String>(
                                    enabled: true,
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
                                        labelText: "Máquina",
                                        hintText: "Selecciona una máquina",
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _machineController = value!;
                                      });
                                    },
                                  ),
                                ),
                                TextFormField(
                                  controller: _repsController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Repeticiones',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa las repeticiones';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _durationController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Duración (minutos)',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa la duración';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Peso (kg)',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa el peso';
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
                                          weight: double.parse(
                                              _weightController.text),
                                          reps: int.parse(_repsController.text),
                                          duration: int.parse(
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
                if (_currentExercises.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentExercises.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center),
                          title: Text(_currentExercises[index].name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _currentExercises.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _finalizeLap();
                    },
                    child: const Text('Finalizar circuito'),
                  ),
                ),
                if (_completedLaps.isNotEmpty)
                  Column(
                    children: _completedLaps
                        .map(
                          (lapId) => FinishedLap(
                            lapId: lapId,
                          ),
                        )
                        .toList(),
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
                            firstDate: DateTime(today.year, today.month - 1),
                            lastDate: today,
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
                      Navigator.pop(context, false);
                    },
                  ),
                  TextButton(
                    child: const Text('Aceptar'),
                    onPressed: () async {
                      Routine routine = Routine(
                        id: '',
                        date: date.toString().substring(0, 10),
                        comments: _commentsController.text,
                        trainer: 'Integrar con sesion',
                        laps: [],
                      );
                      DatabaseService.createRoutineFromDraft(
                          routine, widget.clientId, _draft.id);
                      setState(() {
                        _currentExercises.clear();
                        _completedLaps.clear();
                        _commentsController.clear();
                      });
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
            });
          }
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
