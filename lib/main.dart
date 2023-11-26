
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:thematchapp/friends.dart';
import 'package:thematchapp/myCalendar.dart';

import './profilepage.dart';
import './myposts.dart';
import './rastermap.dart';

import 'package:http/http.dart' as http; //http package

//import 'package:google_maps_flutter/google_maps_flutter.dart'; //google maps package
import 'package:map/map.dart';
import 'package:table_calendar/table_calendar.dart';

import 'dart:io';

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
  bool mapDisplay = false;

  DateTime _selectedDay = DateTime.now(); 
  

  Future<http.Response> createNewEvent() async {
    var interface = await NetworkInterface.list();
    String ip = interface[0].addresses[0].address;
    return http.post(Uri.parse('http://localhost:8000/newEvent'), headers: <String, String>{
      'content-type': 'application/json',
      'event_name': myController.text,
      'ip': ip,
      'coords': "(0, 0)",
      "date": '$_selectedDay'
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
    var response = await createNewEvent();
    print(response);
  }

  void _displayMap() {
    setState(() {
      if (mapDisplay) {
        mapDisplay = false;
      } else {
         mapDisplay=true;
      } 
     
    });
  }
  /*Center(child: ElevatedButton(
          onPressed: _displayMap,
          child: const Text('Map view'),
         )) */

  @override
  Widget build(BuildContext context) {
    return mapDisplay ? Scaffold(
      appBar: AppBar(
        //navigation
        
        backgroundColor: Colors.green[300],
        title: const Text("Map selector"),
        leading: IconButton (
                 icon: const Icon(Icons.arrow_back), 
                 onPressed: _displayMap
            ),
      ),
      body: const RasterMapPage() //add marker for events
  
      ) : Column(
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Center(
            child: ElevatedButton(
            onPressed: _displayMap,
            child: const Text('Toggle Map'),
          )) ),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Center(
            child: TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _selectedDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
          },
       )) ),   
       Center(child: ElevatedButton(
          onPressed: _submitEvent,
          child: const Text('Submit'),
         ))
         
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
//navbar

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key, required this.ip, required this.connected});

  // config statefull widget

  final String ip;
  final bool connected;

  @override
  State<NavDrawer> createState() => _NavDrawer();
}

class _NavDrawer extends State<NavDrawer> {

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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.black, fontSize: 25),
            )
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          widget.connected ? ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Friends'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Friends()),
              );
            },
          ) : const Text(""),
          widget.connected ? ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('My Calendar'),
            onTap: () => {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyCalendar()),
              )},
          ) : const Text(""),
          widget.connected ? ListTile(
            leading: const Icon(Icons.add_rounded),
            title: const Text('My post'),
            onTap: () => { Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPosts()),
              )
            },
          ) : const Text(""),
           widget.connected ? ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => {
              disconnect()
              },
          ) : const Text(""),
        ],
      ),
    );
  }
}

//map page

class GMPage extends StatefulWidget {
  const GMPage({super.key});

  // config statefull widget

  @override
  State<GMPage> createState() => _GoogleMapPage();
}

class _GoogleMapPage extends State<GMPage> {
  //late GoogleMapController mapController;

  

  //final LatLng _center = const LatLng(-33.86, 151.20);

  //void _onMapCreated(GoogleMapController controller) {
  //  mapController = controller;
  //}

  @override
  Widget build(BuildContext context) {
    //build UI function
    return Scaffold(
      appBar: AppBar(
        //navigation
        
        backgroundColor: Colors.green[300],
        title: const Text("Map selector"),
      ),
      body: const RasterMapPage() //add marker for events
  
      );
  }
}

/*
late GoogleMapController mapController;
      
        final LatLng _center = const LatLng(-33.86, 151.20);
      
        void _onMapCreated(GoogleMapController controller) {
          mapController = controller;
        }
*/

//Home page

class _HomePageState extends State<TMA> {
  int _counter = 0;
  bool _formActive = false;
  bool connected = false;
  String iip = "";
  final _listOfEvents = <String>[];
  final _homeWidgets = <Widget>[];

  Future loadEvents() async {
    var interface = await NetworkInterface.list();
    String ip = interface[0].addresses[0].address;
    iip = ip;

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
        if (events["events"].length > 0) {
          for (int i=0; i<events["events"].length; i++) {
            String eventName = events["events"][i];
            _homeWidgets.add(Column(children: [Text(eventName), ElevatedButton(
          onPressed:  () => { 
            http
      .post(Uri.parse('http://localhost:8000/queue'), headers: {
      'content-type': 'application/json',
      'ip': ip,
      'id': events['eventInfos'][i]['id'].toString(),
    })}, //
          child: const Text('Subscribe'),
         )],));
          }
        } else {
          _homeWidgets.add(const Text("No current Events..."));
        }

        for (int i = 0; i<events["connected"].length; i++) {
          if(ip == events["connected"][i]) {
            connected = true;
          }
        }
        
      });
        

      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('ERROR: Failed to load events');
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

  /*
  leading: const IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu'
          onPressed: NavDrawer(),
          
        ), */

  @override
  Widget build(BuildContext context) {
    //build UI function
    return Scaffold(
      drawer: NavDrawer(ip: iip, connected: connected),
      appBar: AppBar(
        //navigation
        
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
      floatingActionButton: connected ? !_formActive ? FloatingActionButton(
        onPressed: _activateForm,
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ) : FloatingActionButton(
        onPressed: _activateForm,
        tooltip: 'Cancel',
        child: const Icon(Icons.cancel),
      ) : FloatingActionButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('You must be connected in order to create events.'),
            content: const Text('Click on the Profile section in order to create or connect to an account!'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        tooltip: 'Connect',
        child: const Icon(Icons.login),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}



