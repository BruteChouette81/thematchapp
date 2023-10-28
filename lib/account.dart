
import 'package:flutter/material.dart';

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
          ElevatedButton(onPressed: disconnect, child: const Text('Disconnect'))

        ]
      );
  }
}