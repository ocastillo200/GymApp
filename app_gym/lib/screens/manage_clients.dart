import 'dart:convert';
import 'dart:typed_data';
import 'package:app_gym/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:app_gym/models/client.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Client> _filteredClients = []; // Lista de clientes filtrados
  bool _isLoading = true;
  Map<String, Uint8List> images = {};
  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    try {
      final clients = await DatabaseService.getClients();
      if (clients.isEmpty) {
        print('No clients found.');
        return;
      }
      if (mounted) {
        setState(() {
          _filteredClients = List.from(clients);
          Uint8List? decodedImage;
          for (var client in _filteredClients) {
            if (client.image != null && client.image!.isNotEmpty) {
              try {
                decodedImage = base64Decode(client.image!);
                images[client.id] = decodedImage;
              } catch (e) {
                // Handle decoding error if needed
                print('Error decoding image for client ${client.id}: $e');
              }
            }
          }
          _isLoading = false;
          print('Clients loaded: ${_filteredClients.length}');
        });
      }
    } catch (e) {
      // Handle fetching clients error
      print('Error fetching clients: $e');
    }
  }

  void _openAddClientForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String nombre = '';
    String email = '';
    String phone = '';
    String rut = '';
    bool health = true;
    String? encodedImage;

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        Uint8List compressedImage = await FlutterImageCompress.compressWithList(
          bytes,
          minHeight: 1920,
          minWidth: 1080,
          quality: 40,
          format: CompressFormat.jpeg,
        );
        if (compressedImage.isNotEmpty) {
          String base64Image = base64Encode(compressedImage);
          setState(() {
            encodedImage = base64Image;
          });
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Agregar Cliente',
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
                  TextFormField(
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor ingrese un email válido';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el teléfono';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Por favor ingrese un teléfono válido';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      phone = value!;
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      labelText: 'Rut',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el rut';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      rut = value!;
                    },
                  ),
                  DropdownButtonFormField<bool>(
                    decoration: const InputDecoration(
                      labelText: 'Estado de salud',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    value: health,
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text(
                          'Saludable',
                          style: TextStyle(fontFamily: 'Product Sans'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('Con lesión',
                            style: TextStyle(fontFamily: 'Product Sans')),
                      ),
                    ],
                    onChanged: (value) {
                      health = value!;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: pickImage,
                    child: const Text(
                      'Capturar Imagen',
                      style: TextStyle(fontFamily: 'Product Sans'),
                    ),
                  ),
                  if (encodedImage != null)
                    const Text(
                      'Imagen capturada',
                      style: TextStyle(fontFamily: 'Product Sans'),
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
                  DatabaseService.addClient(Client(
                    image: encodedImage,
                    id: '',
                    name: nombre,
                    email: email,
                    phone: phone,
                    rut: rut,
                    health: health,
                    draft: null,
                  ));
                  setState(() {
                    _fetchClients();
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

  void _openEditClient(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        String nombre = client.name;
        String email = client.email;
        String phone = client.phone;
        String rut = client.rut;
        bool health = client.health;

        return AlertDialog(
          title: const Text(
            'Editar Cliente',
            style: TextStyle(fontFamily: 'Product Sans'),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                  TextFormField(
                    initialValue: email,
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor ingrese un email válido';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: phone,
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el teléfono';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Por favor ingrese un teléfono válido';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      phone = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: rut,
                    style: const TextStyle(fontFamily: 'Product Sans'),
                    decoration: const InputDecoration(
                      labelText: 'Rut',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el rut';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      rut = value!;
                    },
                  ),
                  DropdownButtonFormField<bool>(
                    decoration: const InputDecoration(
                      labelText: 'Salud',
                      labelStyle: TextStyle(fontFamily: 'Product Sans'),
                    ),
                    value: health,
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('Saludable'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('Con lesión'),
                      ),
                    ],
                    onChanged: (value) {
                      health = value!;
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
                  DatabaseService.updateClient(Client(
                    image: client.image,
                    id: client.id,
                    name: nombre,
                    email: email,
                    phone: phone,
                    rut: rut,
                    health: health,
                    draft: client.draft,
                  ));
                  setState(() {
                    _fetchClients();
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

  Widget _buildAvatarContent(Client client) {
    if (client.image != null) {
      print('LLEGUE ACA');
      Uint8List decodedImage = base64Decode(client.image!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.memory(
          decodedImage,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
        ),
      );
    } else {
      print('LLEGUE ACA SIN IMAGEN');
      return CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          client.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Product Sans',
            color: Colors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_isLoading)
          ? const Center(child: CircularProgressIndicator())
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: ListView.builder(
                key: const ValueKey('list'),
                itemCount: _filteredClients.length + 1,
                itemBuilder: (context, index) {
                  if (index < _filteredClients.length) {
                    final client = _filteredClients[index];
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
                                            style: TextStyle(
                                                fontFamily: 'Product Sans'),
                                          ),
                                          content: const Text(
                                            '¿Estás seguro de que deseas eliminar este cliente?',
                                            style: TextStyle(
                                                fontFamily: 'Porduct Sans'),
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
                                                DatabaseService.deleteClient(
                                                    client.id);
                                                setState(() {
                                                  _filteredClients
                                                      .removeAt(index);
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
                              leading: _buildAvatarContent(client),
                              title: Text(client.name,
                                  style: const TextStyle(
                                      fontFamily: 'Product Sans')),
                              subtitle: Text(client.email,
                                  style: const TextStyle(
                                      fontFamily: 'Product Sans')),
                              onTap: () {
                                _openEditClient(context, client);
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
          _openAddClientForm(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
