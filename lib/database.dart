import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
            notes,
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
        print(plant['days'][i]);
        if (plant['days'][i] == true) {
          s += d[i] + " ";
        }
      }
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: EdgeInsets.only(bottom: 4, top: 4),
        child: Container(
          padding: const EdgeInsets.only(left: 5),
          child: Row(
            children: [poster, Flexible(child: details)],
          ),
        ));
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

  Future<void> getuserData(String name, String notes, String img) async {
    DocumentReference docPlants = plantCollection.doc(uid);
    CollectionReference numerAtion = docPlants.collection('plants');
    //get the number of plants in the snapshot
    numerAtion.snapshots().length.toString();

  }

}