import 'package:app_gym/models/lap.dart';
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
        Text(client.payment ? 'Pagado' : 'Pago Pendiente')
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
  List<Lap> _laps = [];

  void updateRoutineList() {
    _fetchRoutines();
  }

  @override
  void initState() {
    super.initState();
    _fetchRoutines();
  }

  Future<void> _fetchRoutineLaps(String routineId) async {
    final routineLaps = await DatabaseService.getRoutineLaps(routineId);
    setState(() {
      _laps = routineLaps;
    });
  }

  Future<void> _fetchRoutines() async {
    final routines = await DatabaseService.getRoutines(widget.client.id);
    setState(() {
      _routines = routines;
    });
    for (var routine in _routines) {
      _fetchRoutineLaps(routine.id);
    }
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
                  //      final routineId = routine.id;
                  //       _fetchRoutineLaps(routineId);
                  return ExpansionTile(
                      title: Text("Entrenamiento ${index + 1}"),
                      subtitle: Text(routine.date),
                      children: [
                        Padding(
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
                                itemCount: _laps.length,
                                itemBuilder: (context, index) {
                                  final exercises = _laps[index].exercises;
                                  return ListTile(
                                    title: Text("Circuito ${index + 1}"),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (final exercise in exercises)
                                          if (exercise.reps != 0 ||
                                              exercise.duration != 0 ||
                                              exercise.weight != 0 ||
                                              exercise.machine != null)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(exercise.name),
                                                if (exercise.reps != 0)
                                                  Text(
                                                      'Repeticiones: ${exercise.reps}'),
                                                if (exercise.duration != 0)
                                                  Text(
                                                      'Duración: ${exercise.duration} minutos'),
                                                if (exercise.weight != 0)
                                                  Text(
                                                      'Peso: ${exercise.weight} kg'),
                                                if (exercise.machine != null)
                                                  Text(
                                                      'Máquina: ${exercise.machine}'),
                                              ],
                                            ),
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
                      ]);
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
