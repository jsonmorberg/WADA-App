import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weekday_selector/weekday_selector.dart';
class Plants extends StatelessWidget {
  /// Contains all snapshot data for a given movie.
  final DocumentSnapshot snapshot;

  /// Initialize a [Move] instance with a given [DocumentSnapshot].
  Plants(this.snapshot);

  /// Returns the [DocumentSnapshot] data as a a [Map].
  Map<String, dynamic> get plant {
    return snapshot.data();
  }

  /// Returns the movie poster.
  Widget get poster {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.grey)
      ),
      width: 125,
      height: 125,
      child: Center(child: Image.network(plant['imgurl'])),
    );
  }

  /// Returns plant details.
  Widget get details {
    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            name,
            room,
            if (plant['notes'] != null) notes,
            days,
          ],
        ));
  }

  /// Returns Plant name.
  Widget get name {
    return Text("${plant['name']}",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget get room {
    return Text("${plant['room']}",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  /// Returns metadata about the movie.
  Widget get notes {
    return Padding(
        padding: EdgeInsets.only(top: 8),
        child: Row(children: [
          Padding(
              child: Text('Notes: ${plant['notes']}'),
              padding: EdgeInsets.only(right: 8)),
        ]));
  }

  Widget get days {
    return Text(
      //plant['days'].toString(),
      getDayString(),
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
  }

  String getDayString() {
    List<String> d = ["S", "M", "T", "W", "Th", "F", "S"];
    String s = "";
    if (plant['days'] != null) {
      for (int i = 0; i < 7; i++) {
        if (plant['days'][i] == true) {
          s += d[i] + " ";
        }
      }
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditPlant(reqid: snapshot.id,)),
          );
        },
        child: Container(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Row(
            children: [
              poster,
              Flexible(child: details),
            ],
          ),
        )
    );
  }
}



class DatabaseService {
  final String uid;
  DatabaseService({ this.uid });
  final CollectionReference plantCollection = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData(String name, String room, List<bool> days,
      String notes, String img) async {
    DocumentReference docPlants = plantCollection.doc(uid);
    CollectionReference numerAtion = docPlants.collection('plants');
    String randomID = UniqueKey().toString();
    return await numerAtion.doc(randomID).set({
      'notes': notes,
      'name': name,
      'imgurl' : img,
      'days' : days,
      'room' : room,
    });

  }

  Future<void> editUserData(String name, String room, List<bool> days,
      String notes, String img, String ID) async {
    DocumentReference docPlants = plantCollection.doc(uid);
    CollectionReference numerAtion = docPlants.collection('plants');
    return await numerAtion.doc(ID).set({
      'notes': notes,
      'name': name,
      'imgurl' : img,
      'days' : days,
      'room' : room,
    });
  }

  Future<void> deletePlant(String name, String room, List<bool> days,
      String notes, String ID) async {
    DocumentReference docPlants = plantCollection.doc(uid);
    CollectionReference numerAtion = docPlants.collection('plants');

    return await numerAtion.doc(ID).delete();
  }

  Future<void> getuserData(String name, String notes, String img) async {
    DocumentReference docPlants = plantCollection.doc(uid);
    CollectionReference numerAtion = docPlants.collection('plants');
    //get the number of plants in the snapshot
    numerAtion.snapshots().length.toString();
  }
}


class EditPlant extends StatefulWidget {
  final String reqid;
  EditPlant({Key key, @required this.reqid}) : super(key: key);

  @override
  _EditPlant createState() => _EditPlant();
}

class _EditPlant extends State {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth currUser = FirebaseAuth.instance;
  var user = FirebaseAuth.instance.currentUser;
  io.File _image;
  String _species;
  String _notes;
  String _room;
  int freq;
  var _days = [false, false, false, false, false, false, false];

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
  EditPlant get widget => super.widget;
  void initState() {
    super.initState();
  }

  Future<void> open_camera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<void> open_gallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void species(species) async {
    setState(() {
      _species = species;
    });
  }

  void notes(notes) async {
    setState(() {
      _notes = notes;
    });
  }

  void days(days) async {
    setState(() {
      _days = values;
    });
  }

  void room(room) async {
    setState(() {
      _room = _rooms[selectedRoom];
    });
  }

  void submitInfo() async {
    //this will take the insantiated image and upload it to the firebase database
    String fileName = _image.path;
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
    );

    await DatabaseService(uid: user.uid)
        .editUserData(_species,_room,_days,_notes,downloadUrl,widget.reqid);
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
    List<String> _locations = ['1', '2', '3', '4', '5', '6', '7']; // Option 1
    var currentSelectedValue;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            child: DirectSelectContainer(
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
                          child: _image == null
                              ? Text("Still waiting!", textAlign: TextAlign.center)
                              : Image.file(_image),
                        ),
                        Column(
                          children: [
                            Container(
                              height: 100.0,
                              width: 180.0,
                              alignment: Alignment.center,
                              child: FlatButton(
                                color: Colors.deepOrangeAccent,
                                child: Text(
                                  "Open Camera",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  open_camera();
                                },
                              ),
                            ),
                            Container(
                              height: 100.0,
                              width: 180.0,
                              alignment: Alignment.center,
                              child: FlatButton(
                                color: Colors.limeAccent,
                                child: Text(
                                  "Open Gallery",
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
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
                            child: Column(children: [
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
                                  defaultItemIndex: selectedRoom,
                                  itemBuilder: (String value) =>
                                      getDropDownMenuItem(value),
                                  focusedItemDecoration: _getDslDecoration(),
                                  onItemSelectedListener: (item, index, context) {
                                    selectedRoom = index;
                                    room(selectedRoom);
                                  }),
                            ]),
                            padding: EdgeInsets.only(left: 22)),
                        Padding(
                            padding:
                            EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
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
                            )),
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
                        SizedBox(
                          height: 20.0,
                        ),
                        Wrap(
                            children: <Widget>[
                          RaisedButton(
                            child: Text("Update Plant",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                            onPressed: () {
                              submitInfo();
                              Navigator.pop(context);
                            },

                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.blue)),
                            elevation: 5.0,
                            color: Colors.blue,
                            textColor: Colors.white,
                            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                            splashColor: Colors.grey,
                          ),
                          RaisedButton(
                            child: Text("Cancel",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.blue)),
                            elevation: 5.0,
                            color: Colors.blue,
                            textColor: Colors.white,
                            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                            splashColor: Colors.grey,
                          ),
                          RaisedButton(
                            child: Text("Delete",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                            onPressed: () {
                              DatabaseService(uid: user.uid)
                                  .deletePlant(_species,_room,_days,_notes,widget.reqid);
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.blue)),
                            elevation: 5.0,
                            color: Colors.blue,
                            textColor: Colors.white,
                            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                            splashColor: Colors.grey,
                          ),
      ]
                        )

                      ],
                    )
                  ],
                ),
              ),
            )
        )
        );
  }
}
