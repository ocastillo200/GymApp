import 'package:app_gym/models/trainer.dart';
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
    setState(() {
      _filteredTrainers = List.from(trainers); // Inicializa la lista filtrada con todos los entrenadores
      print(_filteredTrainers);
    });
  }

  void _openAddTrainerForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String nombre = '';
    
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
                  DatabaseService.addTrainer(Trainer(
                    id: '',
                    name: nombre,
                    clients: [],
                  ));
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
        final _formKey = GlobalKey<FormState>();
        String nombre = trainer.name;

        return AlertDialog(
          title: const Text(
            'Editar Entrenador',
            style: TextStyle(fontFamily: 'Product Sans'),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nombre,
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
                  _formKey.currentState!.save();
                  DatabaseService.updateTrainer(Trainer(
                    id: trainer.id,
                    name: nombre,
                    clients: trainer.clients,
                  ));
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
                        // subtitle: Text(trainer.email,
                        //     style: const TextStyle(fontFamily: 'Product Sans')),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
