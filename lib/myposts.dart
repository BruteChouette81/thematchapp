import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:io';

import './utils/get_server.dart';

String server = getString(); //http://localhost:8000


class MyPosts extends StatefulWidget {
  const MyPosts({super.key});
  
  @override
  State<MyPosts> createState() => _MyPosts();

  
}

class _MyPosts extends State<MyPosts> {
  final _posted = <Widget>[];
  bool deleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadInfo());
  }

  Future deleteItem(String name) async {
    setState(() {
      deleted  = true;
    });
    await http
      .post(Uri.parse('$server/deleteEvent'), headers: <String, String>{ //final response = 
      'content-type': 'application/json',
      'event_name': name
    });
  }

  Future loadInfo() async {
    var interface = await NetworkInterface.list();
    String ip2 = interface[0].addresses[0].address;

    final response = await http
      .post(Uri.parse('$server/mypost'), headers: <String, String>{
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
        if(infos["mp"].length > 0) {
          for(var i =0; i<infos["mp"].length; i++) {
            _posted.add(Column(children: [Text(infos["mp"][i]["name"]), ElevatedButton(
          onPressed: () => deleteItem(infos["mp"][i]["name"]),
          child: const Text('Delete'),
         )],));
          }
        } else {
          _posted.add(const Text("No current post"));
        }
       
        
      });
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //navigation
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("My Posts"),
      ),
      body: Center(
        
        child: Column(
         
          children:  deleted ? [AlertDialog(
            title: const Text('You deleted your post!'),
            content: const Text('Refresh to actualize.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => setState(() => deleted = false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => setState(() => deleted = false),
                child: const Text('OK'),
              ),
            ],
          )]: _posted,
        ),
      ),
    );
    
  }
}