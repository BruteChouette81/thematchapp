import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});
  
  @override
  State<Friends> createState() => _Friends();

  
}

class _Friends extends State<Friends> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //navigation
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("My Friends"),
      ),
      body: const Center(
        child: Text("test"),
      )
    );
  }
}