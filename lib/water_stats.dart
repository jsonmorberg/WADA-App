import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class WaterStats extends StatefulWidget {
  final String name;

  WaterStats({this.name});
  @override
  State<StatefulWidget> createState() => _WaterStatsState();
}

class _WaterStatsState extends State<WaterStats> {
  String title = 'Watering';
  String day = "Today";
  String room1 = "Bedroom";
  String room2 = "Living Room";

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: title,
      home: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Center(child: _buildColumns(),
          )
      ),
    );
  }

  Widget _buildRoom() => ListView();

  Widget _buildRoomView() => Column();

  Widget _buildVineColumn() => Column();

  Widget _buildColumns() => Container(
    decoration: BoxDecoration(
      color: Colors.black45,
    ),
    child: Column(
      children: [
        _buildVineColumn(),
        _buildRoomView(),
      ],
    ),
  );

}
