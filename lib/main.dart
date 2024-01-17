
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:latlong2/latlong.dart';
//import 'package:latlong2/latlong.dart';
import 'package:thematchapp/friends.dart';
import 'package:thematchapp/minimap.dart';
import 'package:thematchapp/myCalendar.dart';
import 'package:latlng/latlng.dart';

import './profilepage.dart';
import './myposts.dart';
//import './rastermap.dart';
import './markers.dart';

import 'package:http/http.dart' as http; //http package

//import 'package:google_maps_flutter/google_maps_flutter.dart'; //google maps package
//import 'package:map/map.dart';
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

  LatLng _pointedLocation = const LatLng(0.0, 0.0);

  void tapScreen(LatLng position) {
    //return the selected position
    setState(() {
      _pointedLocation = position;
    });
    
  }

  Future<http.Response> createNewEvent() async {
    var interface = await NetworkInterface.list();
    String ip = interface[0].addresses[0].address;

    return http.post(Uri.parse('http://localhost:8000/newEvent'), headers: <String, String>{
      'content-type': 'application/json',
      'event_name': myController.text,
      'ip': ip,
      'coords': '${_pointedLocation.latitude.toString()}, ${_pointedLocation.longitude.toString()}',
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
    if (myController.text != "") { 
      var response = await createNewEvent();
      print(response);
    } else {
      print("need name");
    }
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
      body: MarkersPage(tapScreen: tapScreen) //add marker for events
  
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
          child:  Text("Insert a location: ${_pointedLocation.latitude.toString()}, ${_pointedLocation.longitude.toString()}") ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Center(
            child: ElevatedButton(
            onPressed: _displayMap,
            child: const Text('Toggle Map'),
          )) ),
          const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child:  Text("Add the day or the starting day of the event") ),
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
       )) ), Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Text('selected day: $_selectedDay')),   
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
/*
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
*/
//event component
class Events extends StatefulWidget {
  const Events({super.key, required this.name, required this.ip, required this.event, required this.connected, required this.coords, required this.myItem});
  /*
  Column(children: [Text(eventName), ElevatedButton(
          onPressed:  () => { if (connected) {
            http
      .post(Uri.parse('http://localhost:8000/queue'), headers: {
      'content-type': 'application/json',
      'ip': ip,
      'id': events['eventInfos'][i]['id'].toString(),
    }) 
  } }, //
          child: const Text('Subscribe'),
         )],)*/
  // config statefull widget
  final bool myItem;
  final LatLng coords;
  final String name;
  final String ip;
  final dynamic event;
  final bool connected;

  @override
  State<Events> createState() => _Events();
}

class _Events extends State<Events> {

  @override
  Widget build(BuildContext context) {
    //build UI function
    return widget.myItem ? Padding(padding: const EdgeInsets.all(8.0), child:Container(width:300, height: 200, decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              color: Color.fromARGB(137, 0, 140, 255),
            ), child: Scaffold( 
      backgroundColor: Colors.transparent,
      body: Center(child:Column(
      
      children: [Text(widget.name), MinimapPage(coords: widget.coords) ,Padding(padding: const EdgeInsets.all(7.0), child: ElevatedButton(
          onPressed:  () => { if (widget.connected) {
            http
      .post(Uri.parse('http://localhost:8000/queue'), headers: {
      'content-type': 'application/json',
      'ip': widget.ip,
      'id': widget.event['id'].toString(),
    }) 
  } else {
    print("not connected")
  } },
          child: const Text('Subscribe'),
         ), )],),) ) ) ,) :  Padding(padding: const EdgeInsets.all(8.0), child:Container(width:300, height: 200, decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              color: Color.fromARGB(137, 0, 140, 255),
            ), child: Scaffold( 
      backgroundColor: Colors.transparent,
      body: Center(child:Column(
      
      children: [Text(widget.name), MinimapPage(coords: widget.coords) ,Padding(padding: const EdgeInsets.all(7.0), child: ElevatedButton(
          onPressed:  () => { if (widget.connected) {
            http
      .post(Uri.parse('http://localhost:8000/unQueue'), headers: {
      'content-type': 'application/json',
      'ip': widget.ip,
      'id': widget.event['id'].toString(),
    }) 
  } else {
    print("not connected")
  } },
          child: const Text('Remove'),
         ), )],),) ) ) ,);
  }

}
//Home page

class _HomePageState extends State<TMA> {
  int _counter = 0;
  bool _formActive = false;
  bool connected = false;
  String iip = "";
  final _listOfEvents = <String>[];
  final _homeWidgets = <Widget>[];

  //event research settings/filter
  final List<String> list = <String>['Most recent', 'Location(near me)', 'My dispos', 'Recommended'];
  String dropdownValue = "Most recent";


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
        for (int i = 0; i<events["connected"].length; i++) {
          if(ip == events["connected"][i]) {
            connected = true;
          }
        }

        if (events["events"].length > 0) {

          for (int i=0; i<events["events"].length; i++) {
            String eventName = events["events"][i];
            //get the coords
            List latlng = events['eventInfos'][i]['coords'].split(", ");
            LatLng coords = LatLng(double.tryParse(latlng[0]) ?? 00.00, double.tryParse(latlng[1]) ?? 00.00);
            print(coords.latitude);
            _homeWidgets.add(Events(name: eventName, ip: ip, event: events['eventInfos'][i], connected: connected, coords:  coords, myItem: true,));
          }
        } else {
          _homeWidgets.add(const Text("No current Events..."));
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
       
        child: Column(children: [const Text("Research filters"), DropdownButton<String>(
      value: dropdownValue,
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
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ), Column(
          
          children: _homeWidgets
        )]),
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



