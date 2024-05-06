import 'package:app_gym/models/exercise.dart';
import 'package:app_gym/screens/add_routine_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_gym/models/routine.dart';
import 'package:app_gym/models/client.dart';
import 'package:app_gym/services/database_service.dart';

class ClientDetailsScreen extends StatefulWidget {
  final Client client;

  ClientDetailsScreen({required this.client});

  @override
  _ClientDetailsScreenState createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  List<Routine> _routines = [
    Routine(
      id: '1',
      clientId: '201234560',
      exercises: [
        Exercise(id: '1', name: 'Sentadillas', description: '3 sets de 10 reps', sets: 3, reps: 10),
        Exercise(id: '2', name: 'Flexiones', description: '3 sets de 10 reps', sets: 3, reps: 10),
      ],
          comments: 'El peso de la sentadilla esta bien, pero debe mejorar la postura. En las flexiones, debe bajar mas el cuerpo',
    ),
    Routine(
      id: '2',
      clientId: '201234560',
      exercises: [
        Exercise(id: '3', name: 'Estocadas', description: '3 sets de 10 reps', sets: 3, reps: 10),
        Exercise(id: '4', name: 'Dominadas', description: '3 sets de 10 reps', sets: 3, reps: 10),
      ],
      comments: 'Debe mejorar la postura en las estocadas. En las dominadas, debe bajar mas el cuerpo',
    ),
    Routine(
      id: '2',
      clientId: '201234560',
      exercises: [
        Exercise(id: '5', name: 'Press Banca', description: '1 set de 10 reps', sets: 1, reps: 10),
        Exercise(id: '6', name: 'Peso muerto', description: '3 sets de 10 reps', sets: 3, reps: 10),
      ],
      comments: 'Debe mejorar la postura en el press banca. En el peso muerto, debe bajar mas el cuerpo',
    ),
  ];

  @override
  void initState() {
    super.initState();
 //   _fetchRoutines();
  }

  Future<void> _fetchRoutines() async {
    final routines = await DatabaseService.getRoutines(widget.client.id);
    setState(() {
      _routines = routines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrenamientos'),
      ),
      body: ListView.builder(
        itemCount: _routines.length,
        itemBuilder: (context, index) {
          final routine = _routines[index];
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ejercicios de la rutina:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: routine.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = routine.exercises[index];
                      return ListTile(
                        title: Text(exercise.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Descripción: ${exercise.description}'),
                            Text('Sets: ${exercise.sets}'),
                            Text('Reps: ${exercise.reps}'),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8.0),
                  Text('Fecha: ${routine.date}'),
                  SizedBox(height: 8.0),
                  Text(
                    'Comentarios: ${routine.comments}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRoutineScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      )
    );
  }
}