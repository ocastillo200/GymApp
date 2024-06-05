import 'package:app_gym/models/draft.dart';
import 'package:app_gym/models/lap.dart';
import 'package:app_gym/screens/add_routine_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_gym/models/routine.dart';
import 'package:app_gym/models/client.dart';
import 'package:app_gym/services/database_service.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        visualDensity: VisualDensity.comfortable,
        trailing: const Icon(Icons.unfold_more),
        dense: true,
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            client.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Center(
          child: Text(client.name, style: const TextStyle(fontSize: 20)),
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                visualDensity: VisualDensity.compact,
                dense: true,
                leading: const Icon(Icons.credit_card_outlined),
                title: const Text('Rut',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle:
                    Text(client.rut, style: const TextStyle(fontSize: 12)),
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                dense: true,
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle:
                    Text(client.email, style: const TextStyle(fontSize: 12)),
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                dense: true,
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Teléfono',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle:
                    Text(client.phone, style: const TextStyle(fontSize: 12)),
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                dense: true,
                leading: Icon(client.payment
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined),
                title: const Text('Estado de Pago',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(client.payment ? 'Pagado' : 'Pago Pendiente',
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ]);
  }
}

class DraftWidget extends StatelessWidget {
  final Draft draft;
  final Client client;
  final Function fetchData;
  final Function setState;

  const DraftWidget(
      {super.key,
      required this.draft,
      required this.client,
      required this.setState,
      required this.fetchData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddRoutineScreen(
              clientId: client.id,
              updateRoutineList: () => [],
            ),
          ),
        ).then((value) {
          fetchData();
        });
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            height: 65,
            child: Row(
              children: [
                Icon(Icons.hourglass_bottom, size: 50, color: Colors.blue),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rutina en progreso...',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text('Entrenador: Integrar con sesiones'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClientDetailsScreen extends StatefulWidget {
  final Client client;
  final Function updateRoutineList;

  const ClientDetailsScreen({
    Key? key,
    required this.client,
    required this.updateRoutineList,
  }) : super(key: key);

  @override
  _ClientDetailsScreenState createState() => _ClientDetailsScreenState();
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {}

class _ClientDetailsScreenState extends State<ClientDetailsScreen>
    with RouteAware {
  List<Routine> _routines = [];
  Draft? _clientDraft;
  final Map<String, List<Lap>> _routineLaps = {};
  bool _isLoading = true;
  MyRouteObserver? _routeObserver;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver ??= MyRouteObserver();
    _routeObserver!
        .subscribe(this, ModalRoute.of(context)! as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // handle route push
  }

  @override
  void didPopNext() {
    // handle route pop
  }

  void updateRoutineList() {
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final routinesFuture = DatabaseService.getRoutines(widget.client.id);
      final clientDraftFuture =
          DatabaseService.getDraftOfClient(widget.client.id);

      final routines = await routinesFuture;
      final clientDraft = await clientDraftFuture;

      if (mounted) {
        setState(() {
          _routines = routines.reversed.toList();
          _clientDraft = clientDraft;
          _isLoading = false;
        });
      }
      for (var routine in _routines) {
        await _fetchRoutineLaps(routine.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRoutineLaps(String routineId) async {
    final routineLaps = await DatabaseService.getRoutineLaps(routineId);
    if (mounted) {
      setState(() {
        _routineLaps[routineId] = routineLaps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenamientos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                UserDetails(client: widget.client),
                Expanded(
                  child: ListView.builder(
                    itemCount: _routines.length,
                    itemBuilder: (context, index) {
                      final routine = _routines[index];
                      final laps = _routineLaps[routine.id] ?? [];
                      return ExpansionTile(
                        title:
                            Text("Entrenamiento ${_routines.length - index}"),
                        subtitle: Text(routine.date),
                        leading: const Icon(Icons.flash_on),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 12.0, right: 12.0, bottom: 5.0, top: 3.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: laps.length,
                                  itemBuilder: (context, lapIndex) {
                                    final exercises = laps[lapIndex].exercises;
                                    return Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 211, 211, 211),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: ListTile(
                                            trailing: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.repeat,
                                                  size: 50.0,
                                                ),
                                                Text(
                                                  laps[lapIndex]
                                                      .sets
                                                      .toString(), // Texto que muestra el número de series
                                                  style: const TextStyle(
                                                    fontSize:
                                                        12, // Tamaño del texto
                                                    color: Colors
                                                        .black, // Color del texto
                                                    fontWeight: FontWeight
                                                        .bold, // Estilo del texto
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: Text(
                                                "Circuito ${lapIndex + 1}"),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  for (final exercise
                                                      in exercises!)
                                                    if (exercise.reps != 0 ||
                                                        exercise.duration !=
                                                            0 ||
                                                        exercise.weight != 0 ||
                                                        exercise.machine !=
                                                            null)
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(exercise.name,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          if (exercise.reps !=
                                                              0)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 8),
                                                              child: Text(
                                                                  'Repeticiones: ${exercise.reps}'),
                                                            ),
                                                          if (exercise
                                                                  .duration !=
                                                              0)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 8),
                                                              child: Text(
                                                                  'Duración: ${exercise.duration} minutos'),
                                                            ),
                                                          if (exercise.weight !=
                                                              0)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 8),
                                                              child: Text(
                                                                  'Peso: ${exercise.weight} kg'),
                                                            ),
                                                          if (exercise
                                                                  .machine !=
                                                              null)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 8),
                                                              child: Text(
                                                                  'Máquina: ${exercise.machine}'),
                                                            ),
                                                          const SizedBox(
                                                              height: 8.0),
                                                        ],
                                                      ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                      ],
                                    );
                                  },
                                ),
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
                        ],
                      );
                    },
                  ),
                ),
                if (_clientDraft != null)
                  DraftWidget(
                    draft: _clientDraft!,
                    client: widget.client,
                    fetchData: _fetchData,
                    setState: setState,
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRoutineScreen(
                clientId: widget.client.id,
                updateRoutineList: updateRoutineList,
              ),
            ),
          );
          _fetchData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
