
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_login.dart';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification.dart';

Future<TimeOfDay> _selectTime(BuildContext context, DateTime selectedTime) {

  return showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: selectedTime.hour, minute: selectedTime.minute),
  );
}

class WaterStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Grid List';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: 2,
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
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth currUser = FirebaseAuth.instance;
  var user = FirebaseAuth.instance.currentUser;

  DateTime selectedTime = DateTime.now();


  File _image;
  String _species;
  String _notes;
  String _frequency;
  int freq;
  String currentSelectedValue;

  String day;
  String currentSelectedDay;
  int hour;
  int minute;


  @override
  void initState() {
    super.initState();
  }

  Future<void> open_camera()
  async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });

  }
  Future<void> open_gallery()
  async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;

    });

  }

  void species(species)
  async {
    setState(() {
      _species = species;

    });

  }

  void notes(notes)
  async {
    setState(() {
      _notes = notes;

    });

  }

  void frequency(frequency)
  async {
    setState(() {
      _frequency = frequency;
      freq = int.parse(_frequency);
    });

  }


  void submitInfo()
  async {
    //this will take the insantiated image and upload it to the firebase database
    String imgurl;
    String fileName = _image.path;
    Reference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),

    );
    await DatabaseService(uid: user.uid).updateUserData(_species, _notes, freq, downloadUrl);
  }



  @override
  Widget build(BuildContext context) {
    TextEditingController speciesController = TextEditingController();
    TextEditingController plantNotes = TextEditingController();

    List<String> _locations = ['1', '2', '3', '4', '5', '6', '7'];

    List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday','Sunday']; // Option 1

    return Scaffold(
        resizeToAvoidBottomPadding: false,
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

                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: TextFormField(
                        onChanged: (text) {
                          species(text);
                        },
                        decoration: InputDecoration(
                          labelText: "Enter plant species",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a plant species';
                          } else if (value.length < 2) {
                            return 'Please enter something with at least 2 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: TextFormField(
                        onChanged: (text) {
                          notes(text);
                        },
                        decoration: InputDecoration(
                          labelText: "Plant notes",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter any necessary notes for this plant';
                          } else if (value.length < 2) {
                            return 'Please enter something with at least 2 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: DropdownButton<String>(
                        //hint: Text("Select Device"),
                        value: currentSelectedValue,
                        isDense: true,
                        onChanged: (newValue) {
                          frequency(newValue);
                          setState(() {
                            currentSelectedValue = newValue;
                            frequency(newValue);
                          });
                        },
                        items: _locations.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        children: <Widget>[
                          DropdownButton<String>(
                            hint: Text("DAY"),
                            value: currentSelectedDay,
                            isDense: true,
                            onChanged: (newValue) {

                              setState(() {
                                currentSelectedDay = newValue;
                                day = currentSelectedDay;
                              });
                            },
                            items: _days.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          RaisedButton(
                              child: Text(DateFormat('hh:mm aa').format(selectedTime)),
                              onPressed: () async {
                              final time = await _selectTime(context, selectedTime);
                              if(time == null) return;

                              setState(() {
                                hour = time.hour;
                                minute = time.minute;
                                selectedTime = DateTime(
                                  selectedTime.year,
                                  selectedTime.month,
                                  selectedTime.day,
                                  time.hour,
                                  time.minute
                                );
                              });
                            }
                          )
                        ],
                      )
                    ),
                    SizedBox(height: 20.0,),
                    RaisedButton(
                      child: Text("Add plant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      onPressed: (){
                        submitInfo();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.blue)
                      ),
                      elevation: 5.0,
                      color: Colors.blue,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                      splashColor: Colors.grey,
                    ),
                  ],
                )

              ],
            ),
          ),
        )

    );

  }
}
