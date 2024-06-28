import 'package:app_gym/models/machine.dart';
import 'package:app_gym/services/database_service.dart';
import 'package:flutter/material.dart';

class MaquinasScreen extends StatefulWidget {
  const MaquinasScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MaquinasScreenState createState() => _MaquinasScreenState();
}

class _MaquinasScreenState extends State<MaquinasScreen> {
  List<dynamic> _maquinas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMachines();
  }

  Future<void> _fetchMachines() async {
    _maquinas = await DatabaseService.getMachines();
    if (mounted) {
      setState(() {
        _maquinas = _maquinas;
        _isLoading = false;
      });
    }
  }

  void _openAddMaquinaForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String nombre = '';
    int cantidad = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Agregar Máquina',
            style: TextStyle(fontFamily: 'Product Sans'),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  style: const TextStyle(fontFamily: 'Product Sans'),
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(fontFamily: 'Product Sans'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    final regex = RegExp(r'^[a-zA-Z0-9]+$');
                    if (!regex.hasMatch(value)) {
                      return 'Ingrese caracteres válidos';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    nombre = value;
                  },
                ),
                TextFormField(
                  style: const TextStyle(fontFamily: 'Product Sans'),
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    labelStyle: TextStyle(fontFamily: 'Product Sans'),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una cantidad';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue <= 0) {
                      return 'Ingrese una cantidad válida';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    cantidad = int.tryParse(value) ?? 1;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(fontFamily: 'Product Sans'),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
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
    final _formKey = GlobalKey<FormState>();
    String nombre = machine.name;
    int cantidad = machine.quantity;
    int disponibles = machine.available;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            nombre,
            style: const TextStyle(fontFamily: 'Product Sans'),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: cantidad.toString(),
                  style: const TextStyle(fontFamily: 'Product Sans'),
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    labelStyle: TextStyle(fontFamily: 'Product Sans'),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una cantidad';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue <= 0) {
                      return 'Ingrese una cantidad válida';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    cantidad = int.tryParse(value) ?? machine.quantity;
                  },
                ),
                TextFormField(
                  initialValue: disponibles.toString(),
                  style: const TextStyle(fontFamily: 'Product Sans'),
                  decoration: const InputDecoration(
                    labelText: 'Disponibles',
                    labelStyle: TextStyle(fontFamily: 'Product Sans'),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una cantidad disponible';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0) {
                      return 'Ingrese una cantidad válida';
                    }
                    if (intValue > cantidad) {
                      return 'No hay suficientes máquinas';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    disponibles = int.tryParse(value) ?? machine.available;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(fontFamily: 'Product Sans'),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  DatabaseService.editMachine(Machine(
                    id: machine.id,
                    name: nombre,
                    quantity: cantidad,
                    available: disponibles,
                  ));
                  Navigator.pop(context);
                  await _fetchMachines();
                  setState(() {
                    _maquinas = _maquinas;
                  });
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
      body: (_isLoading)
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (maquina.available == 0)
                              const Icon(
                                Icons.handyman,
                                color: Colors.red,
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Confirmar eliminación',
                                        style: TextStyle(
                                            fontFamily: 'Product Sans'),
                                      ),
                                      content: const Text(
                                        '¿Estás seguro de que deseas eliminar esta máquina?',
                                        style: TextStyle(
                                            fontFamily: 'Product Sans'),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(
                                                fontFamily: 'Product Sans'),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            DatabaseService.deleteMachine(
                                                maquina.id);
                                            setState(() {
                                              _maquinas.removeAt(index);
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Eliminar',
                                            style: TextStyle(
                                                fontFamily: 'Product Sans'),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
