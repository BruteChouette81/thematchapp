
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

class Account extends StatefulWidget{
  const Account({super.key, required this.user, required this.password, required this.ip});
  
  final String user;
  final String password;
  final String ip;

  @override
  State<Account> createState() => _Account();

}

class _Account extends State<Account> {

  final _events = <Widget>[];

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadEvents());
  }


  Future loadEvents() async {
    var interface = await NetworkInterface.list();
    String ip2 = interface[0].addresses[0].address;

    final response = await http
      .post(Uri.parse('http://localhost:8000/queueList'), headers: <String, String>{
      'content-type': 'application/json',
      'ip': ip2
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //print(response);
      print(response.body);

      final events = jsonDecode(response.body);
      print(events);

      //update the state at refreash
      setState(() {
        if(events["events"].length > 0) {
          for(var i =0; i<events["events"].length; i++) {
            _events.add(Column(children: [Text(events["events"][i]["name"]), ElevatedButton(
          onPressed: () => {},
          child: const Text('Remove'),
         )],));
          }
        } else {
          _events.add(const Text("No current events"));
        }
       
        
      });
  }
  }


  Future disconnect() async {
     final response = await http
      .post(Uri.parse('http://localhost:8000/disconnect'), headers: <String, String>{
      'content-type': 'application/json',
      'ip': widget.ip
    });
    print(response);
  }
  @override
  Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("user:${widget.user}"),
          Text("password:${widget.password}"),
          Text("ip:${widget.ip}"),
          ElevatedButton(onPressed: disconnect, child: const Text('Disconnect')),
          Center(
      
            child: Column(
      
              children: _events
            )
          )

        ]
      );
  }
}