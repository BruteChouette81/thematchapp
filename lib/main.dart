
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http; //http package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // root
  // r to reload
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'thematchapp',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 58, 127, 183)),
        useMaterial3: true,
      ),
      home: const TMA(title: 'The Match App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NewEventForm extends StatefulWidget {
  const NewEventForm({super.key});
  
  @override
  State<NewEventForm> createState() => _NewEventForm();

  
}

class _NewEventForm extends State<NewEventForm> {
  final myController = TextEditingController();

  Future<http.Response> testAPI() {
    return http.post(Uri.parse('http://localhost:8000/newEvent'), headers: <String, String>{
      'content-type': 'application/json',
      'event_name': myController.text
    } );
  }
  

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void _submitEvent() async {
    print("FORM: submited");
    var response = await testAPI();
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Name of the Event',
            ),
            controller: myController,
          ),
        ), 
        Center(
          child: ElevatedButton(
          onPressed: _submitEvent,
          child: const Text('Submit'),
         )) ,   
      ],
    );
  }
}

class TMA extends StatefulWidget {
  const TMA({super.key, required this.title});

  // config statefull widget

  final String title;

  @override
  State<TMA> createState() => _HomePageState();
}

class _HomePageState extends State<TMA> {
  int _counter = 0;
  bool _formActive = false;
  final _listOfEvents = <String>[];
  final _homeWidgets = <Widget>[];

  Future loadEvents() async {
    final response = await http
      .get(Uri.parse('http://localhost:8000/events'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //print(response);
      print(response.body);

      final events = jsonDecode(response.body);
      print(events["events"].length.toString());

      //update the state at refreash
      setState(() {
        _homeWidgets.clear();
        for (int i=0; i<events["events"].length; i++) {
          
          _homeWidgets.add(Text('$i'));
        }
      });
        

      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

 void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadEvents());
 }

  


  /*<Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
          ], */


  void _incrementCounter() {
    setState(() {
      //change display value
      _listOfEvents.add("test");
      _counter++;
      _homeWidgets.add(Text('${_listOfEvents.last}$_counter'));
    });
  }

  void _activateForm() {
    setState(() {
      if (_formActive) {
        _formActive = false;
        loadEvents();
       
      } else {
        _formActive = true;
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    //build UI function
    return Scaffold(
      appBar: AppBar(
        //navigation
        leading: const IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu',
          onPressed: null,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _formActive ? const NewEventForm() : Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          
          //press p to see canvas
          //mainAxisAlignment: MainAxisAlignment.center, align center
          children: _homeWidgets
        ),
      ),
      floatingActionButton: !_formActive ? FloatingActionButton(
        onPressed: _activateForm,
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ) : FloatingActionButton(
        onPressed: _activateForm,
        tooltip: 'Cancel',
        child: const Icon(Icons.cancel),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}



