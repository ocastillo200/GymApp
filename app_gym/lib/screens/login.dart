import 'package:flutter/material.dart';
import 'package:app_gym/screens/clients.dart';
//import 'package:app_gym/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
           //         AuthService.login(
            //          email: _emailController.text,
            //          password: _passwordController.text,
           //         ).then((user) {
         //             if (user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientsScreen(),
                          ),
                        );
             //         } 
           //           else {
            //            ScaffoldMessenger.of(context).showSnackBar(
           //               SnackBar(
          //                  content: Text('Invalid email or password'),
          //                ),
        //                );
                      }
       //             });
     //             }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}