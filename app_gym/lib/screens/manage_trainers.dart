import 'package:app_gym/models/trainer.dart';
import 'package:app_gym/models/user.dart';
import 'package:app_gym/services/database_service.dart';
import 'package:flutter/material.dart';

class EntrenadoresScreen extends StatefulWidget {
  const EntrenadoresScreen({super.key});
  @override
  _EntrenadoresScreenState createState() => _EntrenadoresScreenState();
}

class _EntrenadoresScreenState extends State<EntrenadoresScreen> {
  List<Trainer> _filteredTrainers = []; // Lista de entrenadores filtrados

  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  Future<void> _fetchTrainers() async {
    final trainers = await DatabaseService.getTrainers();
    if (mounted) {
      setState(() {
        _filteredTrainers = List.from(
            trainers); // Inicializa la lista filtrada con todos los entrenadores
      });
    }
  }

  void _openAddTrainerForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String nombre = '';
    String rut = '';
    String username = '';
    String password = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Agregar Entrenador',
            style: TextStyle(fontFamily: 'Product Sans'),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre de usuario';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      username = value!;
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresar contraseña';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      password = value!;
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      nombre = value!;
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      hintText: 'Ej: 12345678-9',
                      labelText: 'Rut',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el rut sin puntos y con guión';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      rut = value!;
                    },
                  ),
                ],
              ),
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
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  DatabaseService.addUser(
                    User(
                        id: "",
                        name: nombre,
                        password: password,
                        rut: rut,
                        username: username,
                        admin: false),
                  );
                  setState(() {
                    _fetchTrainers();
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

  void _openEditTrainer(BuildContext context, Trainer trainer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        String nombre = trainer.name;
        String password = '';
        String username = '';
        String rut = trainer.rut;

        return AlertDialog(
          title: const Text(
            'Editar Entrenador',
            style: TextStyle(fontFamily: 'Product Sans'),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: username,
                  style: const TextStyle(fontFamily: 'Product Sans'),
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    labelStyle: TextStyle(fontFamily: 'Product Sans'),
                  ),
                  onSaved: (value) {
                    username = value!;
                  },
                ),
                TextFormField(
                  initialValue: password,
                  style: const TextStyle(fontFamily: 'Product Sans'),
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(fontFamily: 'Product Sans'),
                  ),
                  onSaved: (value) {
                    nombre = value!;
                  },
                ),
                TextFormField(
                  initialValue: nombre,
                  style: const TextStyle(fontFamily: 'Product Sans'),
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(fontFamily: 'Product Sans'),
                  ),
                  onSaved: (value) {
                    nombre = value!;
                  },
                ),
                TextFormField(
                  initialValue: rut,
                  style: const TextStyle(fontFamily: 'Product Sans'),
                  decoration: const InputDecoration(
                    labelText: 'Rut',
                    labelStyle: TextStyle(fontFamily: 'Product Sans'),
                  ),
                  onSaved: (value) {
                    rut = value!;
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
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  DatabaseService.updateTrainer(
                      Trainer(
                        rut: rut,
                        id: trainer.id,
                        name: nombre,
                        clients: trainer.clients,
                      ),
                      password,
                      username);
                  setState(() {
                    _fetchTrainers();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Guardar',
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: ListView.builder(
          key: const ValueKey('list'),
          itemCount: _filteredTrainers.length + 1,
          itemBuilder: (context, index) {
            if (index < _filteredTrainers.length) {
              final trainer = _filteredTrainers[index];
              return Column(
                children: [
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                      style:
                                          TextStyle(fontFamily: 'Product Sans'),
                                    ),
                                    content: const Text(
                                      '¿Estás seguro de que deseas eliminar este entrenador?',
                                      style:
                                          TextStyle(fontFamily: 'Porduct Sans'),
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
                                          DatabaseService.deleteTrainer(
                                              trainer.id);
                                          setState(() {
                                            _filteredTrainers.removeAt(index);
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
                            }),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            trainer.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white),
                          ),
                        ),
                        title: Text(trainer.name,
                            style: const TextStyle(fontFamily: 'Product Sans')),
                        onTap: () {
                          _openEditTrainer(context, trainer);
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox(height: 80.0);
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddTrainerForm(context);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
