import 'package:app_gym/screens/login.dart';
import 'package:app_gym/screens/manage_clients.dart';
import 'package:app_gym/screens/manage_machines.dart';
import 'package:app_gym/screens/manage_trainers.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const EntrenadoresScreen(),
    const ClientesScreen(),
    const MaquinasScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(
          context); // Cierra el Drawer después de seleccionar una opción
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: Text(
          (_selectedIndex == 0)
              ? 'Entrenadores'
              : _selectedIndex == 1
                  ? 'Clientes'
                  : 'Máquinas',
          style: const TextStyle(
            fontFamily: 'Product Sans',
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Text(
                'Administrador',
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                '',
                style: TextStyle(
                  fontFamily: 'Product Sans',
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                'Entrenadores',
                style: TextStyle(fontSize: 16, fontFamily: 'Product Sans'),
              ),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text(
                'Clientes',
                style: TextStyle(fontSize: 16, fontFamily: 'Product Sans'),
              ),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text(
                'Máquinas',
                style: TextStyle(fontSize: 16, fontFamily: 'Product Sans'),
              ),
              onTap: () => _onItemTapped(2),
            ),
            const Expanded(child: SizedBox()), // Takes remaining space
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 3),
                onPressed: () async {
                  bool? confirmLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          '¿Estás seguro de que quieres cerrar sesión?',
                          style: TextStyle(fontFamily: 'Product Sans'),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontFamily: 'Product Sans'),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text(
                              'Aceptar',
                              style: TextStyle(fontFamily: 'Product Sans'),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmLogout == true) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
      body: _screens.isNotEmpty ? _screens[_selectedIndex] : Container(),
    );
  }
}
