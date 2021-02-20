import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services.dart';
import 'package:image_picker/image_picker.dart';
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
      width: 100,
      child: Center(child: Image.network(plant['imgurl'])),
    );
  }

  /// Returns movie details.
  Widget get details {
    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            frequency,
            notes,
            name,
          ],
        ));
  }

  /// Return the movie title.
  Widget get frequency {
    return Text("Watering frequency: ${plant['frequency']}",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
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

  /// Returns a list of genre movie tags.


  /// Returns all genres.
  Widget get name {
    return Text("Species:  ${plant['name']}",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
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
          padding: new EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),

          child: Row(
            children: [poster, Flexible(child: details)],
          ),
        ));
  }
}

class EditPlant extends StatefulWidget {
  final String reqid;
  EditPlant({Key key, @required this.reqid}) : super(key: key);

  @override
  _EditPlant createState() => _EditPlant();
}

class _EditPlant extends State {

  String _frequency;
  int freq;
  List<String> _locations = ['1', '2', '3', '4', '5', '6','7']; // Option 1
  var currentSelectedValue;
  File _image;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth currUser = FirebaseAuth.instance;
  var user = FirebaseAuth.instance.currentUser;
  String _species;
  String _notes;

  @override
// TODO: implement widget
  EditPlant get widget => super.widget;
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
    String fileName = _image.path;
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
    );
    await DatabaseService(uid: user.uid).editUserData(_species, _notes, freq, downloadUrl, widget.reqid);


  }

  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Center(
          child: Container(
            child: Column(
              children: [

                Container(
                  color: Colors.lightGreen,
                  height: 150.0,
                  width: 150.0,
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
                        hint: Text("Watering Frequency"),
                        value: currentSelectedValue,
                        isDense: true,
                        onChanged: (newValue) {
                          frequency(newValue);
                        },
                        items: _locations.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    RaisedButton(
                      child: Text("Update Plant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
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
                    RaisedButton(
                      child: Text("Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)
                      ),
                      elevation: 5.0,
                      color: Colors.red,
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


class DatabaseService {
  final String uid;
  DatabaseService({ this.uid });
  final CollectionReference plantCollection = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData(String name, String notes, int frequency, String img) async {
    DocumentReference docPlants = plantCollection.doc(uid);
    CollectionReference numerAtion = docPlants.collection('plants');
    String randomID = UniqueKey().toString();
    return await numerAtion.doc(randomID).set({
      'frequency': frequency,
      'notes': notes,
      'name': name,
      'imgurl' : img,
    });



  }

  Future<void> editUserData(String name, String notes, int frequency, String img, String ID) async {
    DocumentReference docPlants = plantCollection.doc(uid);
    CollectionReference numerAtion = docPlants.collection('plants');
    return await numerAtion.doc(ID).set({
      'frequency': frequency,
      'notes': notes,
      'name': name,
      'imgurl' : img,
    });



  }

  Future<void> getuserData(String name, String notes, int frequency, String img) async {
    DocumentReference docPlants = plantCollection.doc(uid);
    CollectionReference numerAtion = docPlants.collection('plants');
    //get the number of plants in the snapshot
    numerAtion.snapshots().length.toString();

  }

}