import 'package:app_gym/models/exercise.dart';
import 'package:flutter/material.dart';
//import 'package:app_gym/models/exercise.dart';
//import 'package:app_gym/services/database_service.dart';

class AddRoutineScreen extends StatefulWidget {
  @override
  _AddRoutineScreenState createState() => _AddRoutineScreenState();
}
class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _repsController = TextEditingController();
  final _setsController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Exercise> _exercises = [
    Exercise(id: '1', name: 'Sentadillas', description: 'asi se hace este', sets: 3, reps: 10),
    Exercise(id: '2', name: 'Flexiones', description: 'asi se hace este otro', sets: 3, reps: 10),
    Exercise(id: '3', name: 'Estocadas', description: 'dsadas', sets: 3, reps: 10),
    Exercise(id: '4', name: 'Dominadas', description: 'nosenose',  sets: 3, reps: 10),
    Exercise(id: '5', name: 'Press Banca', description: 'dsadas', sets: 3, reps: 10),
    Exercise(id: '6', name: 'Peso muerto', description: 'muybuenosesestes', sets: 3, reps: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir nueva rutina'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
    
    borderRadius: BorderRadius.circular(10),
  ),
            child: ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Ejercicio',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el nombre del ejercicio';
                                  }
                                  return null;
                                },
                              ),TextFormField(
                          controller: _repsController,
                          decoration: InputDecoration(
                            labelText: 'Repeticiones',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese la cantidad de repeticiones';
                            }
                            return null;
                          },
                        ),TextFormField(
                          controller: _setsController,
                          decoration: InputDecoration(
                            labelText: 'Series',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese la cantidad de series';
                            }
                            return null;
                          },
                        ),TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese una descripción del ejercicio';
                            }
                            return null;
                          },
                        ),const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                _exercises.add(Exercise(id: '7', name: _nameController.text, description: _descriptionController.text, sets: int.parse(_setsController.text), reps: int.parse(_repsController.text)));
                              });
                                    _nameController.clear();
                                    _descriptionController.clear();
                                    _repsController.clear();
                                    _setsController.clear();
                         //     final exercise = Exercise(
                         //       id: '',
                         //       name: _nameController.text,
                         //       description: _descriptionController.text,
                          //    );
                        //      DatabaseService.addExercise(exercise).then((_) {
                              
                              
                          //    });
                            }
                                },
                                child: Text('Agregar ejercicio'),
                              ),
                      ],
                    ),
                  ),
                ),ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: _exercises.length,
  itemBuilder: (context, index) {
    return Card(
      child: ListTile(
        title: Text(_exercises[index].name),
        subtitle: Text(_exercises[index].description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${_exercises[index].sets.toString()} sets de ${_exercises[index].reps.toString()} reps'),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmar eliminación'),
                      content: Text('¿Estás seguro de que quieres eliminar este ejercicio?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Eliminar'),
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
    );
  },
),
              ],
            ),
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    DateTime? date = DateTime.now();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Estás seguro que quieres añadir la rutina?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Comentario',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un comentario';
                    }
                    return null;
                  },
                ), SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2050),
                    );
                    date ??= DateTime.now();
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  },
  child: Icon(Icons.done),
),
    );
  }
}