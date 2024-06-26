import 'package:app_gym/screens/manage_clients.dart';
import 'package:app_gym/screens/manage_machines.dart';
import 'package:app_gym/screens/manage_trainers.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
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
              fontFamily: 'Product Sans', color: Colors.white, fontSize: 18),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú de navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Entrenadores'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Clientes'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.precision_manufacturing),
              title: const Text('Máquinas'),
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex], // Muestra la pantalla seleccionada
    );
  }
}
