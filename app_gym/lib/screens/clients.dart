import 'package:flutter/material.dart';
import 'package:app_gym/models/client.dart';
import 'package:app_gym/screens/client_details_screen.dart';
import 'package:app_gym/screens/exercises.dart';
import 'package:app_gym/services/database_service.dart';

class ClientsScreen extends StatefulWidget {
  final String userName;
  const ClientsScreen({super.key, required this.userName});

  @override
  // ignore: library_private_types_in_public_api
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> _filteredClients = []; // Lista de clientes filtrados
  bool _isListMode = true; // Variable para controlar el modo de visualización

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    final clients = await DatabaseService.getClients();
    setState(() {
      _filteredClients = List.from(
          clients); // Inicializa la lista filtrada con todos los clientes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent.shade400,
        title: Text(
          'Bienvenido ${widget.userName}',
          style: TextStyle(fontFamily: 'Product Sans', color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(_isListMode ? Icons.view_module : Icons.view_list,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _isListMode = !_isListMode; // Cambia el modo de visualización
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final selectedClient = await showSearch<Client>(
                context: context,
                delegate: _ClientSearchDelegate(_filteredClients),
              );

              if (selectedClient != null) {
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientDetailsScreen(
                      client: selectedClient,
                      updateRoutineList:
                          () {}, // No sé qué hace esta función en tu app
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.fitness_center, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExercisesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isListMode
              ? GridView.builder(
                  key: const ValueKey('grid'),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = _filteredClients[index];
                    return Card(
                      color: Colors.white,
                      elevation: 4.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientDetailsScreen(
                                client: client,
                                updateRoutineList: () => {},
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue,
                              child: Text(
                                client.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Text(
                              client.name,
                              style: const TextStyle(
                                  fontFamily: 'Product Sans', fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  key: const ValueKey('list'),
                  itemCount: _filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = _filteredClients[index];
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 66, 66, 66)
                                    .withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                client.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Colors.white),
                              ),
                            ),
                            title: Text(client.name,
                                style: const TextStyle(
                                    fontFamily: 'Product Sans')),
                            subtitle: Text(client.email,
                                style: const TextStyle(
                                    fontFamily: 'Product Sans')),
                            trailing: Text(
                                client.payment ? 'Pagado' : 'Pendiente',
                                style: const TextStyle(
                                    fontFamily: 'Product Sans')),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClientDetailsScreen(
                                    client: client,
                                    updateRoutineList: () => {},
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8.0)
                      ],
                    );
                  },
                )),
    );
  }
}

class _ClientSearchDelegate extends SearchDelegate<Client> {
  final List<Client> clients;

  _ClientSearchDelegate(this.clients);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'Product Sans', // Cambia a la fuente deseada
          fontSize: 20.0, // Tamaño de la fuente
          color: Color.fromARGB(255, 0, 0, 0), // Color del texto
        ),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Buscar Cliente';

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Client> suggestions = query.isEmpty
        ? clients
        : clients
            .where((client) =>
                client.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final client = suggestions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              client.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  fontFamily: 'Product Sans', color: Colors.white),
            ),
          ),
          title: Text(client.name,
              style: const TextStyle(fontFamily: 'Product Sans')),
          onTap: () {
            close(context, client); // Devuelve el cliente seleccionado
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }
}
