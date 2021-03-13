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

  int _currentIndex = 0;
  final List<Widget> _children = [
    MainPage(),
    Dictionary(),
    Watering()
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
              icon: Icon(Icons.stream),
              title: Text('Watering')
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

  FirebaseAuth currUser = FirebaseAuth.instance;
  var user = FirebaseAuth.instance.currentUser;
  @override


  Widget build(BuildContext context) {
    final title = 'Plants';
    Query query = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('plants');
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
              itemBuilder: (context, index) => Plants(querySnapshot.docs[index]),
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

