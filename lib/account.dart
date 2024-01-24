
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:http_parser/http_parser.dart';

import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thematchapp/main.dart';

class Account extends StatefulWidget{
  const Account({super.key, required this.user, required this.password, required this.ip});
  
  final String user;
  final String password;
  final String ip;

  @override
  State<Account> createState() => _Account();

}

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSetting();
}

class _AccountSetting extends State<AccountSettings> {

  final nameController = TextEditingController();
  final bioController = TextEditingController();

   Future<http.Response> newAccountInfos() async {
    var interface = await NetworkInterface.list();
    String ip = interface[0].addresses[0].address;

    return http.post(Uri.parse('http://localhost:8000/accountInfos'), headers: <String, String>{
      'content-type': 'application/json',
      'name': nameController.text,
      'ip': ip,
      'bio': bioController.text
    } ); 
  }
  

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _submitEvent() async {
    print("FORM: submited");
    if (nameController.text != "") { 
      var response = await newAccountInfos();
      print(response);
    } else {
      print("need name");
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Your name',
            ),
            controller: nameController,
          ),
        ), 
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Your bio',
            ),
            controller: bioController,
          ),
        ), 
         Center(child: ElevatedButton(
          onPressed: _submitEvent,
          child: const Text('Submit'),
         ))
      ]
    );
  }
}

class _Account extends State<Account> {

  final _events = <Widget>[];

  bool displaySetting = false;

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadEvents());
  }

  Future removeEvent(eventID) async {
    var interface = await NetworkInterface.list();
    String ip2 = interface[0].addresses[0].address;
    final response = await http
      .post(Uri.parse('http://localhost:8000/unQueue'), headers: <String, String>{
      'content-type': 'application/json',
      'ip': ip2,
      'id': eventID.toString()
    });
    print(response);
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
      /**
       * Column(children: [Text(), ElevatedButton(
          onPressed: () => removeEvent(events["events"][i]["id"]),
          child: const Text('Remove'),
         )],)
       */

      //update the state at refreash
      setState(() {
        if(events["events"].length > 0) {
          for(var i =0; i<events["events"].length; i++) {
              List latlng = events['events'][i]['coords'].split(", ");
              LatLng coords = LatLng(double.tryParse(latlng[0]) ?? 00.00, double.tryParse(latlng[1]) ?? 00.00);
              print(coords.latitude);
              _events.add(Events(name: events["events"][i]["name"], ip: ip2, event: events["events"][i], connected: true, coords: coords, myItem: false));
          }
        } else {
          _events.add(const Text("No current events"));
        }
       
        
      });
  }
  }

  void uploadPP() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      
      Uint8List? fileBytes = result.files.first.bytes;
      //String fileName = result.files.first.name;
      var interface = await NetworkInterface.list();
      String ip2 = interface[0].addresses[0].address;
      /*
      final response = await http
      .post(Uri.parse('http://localhost:8000/profilePicture'), headers: <String, String>{
      'content-type': 'application/json; charset=UTF-8',
      'ip': ip2,
      }, body: jsonEncode(<String, dynamic>{"file": file}),  );*/
      
      
      var request = http.MultipartRequest("POST", Uri.parse('http://localhost:8000/profilePicture'));
      request.fields['ip'] = ip2;
      request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('image', 'png'), //new MediaType('application', 'x-tar')
      ));
      print(request);
      request.send().then((response) {
        if (response.statusCode == 200) print("Uploaded!");
      });

    } else {
      print("problem");
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

  void activateSetting() {
    displaySetting = !displaySetting;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
      return displaySetting ? Scaffold( appBar: AppBar(
        //navigation
        
        backgroundColor: Colors.green[300],
        title: const Text("Account information"),
        leading: IconButton (
                 icon: const Icon(Icons.arrow_back), 
                 onPressed: activateSetting
            ),
      ),
      body: const AccountSettings())
       : Column( children: [Padding(padding: const EdgeInsets.all(8.0), child:Container(width:300, height: 350, decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              color: Color.fromARGB(137, 0, 140, 255),
            ), child: Scaffold( 
      backgroundColor: Colors.transparent,
      body: Center( child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: GestureDetector(
          onTap: () => uploadPP(),
           // Image tapped
          child: Image.network("https://www.pngall.com/wp-content/uploads/5/Profile-PNG-Free-Download.png", width: 200, height: 200 ))) ,
          Text("user:${widget.user}"),
          Text("password:${widget.password}"),
          Text("ip:${widget.ip}"),
          ElevatedButton(onPressed: activateSetting, child: const Text('Settings')),
          ElevatedButton(onPressed: disconnect, child: const Text('Disconnect')),

        ], ), )))
      ), Center(
      
            child: Column(
      
              children: _events
            )
          )]);
  }
}