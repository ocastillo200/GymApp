import 'package:app_gym/models/machine.dart';
import 'package:app_gym/services/database_service.dart';
import 'package:flutter/material.dart';

class MaquinasScreen extends StatefulWidget {
  const MaquinasScreen({super.key});

  @override
  _MaquinasScreenState createState() => _MaquinasScreenState();
}

class _MaquinasScreenState extends State<MaquinasScreen> {
  List<dynamic> _maquinas = [];

  @override
  void initState() {
    super.initState();
    _fetchMachines();
  }

  Future<void> _fetchMachines() async {
    _maquinas = await DatabaseService.getMachines();
    setState(() {
      _maquinas = _maquinas;
    });
  }

  void _openAddMaquinaForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nombre = '';
        int cantidad = 1;
        return AlertDialog(
          title: const Text(
            'Agregar Máquina',
            style: TextStyle(fontFamily: 'Product Sans'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(fontFamily: 'Product Sans'),
                decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(fontFamily: 'Product Sans')),
                onChanged: (value) {
                  nombre = value;
                },
              ),
              TextField(
                style: const TextStyle(fontFamily: 'Product Sans'),
                decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    labelStyle: TextStyle(fontFamily: 'Product Sans')),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  cantidad = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar',
                  style: TextStyle(fontFamily: 'Product Sans')),
            ),
            TextButton(
              onPressed: () {
                if (nombre.isNotEmpty && cantidad > 0) {
                  DatabaseService.addMachine(Machine(
                    id: '',
                    name: nombre,
                    quantity: cantidad,
                    available: cantidad,
                  ));
                  setState(() {
                    _fetchMachines();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Agregar',
                style: TextStyle(fontFamily: 'Product Sans'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openEditMachineForm(BuildContext context, Machine machine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nombre = machine.name;
        int cantidad = machine.quantity;
        int disponibles = machine.available;
        return AlertDialog(
          title: Text(
            nombre,
            style: const TextStyle(fontFamily: 'Product Sans'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(fontFamily: 'Product Sans'),
                decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    labelStyle: TextStyle(fontFamily: 'Product Sans')),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  cantidad = int.tryParse(value) ?? 1;
                },
              ),
              TextField(
                style: const TextStyle(fontFamily: 'Product Sans'),
                decoration: const InputDecoration(
                    labelText: 'Disponibles',
                    labelStyle: TextStyle(fontFamily: 'Product Sans')),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  disponibles = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar',
                  style: TextStyle(fontFamily: 'Product Sans')),
            ),
            TextButton(
              onPressed: () {
                if (nombre.isNotEmpty && cantidad > 0) {
                  DatabaseService.editMachine(Machine(
                    id: machine.id,
                    name: nombre,
                    quantity: cantidad,
                    available: disponibles,
                  ));
                }
              },
              child: const Text(
                'Editar',
                style: TextStyle(fontFamily: 'Product Sans'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _maquinas.length + 1,
        itemBuilder: (context, index) {
          if (index < _maquinas.length) {
            final maquina = _maquinas[index];
            return Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 6),
              child: Container(
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Confirmar eliminación',
                              style: TextStyle(fontFamily: 'Product Sans'),
                            ),
                            content: const Text(
                              '¿Estás seguro de que deseas eliminar esta máquina?',
                              style: TextStyle(fontFamily: 'Porduct Sans'),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(fontFamily: 'Product Sans'),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  DatabaseService.deleteMachine(maquina['id']);

                                  setState(() {
                                    _maquinas.removeAt(index);
                                  });

                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(fontFamily: 'Product Sans'),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  title: Text(
                    maquina.name,
                    style: const TextStyle(
                        fontFamily: 'Product Sans', fontSize: 20),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cantidad: ${maquina.quantity}',
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Colors.grey[600]),
                      ),
                      Text(
                        'Disponibles: ${maquina.available}',
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  onTap: () {
                    _openEditMachineForm(context, maquina);
                  },
                ),
              ),
            );
          } else {
            return const SizedBox(height: 80);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMaquinaForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
