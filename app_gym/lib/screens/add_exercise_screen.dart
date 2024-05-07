import 'package:flutter/material.dart';
//import 'package:app_gym/models/exercise.dart';
//import 'package:app_gym/services/database_service.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}
class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir ejercicio '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
               //     final exercise = Exercise(
               //       id: '',
               //       name: _nameController.text,
               //       description: _descriptionController.text,
                //    );
              //      DatabaseService.addExercise(exercise).then((_) {
                      Navigator.pop(context);
                //    });
                  }
                },
                child: const Text('Add Exercise'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}