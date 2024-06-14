import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget{

  const AdminScreen({super.key});
  @override

  _AdminScreenState createState()=>_AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>{
  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.redAccent.shade700,
        title: const Text(
          'Bienvenido',
          style:  TextStyle(
            fontFamily: 'Product Sans', color: Colors.white,fontSize: 18
          ),
        ),
      ),
    );
  }
}