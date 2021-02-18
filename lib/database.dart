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

    return Padding(


        padding: EdgeInsets.only(bottom: 4, top: 4),
        child: Container(

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

  Future<void> getuserData(String name, String notes, int frequency, String img) async {
    DocumentReference docPlants = plantCollection.doc(uid);
    CollectionReference numerAtion = docPlants.collection('plants');
    //get the number of plants in the snapshot
    numerAtion.snapshots().length.toString();

  }

}