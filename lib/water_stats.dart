
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_login.dart';
import 'dart:developer';
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
    String fileName = _image.path;
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
    );
  }
  void open_gallery()
  async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;

    });
    String fileName = _image.path;
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
    );
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

                Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Plant species'
                      ),
                      onChanged: (text) {
                        print("First text field: $text");
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'plant notes'
                      ),
                      onChanged: (text) {
                        print("First text field: $text");
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'How often plant needs to be watered'
                      ),
                      onChanged: (text) {
                        print("Number of : $text");
                      },
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
