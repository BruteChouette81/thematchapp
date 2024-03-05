
//import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:latlng/latlng.dart';
import 'package:http_parser/http_parser.dart';

import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thematchapp/main.dart';

import './utils/get_server.dart';

String server = getString(); //http://localhost:8000

class Account extends StatefulWidget{
  const Account({super.key, required this.user, required this.password, required this.ip, required this.name, required this.bio, required this.sex, required this.age, required this.interests});
  
  final String user;
  final String password;
  final String ip;
  final String name;
  final String bio;
  final String sex;
  final int age;
  final List<String> interests;

  @override
  State<Account> createState() => _Account();

}

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key, required this.name, required this.bio});

  final String name;
  final String bio;
 

  @override
  State<AccountSettings> createState() => _AccountSetting();
}

class _AccountSetting extends State<AccountSettings> {

  final nameController = TextEditingController();
  final bioController = TextEditingController();

   Future<http.Response> newAccountInfos() async {
    var interface = await NetworkInterface.list();
    String ip = interface[0].addresses[0].address;

    return http.post(Uri.parse('$server/accountInfos'), headers: <String, String>{
      'content-type': 'application/json',
      'name': nameController.text,
      'ip': ip,
      'bio': bioController.text
    } ); 
  }

  void loadController() {
    nameController.text = widget.name;
    bioController.text = widget.bio;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadController());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _submitEvent() async {
    //print("FORM: submited");
    if (nameController.text != "") { 
      //var response = await newAccountInfos();
      await newAccountInfos();
      //print(response);
    } else {
      //print("need name");
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

  //bool removed = false;
  final ageController = TextEditingController();
  final intController = TextEditingController();
  String sex = "male"; //0 female, 1 male 
  final List<String> possibleSex = <String>['male', 'female'];
  final interestsString = <String>[]; 

  final _events = <Widget>[];
  final interests = <Widget>[];

  bool displaySetting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadEvents());
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    ageController.dispose();
    intController.dispose();
    super.dispose();
  }

  void removeInterest() {
    //print("removed");
  }

  void addInterest() {
    interestsString.add(intController.text); //add interest to the list of intrests
/*suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: addIntrestFilter,
                ), */
    interests.add(
      Container(width:150, height: 50, decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              color: Color.fromARGB(137, 0, 140, 255),

            ), child: Row(children: [Text(intController.text), IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: removeInterest,
                ),],)
      )
    );
    setState(() {});
  }

  Future removeEvent(eventID) async {
    var interface = await NetworkInterface.list();
    String ip2 = interface[0].addresses[0].address;
    await http 
      .post(Uri.parse('$server/unQueue'), headers: <String, String>{ //final response = 
      'content-type': 'application/json',
      'ip': ip2,
      'id': eventID.toString()
    });
    //print(response);
  }


  Future loadEvents() async {
    var interface = await NetworkInterface.list();
    String ip2 = interface[0].addresses[0].address;

    sex = widget.sex;
    ageController.text = widget.age.toString();
    //print(widget.interests.length);
    for (int i=0; i<widget.interests.length; i++) {
       interests.add(
      Container(width:150, height: 50, decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              color: Color.fromARGB(137, 0, 140, 255),

            ), child: Row(children: [Text(widget.interests[i]), IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: removeInterest,
                ),],)
      )
    );
    }
    setState(() {});

    final response = await http
      .post(Uri.parse('$server/queueList'), headers: <String, String>{
      'content-type': 'application/json',
      'ip': ip2
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //print(response);
      //print(response.body);

      final events = jsonDecode(response.body);
      //print(events);
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
              //print(coords.latitude);
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
      
      //Uint8List? fileBytes = result.files.first.bytes;
      //String fileName = result.files.first.name;
      var interface = await NetworkInterface.list();
      String ip2 = interface[0].addresses[0].address;
      /*
      final response = await http
      .post(Uri.parse('http://localhost:8000/profilePicture'), headers: <String, String>{
      'content-type': 'application/json; charset=UTF-8',
      'ip': ip2,
      }, body: jsonEncode(<String, dynamic>{"file": file}),  );*/
      
      
      var request = http.MultipartRequest("POST", Uri.parse('$server/profilePicture'));
      request.fields['ip'] = ip2;
      request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('image', 'png'), //new MediaType('application', 'x-tar')
      ));
      //print(request);
      request.send().then((response) {
        if (response.statusCode == 200) {}
      });

    } else {
      //print("problem");
    }
  }


  Future disconnect() async {
    await http
      .post(Uri.parse('$server/disconnect'), headers: <String, String>{ //final response = 
      'content-type': 'application/json',
      'ip': widget.ip
    });
    //print(response);
  }

  Future _submitFilters() async {
   await http 
      .post(Uri.parse('$server/filters'), headers: <String, String>{ // final response = 
      'content-type': 'application/json',
      'ip': widget.ip,
      'sex': sex,
      'age': ageController.text,
      'interests': interestsString.toString()

    });
    //print(response);

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
      body: AccountSettings(name:widget.name, bio:widget.bio))
       : SingleChildScrollView( child: Column( children: [Padding(padding: const EdgeInsets.all(8.0), child:Container(width:300, height: 350, decoration: const BoxDecoration(
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
          Text("Name: ${widget.name}"),
          Text("Bio: ${widget.bio}"),
          Padding(padding: const EdgeInsets.all(4.0), child: ElevatedButton(onPressed: activateSetting, child: const Text('Settings')), ),
          Padding(padding: const EdgeInsets.all(4.0), child: ElevatedButton(onPressed: disconnect, child: const Text('Disconnect')), ),

        ], ), )))
      ),Column( children: [Padding(padding: const EdgeInsets.all(8.0), child:Container(width:300, height: 450, decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              color: Color.fromARGB(137, 0, 140, 255),
            ), child:Padding(padding: const EdgeInsets.all(8.0), child:Center(child:Column(children: <Widget>
            [ const Text("Personnal filters:"),
              //the age - number 
              TextField(
              decoration: const InputDecoration(labelText: "Enter your age"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
               controller: ageController, // Only numbers can be entered
            ),
              //the sexe - dropdown
              DropdownButton<String>(
                value: sex,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.blue),
                underline: Container(
                  height: 2,
                  color: Colors.blue,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    sex = value!;
                  });
                },
                items: possibleSex.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              //sports interests - textfield
              TextField(
              decoration:  InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Your Interest',
                suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: addInterest,
                ),
                ),
                controller: intController,
              ),
              Column(children: interests,),
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Center(
              child: ElevatedButton(
              onPressed: _submitFilters,
              child: const Text('Update filters'),
            
            ))),
            ],
            )))))]) ,Center(
      
            child: Column(
      
              children:  _events
            )
          )]));
  }
}