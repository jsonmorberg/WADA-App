import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wada/water_stats.dart';
import 'signup.dart';
import 'dart:io';
import 'dart:async';
import 'dictionary.dart';
import 'package:image_picker/image_picker.dart';
import 'profile.dart';
import 'placeholder_widget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class Home extends StatelessWidget {
  Home({this.uid});
  final String uid;
  final String title = "Home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth auth = FirebaseAuth.instance;
                auth.signOut().then((res) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                          (Route<dynamic> route) => false);
                });
              },
            )

          ],

        ),
        body: Center(

          child: HomeState()

        ),

        );
  }
}
class HomeState extends StatefulWidget {
  HomeState({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _HomeState extends State<HomeState> {



  void initState(){
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/water');

    var initializationSettingsIOS =
        IOSInitializationSettings();

    var initSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
        initSettings, onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NotificationScreen(
        payload: payload,
      );
    }));
  }

  int _currentIndex = 0;
  final List<Widget> _children = [
    MainPage(),
    Dictionary(),
    WaterStats()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Plants'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            title: Text('Dictionary'),
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Water')
          )
        ],
      ),
    );
  }
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if(_currentIndex == 0) {
        Widget build(BuildContext context) {
          Text("text", textAlign: TextAlign.center,);
        }
      }
    });
  }
}



class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Plants';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: 1,
          // Generate 100 widgets that display their index in the List.
          children: List.generate(100, (index) {
            return Center(
              child: Text(
                'Item $index',
                style: Theme.of(context).textTheme.headline5,
              ),
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPlant()),
            );
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),


      ),
    );
  }

}
class AddPlant extends StatefulWidget {
  AddPlant({Key key}) : super(key: key);

  @override
  _AddPlant createState() => _AddPlant();
}

class _AddPlant extends State {

  File _image;
  @override
  void initState() {
    super.initState();
  }



  void open_camera()
  async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });

  }
  void open_gallery()
  async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Add plant profile"),
          backgroundColor: Colors.black45,),
        body: Center(
          child: Container(
            child: Column(
              children: [
                Container(
                  color: Colors.lightGreen,
                  height: 200.0,
                  width: 200.0,
                  child: _image == null ? Text("Still waiting!") : Image.file(_image),),
                FlatButton(
                  color: Colors.deepOrangeAccent,
                  child: Text("Open Camera", style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    open_camera();
                  },),
                FlatButton(
                  color: Colors.limeAccent,

                  child:Text("Open Gallery", style: TextStyle(color: Colors.black),),
                  onPressed: (){
                    open_gallery();
                  },
                ),
                FlatButton(
                  color: Colors.redAccent,

                  child:Text("Test Notification", style: TextStyle(color: Colors.black),),
                  onPressed: (){
                    showNotification();
                  },
                )
              ],
            ),
          ),
        )

    );

  }

  showNotification() async {
    var android = new AndroidNotificationDetails(
        'id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'Flutter devs', 'Flutter Local Notification Demo', platform,
        payload: 'Welcome to the Local Notification demo ');
  }
}


class NotificationScreen extends StatelessWidget {
  String payload;

  NotificationScreen({
    @required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payload),
      ),
    );
  }
}