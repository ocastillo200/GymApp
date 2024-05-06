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
  List<Client> _clients = [];
  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    final clients = await DatabaseService.getClients();
    setState(() {
      _clients = clients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExercisesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _clients.length,
        itemBuilder: (context, index) {
          final client = _clients[index];
          return ListTile(
            title: Text(client.name),
            subtitle: Text(client.email),
            trailing: Text(client.payment ? 'Pagado' : 'Pendiente'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientDetailsScreen(client: client),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
