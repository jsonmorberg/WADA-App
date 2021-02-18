import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class Watering extends StatefulWidget {
  final String name;

  Watering({this.name});
  @override
  State<StatefulWidget> createState() => _WateringState();
}

class _WateringState extends State<Watering> {
  String title = 'Watering';
  String day = "Today";
  String room1 = "Bedroom";
  String room2 = "Living Room";
  /*Image plant1 = new Image.asset("assets/images/chamaedorea.jpg");
  Image plant2 = new Image.asset("assets/images/planterina.jpg");*/
  String plantImage1 = "assets/images/chamaedorea.jpg";
  String plantImage2 = "assets/images/planterina.jpg";
  String plantName1 = "Chamaedorea";
  String plantName2 = "Planterina";
  String waterAmount1 = "1 oz";
  String waterAmount2 = "5 oz";

  String dropdownValue = "Today";

  int streak = 0;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: title,
      home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(title),
          ),
          body: Center(child: _buildColumns(),
          )
      ),
    );
  }

  Widget _buildRoom(String roomName, String plantImage, String plantName, String waterAmount ) => Container(
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.green),
          ),
          margin: const EdgeInsets.all(4),
          child: Image.asset(
            plantImage,
            height: 100,
            width: 100,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  plantName,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                waterAmount,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildRoomView() => Column (
      children: [
      Container(
      child: _getScheduleForDay(),
  alignment: Alignment.centerLeft,
  decoration: BoxDecoration(
  border: Border.fromBorderSide(bottom),width: 2, color: Colors.black12),
  ),
  ),
  _buildRoom(room1, plantImage1, plantName1, waterAmount1),
  _buildRoom(room2, plantImage2, plantName2, waterAmount2)
  ],
  );

  Widget _getScheduleForDay() => DropdownButton(
    value: dropdownValue,
    icon: Icon(Icons.arrow_drop_down),
    iconSize: 48,
    elevation: 16,
    style: TextStyle(
      color: Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),

    onChanged: (String newValue) {
      setState(() {
        dropdownValue = newValue;
      });
    },
    items: <String>["Today", "Tomorrow", "Thursday", "Friday"]
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
  );

  Widget _buildVineView() => Container(

  );

  Widget _buildColumns() => Container(
    decoration: BoxDecoration(
      color: Colors.black45,
    ),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildVineView(),
        ),
        Expanded(
          flex: 7,
          child: _buildRoomView(),
        ),
      ],
    ),
  );

}
