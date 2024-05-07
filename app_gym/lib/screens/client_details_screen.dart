import 'package:app_gym/screens/add_routine_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_gym/models/routine.dart';
import 'package:app_gym/models/client.dart';
import 'package:app_gym/services/database_service.dart';
import 'package:flutter/widgets.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Nombre: ${client.name}'),
        Text('Rut: ${client.rut}'),
        Text('Email: ${client.email}'),
        Text('Teléfono: ${client.phone}'),
        Text('Pago: ${client.payment}'),
      ],
    );
  }
}

class ClientDetailsScreen extends StatefulWidget {
  final Client client;
  final Function updateRoutineList;

  const ClientDetailsScreen(
      {super.key, required this.client, required this.updateRoutineList});

  @override
  _ClientDetailsScreenState createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  List<Routine> _routines = [];

  void updateRoutineList() {
    _fetchRoutines();
  }

  @override
  void initState() {
    super.initState();
    _fetchRoutines();
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
          title: const Text('Entrenamientos'),
        ),
        body: Column(
          children: [
            UserDetails(client: widget.client),
            Expanded(
              child: ListView.builder(
                itemCount: _routines.length,
                itemBuilder: (context, index) {
                  final routine = _routines[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ejercicios de la rutina:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                          const SizedBox(height: 8.0),
                          Text('Fecha: ${routine.date}'),
                          const SizedBox(height: 8.0),
                          Text(
                            'Comentarios: ${routine.comments}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddRoutineScreen(
                    clientId: widget.client.id,
                    updateRoutineList: updateRoutineList),
              ),
            );
            if (result == true) {
              _fetchRoutines();
            }
          },
          child: const Icon(Icons.add),
        ));
  }
}
