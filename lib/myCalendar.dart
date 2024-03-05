import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

//import 'package:http/http.dart' as http;
//import 'dart:io';
import './utils/get_server.dart';

String server = getString(); //http://localhost:8000


class MyCalendar extends StatefulWidget {
  const MyCalendar({super.key});
  
  @override
  State<MyCalendar> createState() => _MyCalendar();

  
}

class _MyCalendar extends State<MyCalendar> {
  DateTime _selectedDay = DateTime.now(); 

  final _dispos = <Widget>[];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadDispos());
  }


  Future loadDispos() async {
    var interface = await NetworkInterface.list();
    String ip2 = interface[0].addresses[0].address;

    final response = await http
      .post(Uri.parse('$server/listDispo'), headers: <String, String>{
      'content-type': 'application/json',
      'ip': ip2
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //print(response);
      //print(response.body);

      final infos = jsonDecode(response.body);
      //print(infos);

      //update the state at refreash
      setState(() {
        if(infos["dispo"].length > 0) {
          for(var i =0; i<infos["dispo"].length; i++) {
            _dispos.add(Column(children: [Text(infos["dispo"][i]), ElevatedButton(
          onPressed: () => {},
          child: const Text('Remove'),
         )],));
          }
        } else {
          _dispos.add(const Text("No current disponibilities"));
        }
       
        
      });
  }
  }
   Future uploadDispos() async {
    var interface = await NetworkInterface.list();
    String ip2 = interface[0].addresses[0].address;

    final response = await http
      .post(Uri.parse('$server/addDispo'), headers: <String, String>{
      'content-type': 'application/json',
      'ip': ip2,
      'date': '$_selectedDay'
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //print(response);
      //print(response.body);

     jsonDecode(response.body); // final infos = 
      //print(infos);
       
        
    }
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //navigation
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("My Calendar"),
      ),
      body: Center(
        
        child: Column(
         
          children:[ TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _selectedDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
          },
       ), Text('selected day: $_selectedDay'), 
       ElevatedButton(
          onPressed: uploadDispos,
          child: const Text('Add disponibility'),
         ), Column(
           children: _dispos,
         )] 
       )
      ),
    );
    
  }
}











