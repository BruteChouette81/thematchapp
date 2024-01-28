import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class Settings extends StatefulWidget {
  const Settings({super.key});
  
  @override
  State<Settings> createState() => _Settings();

  
}

class _Settings extends State<Settings> {
  String user = "";
  String password = "";
  String ip = "";

  Future loadInfo() async {
    var interface = await NetworkInterface.list();
    String ip2 = interface[0].addresses[0].address;

    final response = await http
      .post(Uri.parse('http://localhost:8000/connected'), headers: <String, String>{
      'content-type': 'application/json',
      'ip': ip2
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //print(response);
      print(response.body);

      final infos = jsonDecode(response.body);
      print(infos);

      //update the state at refreash
      setState(() {
        if(!(infos["status"] == 5)) {
          ip = ip2;
          user = infos["name"];
          password = infos["password"];
         
        }
       
        
      });
  }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadInfo());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //navigation
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Settings"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Email: $user"),
          Text("Password: $password"),
          Text("Ip connected: $ip"),

        ], ),
    );
  }
}