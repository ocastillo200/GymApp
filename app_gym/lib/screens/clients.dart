import 'package:flutter/material.dart';
import 'package:app_gym/models/user.dart';
import 'package:app_gym/screens/client_details_screen.dart';
import 'package:app_gym/screens/exercises.dart';
import 'package:app_gym/services/database_service.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> _clients = [
    Client(id: '201234560', name: 'Juan', email: 'a@gmail.com', phone: '912345678'),
    Client(id: '210323011', name: 'Pedro', email: 'b@gmail.com', phone: '912345677'),
    Client(id: '129039930', name: 'Tomas', email: 'c@gmail.com', phone: '912345676'),
    Client(id: '123904902', name: 'Camila', email: 'd@gmail.com', phone: '912345675'),
  ];

  @override
  void initState() {
    super.initState();
 //   _fetchClients();
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
            trailing: Text(client.paymentstate),
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
