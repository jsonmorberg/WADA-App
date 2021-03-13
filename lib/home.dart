import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wada/water_stats.dart';
import 'package:wada/watering.dart';
import 'signup.dart';
import 'dictionary.dart';
import 'water_stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

void scheduleDailyTenAMNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'WADA',
      'Time to water',
      _nextInstanceOfTenAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'daily notification channel id',
            'daily notification channel name',
            'daily notification description'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);
}

tz.TZDateTime _nextInstanceOfTenAM() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
  tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

class Home extends StatelessWidget {
  Home({this.uid});
  final String uid;
  final String title = "Home";
  final player = AudioCache();

  @override
  Widget build(BuildContext context) {
    player.loadAll(['yup.wav', 'wada_better.mp3']);
    player.play("wada_better.mp3");
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
      body: Center(child: HomeState()),
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

    configureLocalTimeZone();
    scheduleDailyTenAMNotification();

    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher.png');

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
  final List<Widget> _children = [MainPage(), Dictionary(), Watering()];
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
            icon: Icon(Icons.map),
            title: Text('Map'),
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.stream), title: Text('Watering'))
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 0) {
        Widget build(BuildContext context) {
          Text(
            "text",
            textAlign: TextAlign.center,
          );
        }
      }
    });
  }
}

class MainPage extends StatelessWidget {
  FirebaseAuth currUser = FirebaseAuth.instance;
  var user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final title = 'Plants';
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('plants');
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, stream) {
            if (stream.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (stream.hasError) {
              return Center(child: Text(stream.error.toString()));
            }

            QuerySnapshot querySnapshot = stream.data;

            return ListView.builder(
              itemCount: querySnapshot.size,
              itemBuilder: (context, index) =>
                  Plants(querySnapshot.docs[index]),
            );
          },
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
