import 'package:app_gym/models/draft.dart';
import 'package:app_gym/models/exercise.dart';
import 'package:app_gym/models/exercise_preset.dart';
import 'package:app_gym/models/lap.dart';
import 'package:app_gym/models/machine.dart';
import 'package:app_gym/models/routine.dart';
import 'package:flutter/material.dart';
import 'package:app_gym/services/database_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

// ignore: must_be_immutable
class FinishedLap extends StatefulWidget {
  final String lapId;

  int items = 0;
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
    sets = lap.sets;

    _exercises = lap.exercises!.cast<Exercise>();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ExpansionTile(
            title: const Text(
              'Circuito finalizado',
              style: TextStyle(
                  fontFamily: 'Product Sans', fontWeight: FontWeight.bold),
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
                    fontFamily: 'Product Sans',
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
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final exercise in _exercises!)
                          if (exercise.reps != 0 ||
                              exercise.duration != 0 ||
                              exercise.weight != 0 ||
                              exercise.machine != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exercise.name,
                                    style: const TextStyle(
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.bold)),
                                if (exercise.reps != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                        'Repeticiones: ${exercise.reps}',
                                        style: const TextStyle(
                                            fontFamily: 'Product Sans')),
                                  ),
                                if (exercise.duration != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                        'Duración: ${exercise.duration} minutos',
                                        style: const TextStyle(
                                            fontFamily: 'Product Sans')),
                                  ),
                                if (exercise.weight != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text('Peso: ${exercise.weight} kg',
                                        style: const TextStyle(
                                            fontFamily: 'Product Sans')),
                                  ),
                                if (exercise.machine != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text('Máquina: ${exercise.machine}',
                                        style: const TextStyle(
                                            fontFamily: 'Product Sans')),
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

  final String name;

  const AddRoutineScreen(
      {super.key, required this.clientId, required this.name});

  @override
  _AddRoutineScreenState createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  String _nameController = "";
  String _machineController = "";
  final _repsController = TextEditingController();
  final _commentsController = TextEditingController();
  final _durationController = TextEditingController();
  final _weightController = TextEditingController();
  final _setsController = TextEditingController();
  bool? result = false;

  final List<Exercise> _exercises = [];
  final List<Exercise> _lapExercises = [];
  List<dynamic> _laps = [];
  Draft _draft = Draft(id: '', laps: []);
  // ignore: non_constant_identifier_names
  List<ExercisePreset> exercises_suggestions = [];
  // ignore: non_constant_identifier_names
  List<Machine> machine_suggestions = [];
  final List<String> _finishedLaps = [];
  Map<String, List<String>> exerciseMachines = {};
  List<String> filteredMachines = [];
  String? _selectedExercise;
  String? _selectedMachine;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _fetchMachines();
    _fetchDraft();
  }

  Future<void> _fetchExercises() async {
    // Obtener todas las máquinas en una sola llamada
    final machines = await DatabaseService.getMachines();

    // Crear un mapa de máquinas para una búsqueda rápida por ID
    final machineMap = {for (var machine in machines) machine.id: machine};

    final exercises = await DatabaseService.getExercises();
    List<ExercisePreset> filteredExercises = [];
    Map<String, List<String>> localExerciseMachines = {};

    for (var exercise in exercises) {
      bool shouldAddExercise = true;
      List<String> machineNames = [];

      for (var machineId in exercise.machines) {
        var machine = machineMap[machineId];
        if (machine == null || machine.available == 0) {
          shouldAddExercise = false;
          break;
        }
        machineNames.add(machine.name);
      }

      if (shouldAddExercise) {
        filteredExercises.add(exercise);
        localExerciseMachines[exercise.name] = machineNames;
      }
    }

    setState(() {
      exercises_suggestions = filteredExercises;
      exerciseMachines = localExerciseMachines;
    });
  }

  void _onExerciseChanged(String? selectedExercise) {
    setState(() {
      _selectedExercise = selectedExercise;
      filteredMachines = selectedExercise != null
          ? exerciseMachines[selectedExercise] ?? []
          : [];
      _selectedMachine = null;
    });
  }

  Future<void> _fetchMachines() async {
    final machines = await DatabaseService.getMachines();
    setState(() {
      for (int i = 0; i < machines.length; i++) {
        if (machines[i].available == 0) {
          machines.removeAt(i);
        }
      }
      machine_suggestions = machines;
    });
  }

  Future<void> _fetchDraft() async {
    Draft? draft = await DatabaseService.getDraftOfClient(widget.clientId);
    if (draft != null) {
      setState(() {
        _draft = draft;
        _laps = draft.laps.map((lap) => lap.id).toList();
      });
      if (_laps.isNotEmpty) {
        String lastLapId = _laps.last.replaceAll('"', '');
        Lap lap = await DatabaseService.getLap(lastLapId);

        _exercises.clear();
        _lapExercises.clear();
        _lapExercises.addAll(lap.exercises!.cast<Exercise>());
        _exercises.addAll(_lapExercises);
      }
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> _DeleteExercise(int index) async {
    setState(() {
      DatabaseService.deleteExerciseFromLap(_laps.last.replaceAll('"', ''),
          _exercises[index].id.replaceAll('"', ''));
      _exercises.removeAt(index);
      if (_exercises.isEmpty) {
        DatabaseService.deleteLap(_laps.last.replaceAll('"', ''), _draft.id);
        _laps.removeLast();
      }
    });
  }

  Future<void> finalizeCircuit() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes finalizar un circuito vacío.',
              style: TextStyle(fontFamily: 'Product Sans')),
        ),
      );
      return;
    }

    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Seguro que deseas finalizar el circuito?',
              style: TextStyle(fontFamily: 'Product Sans')),
          content: Form(
            key: _formKey3,
            child: TextFormField(
              controller: _setsController,
              decoration: const InputDecoration(
                labelText: 'Repeticiones del circuito',
              ),
              validator: (value) {
                if (value == null || value.isEmpty || int.parse(value) <= 0) {
                  return 'Ingrese una cantidad válida de repeticiones.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar',
                  style: TextStyle(fontFamily: 'Product Sans')),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Agregar',
                  style: TextStyle(fontFamily: 'Product Sans')),
              onPressed: () async {
                if (_formKey3.currentState!.validate()) {
                  if (_setsController.text.isNotEmpty) {
                    Navigator.of(context).pop(true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor ingrese la cantidad de sets.',
                            style: TextStyle(fontFamily: 'Product Sans')),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
    if (result == true) {
      await DatabaseService.updateLap(
          _laps.last.replaceAll('"', ''), int.parse(_setsController.text));
      setState(() {
        _finishedLaps.add(_laps.last.replaceAll('"', ''));
        _exercises.clear();
      });
    }
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
      _laps.add(lapId.replaceAll('"', ''));
      await DatabaseService.addExercisetoLap(
          lapId.replaceAll('"', ''), addedExercise);
    } else if (_laps.isEmpty) {
      Lap newLap = Lap(exercises: [], id: "", sets: 0);
      String newLapId = await DatabaseService.addLapToDraft(_draft.id, newLap);
      _laps.add(newLapId.replaceAll('"', ''));
      DatabaseService.addExercisetoLap(
          newLapId.replaceAll('"', ''), addedExercise);
    } else {
      Lap lap = await DatabaseService.getLap(_laps.last.replaceAll('"', ''));
      if (lap.sets != 0) {
        Lap newLap = Lap(exercises: [], id: "", sets: 0);
        String newLapId =
            await DatabaseService.addLapToDraft(_draft.id, newLap);
        _laps.add(newLapId.replaceAll('"', ''));
        DatabaseService.addExercisetoLap(
            newLapId.replaceAll('"', ''), addedExercise);
      } else {
        DatabaseService.addExercisetoLap(lap.id, addedExercise);
      }
    }
    setState(() {
      _exercises.add(addedExercise);
    });
    await _fetchDraft();
  }

  List<String> get Esuggestions =>
      exercises_suggestions.map((e) => e.name).toList();

  List<String> get Msuggestions =>
      machine_suggestions.map((e) => e.name).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent.shade400,
        title: const Text('Añadir nueva rutina',
            style: TextStyle(fontFamily: 'Product Sans', color: Colors.white)),
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
                      title: const Text('Nuevo ejercicio',
                          style: TextStyle(fontFamily: 'Product Sans')),
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
                                    selectedItem: _selectedExercise,
                                    items: Esuggestions,
                                    popupProps: const PopupProps.menu(
                                      showSelectedItems: true,
                                      showSearchBox: false,
                                      constraints:
                                          BoxConstraints(maxHeight: 400),
                                    ),
                                    dropdownDecoratorProps:
                                        const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Seleccionar ejercicio",
                                      ),
                                    ),
                                    onChanged: _onExerciseChanged,
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
                                  enabled: filteredMachines.isNotEmpty,
                                  items: filteredMachines,
                                  popupProps: const PopupProps.menu(
                                    showSelectedItems: true,
                                    showSearchBox: false,
                                    constraints: BoxConstraints(maxHeight: 400),
                                  ),
                                  dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: "Seleccionar máquina",
                                    ),
                                  ),
                                  onChanged: (String? name) =>
                                      _machineController = name!,
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Peso (kg)',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return null;
                                    }
                                    final double? weight =
                                        double.tryParse(value);
                                    if (weight == null || weight <= 0) {
                                      return 'Ingrese un peso válido';
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
                                    if (_durationController.text.isEmpty &&
                                        (value == null || value.isEmpty)) {
                                      return 'Ingrese la cantidad de repeticiones o la duración';
                                    }
                                    if (value != null && value.isNotEmpty) {
                                      final int? reps = int.tryParse(value);
                                      if (reps == null || reps <= 0) {
                                        return 'Ingrese un número válido de repeticiones';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _durationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Duración (minutos)',
                                  ),
                                  validator: (value) {
                                    if (_repsController.text.isEmpty &&
                                        (value == null || value.isEmpty)) {
                                      return 'Ingrese la cantidad de repeticiones o la duración';
                                    }
                                    if (value != null && value.isNotEmpty) {
                                      final int? duration = int.tryParse(value);
                                      if (duration == null || duration <= 0) {
                                        return 'Ingrese una duración válida';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      Exercise addedExercise = Exercise(
                                        id: '',
                                        presetId: exercises_suggestions
                                            .firstWhere((element) =>
                                                element.name ==
                                                _selectedExercise)
                                            .id,
                                        name: _selectedExercise!,
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
                                        machine: _machineController.isEmpty
                                            ? null
                                            : machine_suggestions
                                                .firstWhere((element) =>
                                                    element.name ==
                                                    _machineController)
                                                .id,
                                      );
                                      await _addExercise(addedExercise);
                                      _repsController.clear();
                                      _durationController.clear();
                                      _weightController.clear();
                                    }
                                  },
                                  child: const Text('Agregar ejercicio',
                                      style: TextStyle(
                                          fontFamily: 'Product Sans')),
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
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.fitness_center),
                        subtitle: Text(
                            'Peso: ${_exercises[index].weight} - Repeticiones: ${_exercises[index].reps} - Duración: ${_exercises[index].duration}',
                            style: const TextStyle(fontFamily: 'Product Sans')),
                        title: Text(_exercises[index].name,
                            style: const TextStyle(fontFamily: 'Product Sans')),
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
                                      title: const Text('Confirmar eliminación',
                                          style: TextStyle(
                                              fontFamily: 'Product Sans')),
                                      content: const Text(
                                          '¿Estás seguro de que quieres eliminar este ejercicio?',
                                          style: TextStyle(
                                              fontFamily: 'Product Sans')),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancelar',
                                              style: TextStyle(
                                                  fontFamily: 'Product Sans')),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Eliminar',
                                              style: TextStyle(
                                                  fontFamily: 'Product Sans')),
                                          onPressed: () async {
                                            _DeleteExercise(index);
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
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await finalizeCircuit();
                    },
                    child: const Text('Finalizar circuito',
                        style: TextStyle(fontFamily: 'Product Sans')),
                  ),
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
                title: const Text('¿Estás seguro que quieres añadir la rutina?',
                    style: TextStyle(fontFamily: 'Product Sans')),
                content: Form(
                  key: _formKey2,
                  child: SingleChildScrollView(
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
                          child: const Text('Seleccionar fecha',
                              style: TextStyle(fontFamily: 'Product Sans')),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancelar',
                        style: TextStyle(fontFamily: 'Product Sans')),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  TextButton(
                    child: const Text('Aceptar',
                        style: TextStyle(fontFamily: 'Product Sans')),
                    onPressed: () async {
                      if (_formKey2.currentState!.validate()) {
                        if (_laps.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'No puedes agregar una rutina vacía.',
                                  style: TextStyle(fontFamily: 'Product Sans')),
                            ),
                          );
                          return;
                        }
                        Lap lastlap = await DatabaseService.getLap(
                            _laps.last.replaceAll('"', ''));
                        if (lastlap.sets == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Por favor finaliza el circuito antes de agregar la rutina.',
                                  style: TextStyle(fontFamily: 'Product Sans')),
                            ),
                          );
                          return;
                        }
                        Routine routine = Routine(
                            id: '',
                            date: date.toString().substring(0, 10),
                            comments: _commentsController.text,
                            trainer: widget.name,
                            laps: []);
                        DatabaseService.createRoutineFromDraft(
                            routine, widget.clientId, _draft.id);
                        setState(() {
                          _exercises.clear();
                          _commentsController.clear();
                        });
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ],
              );
            },
          );
          if (result == true) {
            setState(() {
              _exercises.clear();
              _commentsController.clear();
            });
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.done, color: Colors.white),
      ),
    );
  }
}
