
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:thematchapp/account.dart';

class ConnectForm extends StatefulWidget {
  const ConnectForm({super.key});
  
  @override
  State<ConnectForm> createState() => _ConnectForm();

  
}

class _ConnectForm extends State<ConnectForm> {
  final myController = TextEditingController();

  final myPassController = TextEditingController();

  String ip = "";

  bool error1 = false;
  bool error2 = false;
  bool error3 = false;
  bool success = false;

  Future<http.Response> connectUsingAPI() {
    return http.post(Uri.parse('http://localhost:8000/connect'), headers: <String, String>{
      'content-type': 'application/json',
      'user_name': myController.text,
      'password': myPassController.text,
      'ip': ip
    } );
  }

  Future<http.Response> signUpUsingAPI() {
    return http.post(Uri.parse('http://localhost:8000/signup'), headers: <String, String>{
      'content-type': 'application/json',
      'user_name': myController.text,
      'password': myPassController.text,
      'ip': ip
    } );
  }

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
          myController.text = infos["name"];
          myPassController.text = infos["password"];
          success = infos["connected"];
        }
       
        
      });
  }
  }
  

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    myPassController.dispose();
    super.dispose();
  }

  void _submitEvent() async {
    var interface = await NetworkInterface.list();
    ip = interface[0].addresses[0].address;
    print("FORM: Connecting");
    final response = await connectUsingAPI();

    print(response.body);

    final res = jsonDecode(response.body);

    print(res["status"]);

    if (res["status"] == "2") {
      setState(() {
      error2 = true;
    });
    } else if (res["status"] == "3") {
      setState(() {
      error3 = true;
    });
    } else if (res["status"] == "ok") {
      setState(() {
        success = true;
        ip = interface[0].addresses[0].address;
      });
    }
    
  }

   void _submitSignUp() async {
    var interface = await NetworkInterface.list();
    ip = interface[0].addresses[0].address;
    print("FORM: Signing Up");
    final response = await signUpUsingAPI();
    print(response.body);
    final res = jsonDecode(response.body);

    print(res["status"]);
    if (res["status"] == "1") {
      setState(() {
      error1 = true;
    });
    } else if (res["status"] == "ok") {
      setState(() {
      success = true;
      ip = interface[0].addresses[0].address;
    });
  }
  }

  //useEffect()
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadInfo());
  }

  @override
  Widget build(BuildContext context) {
    return success ? Account(user: myController.text, password: myPassController.text, ip: ip) : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Username',
            ),
            controller: myController,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            obscureText:true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Password',
            ),
            controller: myPassController,
          ),
        ),  
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Center(
          child: ElevatedButton(
          onPressed: _submitEvent,
          child: const Text('Login'),
         
         ))) ,   
         Center(
          child: ElevatedButton(
          onPressed: _submitSignUp,
          child: const Text('Sign Up'),
         )) ,
         error1 ? AlertDialog(
              title: const Text('Error: already existing user'),
              content: const Text('If you laready have an account, login in!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => setState(() {
                    error1 = false;
                  }),
                  child: const Text('OK'),
                ),
              ],
            ) :  const Text(""), 
        error2 ? AlertDialog(
              title: const Text('Error: non-existent user'),
              content: const Text('You have to create an account before login in!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => setState(() {
                    error2 = false;
                  }),
                  child: const Text('OK'),
                ),
              ],
            ) :  const Text(""),
        error3 ? AlertDialog(
              title: const Text('Error: wrong password'),
              content: const Text('If you forgot your password, you can reset it using the reset password button.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => setState(() {
                    error3 = false;
                  }),
                  child: const Text('OK'),
                ),
              ],
            ) :  const Text(""),
      ],
    );
  }
}


class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const ConnectForm()
    );
  }
}