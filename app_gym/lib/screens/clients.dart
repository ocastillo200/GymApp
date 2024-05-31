import 'package:flutter/material.dart';
import 'package:app_gym/models/client.dart';
import 'package:app_gym/screens/client_details_screen.dart';
import 'package:app_gym/screens/exercises.dart';
import 'package:app_gym/services/database_service.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> _filteredClients = []; // Lista de clientes filtrados
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
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
            icon: const Icon(Icons.fitness_center),
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
      body: ListView.builder(
        itemCount: _filteredClients.length,
        itemBuilder: (context, index) {
          final client = _filteredClients[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                client.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(client.name),
            subtitle: Text(client.email),
            trailing: Text(client.payment ? 'Pagado' : 'Pendiente'),
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
          );
        },
      ),
    );
  }
}

class _ClientSearchDelegate extends SearchDelegate<Client> {
  final List<Client> clients;

  _ClientSearchDelegate(this.clients);
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
          title: Text(client.name),
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
