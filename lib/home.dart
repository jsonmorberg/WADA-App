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
import 'water_stats.dart';
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
