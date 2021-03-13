import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';

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
  //location
  LocationData _currentPosition;
  String _address,_dateTime;
  GoogleMapController mapController;
  Marker marker;
  Location location = Location();
  GoogleMapController _controller;
  LatLng _initialcameraposition = LatLng(0.5937, 0.9629);

  File _image;
  String _species;
  String _notes;
  String _frequency;
  String _room;
  int freq;
  var _days = [false,false,false,false,false,false,false];

  final values = List.filled(7, false);

  List<String> _rooms = [
    "Living Room",
    "Bedroom",
    "Kitchen",
    "Office",
    "Bathroom"
  ];
  int selectedRoom = 0;

  @override

  getLoc() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialcameraposition = LatLng(_currentPosition.latitude,_currentPosition.longitude);
    location.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.longitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition = LatLng(_currentPosition.latitude,_currentPosition.longitude);

        DateTime now = DateTime.now();
        _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
        _getAddress(_currentPosition.latitude, _currentPosition.longitude)
            .then((value) {
          setState(() {
            _address = "${value.first.addressLine}";

          });
        });
      });
    });
  }

  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }

  void initState() {
    super.initState();
    getLoc();
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

  void days(days)
  async {
    setState(() {
      _days = values;
    });
  }

  void room(room)
  async {
    setState(() {
      _room = _rooms[selectedRoom];
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
    //await DatabaseService(uid: user.uid).updateUserData(_species, _notes, freq, downloadUrl);\
    await DatabaseService(uid: user.uid).updateUserData(_species, _room, _days, _notes, downloadUrl, _currentPosition.latitude.toInt(), _currentPosition.longitude.toInt());
  }

  /* Start DirectSelect */
  DirectSelectItem<String> getDropDownMenuItem(String value) {
    return DirectSelectItem<String>(
        itemHeight: 56,
        value: value,
        itemBuilder: (context, value) {
          return Text(value);
        });
  }

  _getDslDecoration() {
    return BoxDecoration(
      border: BorderDirectional(
        bottom: BorderSide(width: 1, color: Colors.black12),
        top: BorderSide(width: 1, color: Colors.black12),
      ),
    );
  }
  /* End DirectSelect */

  @override
  Widget build(BuildContext context) {
    TextEditingController speciesController = TextEditingController();
    TextEditingController plantNotes = TextEditingController();
    List<String> _locations = ['1', '2', '3', '4', '5', '6','7']; // Option 1
    var currentSelectedValue;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text("Add plant profile"),
          backgroundColor: Colors.black45,),
        body: DirectSelectContainer(
          child: Container(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      color: Colors.lightGreen,
                      height: 200.0,
                      width: 200.0,
                      child: _image == null ? Text("Still waiting!", textAlign: TextAlign.center) : Image.file(_image),),
                    Column (
                      children: [
                        Container(
                          height: 100.0,
                          width: 180.0,
                          alignment: Alignment.center,
                          child:
                          FlatButton(
                            color: Colors.deepOrangeAccent,
                            child: Text("Open Camera", style: TextStyle(color: Colors.white),),
                            onPressed: (){
                              open_camera();
                            },),
                        ),
                        Container(
                          height: 100.0,
                          width: 180.0,
                          alignment: Alignment.center,
                          child:
                          FlatButton(
                            color: Colors.limeAccent,
                            child:Text("Open Gallery", style: TextStyle(color: Colors.black),),
                            onPressed: (){
                              open_gallery();
                            },
                          ),
                        ),
                      ],
                    )
                  ],
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
                        child: Column(
                            children: [
                              Text(
                                'Select Room\n',
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              DirectSelectList<String>(
                                  values: _rooms,
                                  /*onUserTappedListener: () {
                                  _showScaffold();
                                },*/
                                  defaultItemIndex:
                                  selectedRoom,
                                  itemBuilder: (String value) =>
                                      getDropDownMenuItem(value),
                                  focusedItemDecoration:
                                  _getDslDecoration(),
                                  onItemSelectedListener:
                                      (item, index, context) {
                                    selectedRoom = index;
                                    room(selectedRoom);
                                  }),
                            ]
                        ),
                        padding: EdgeInsets.only(left: 22)
                    ),
                    Padding(
                        padding: EdgeInsets.only(left:20.0, right: 20, bottom: 20),
                        child: Column(
                          children: [
                            Text(
                              'Select Days to Water\n',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            WeekdaySelector(
                              firstDayOfWeek: defaultFirstDayOfWeek - 1,
                              selectedFillColor: Colors.indigo,
                              onChanged: (v) {
                                setState(() {
                                  values[v % 7] = !values[v % 7];
                                  days(values);
                                });
                              },
                              values: values,
                            ),
                          ],
                        )
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
                    SizedBox(height: 20.0,),
                    RaisedButton(
                      child: Text("Add plant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      onPressed: (){
                        submitInfo();
                        Navigator.pop(context);
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