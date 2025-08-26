import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  //in fire base i have created 3 user with diffrent name and uid
  final String uid;
  final String name;
  final bool isOnline;
  final DateTime lastSeen;

  UserModel({
    required this.uid,
    required this.name,
    required this.isOnline,
    required this.lastSeen,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      isOnline:
          data['isOnline'] ??
          false, //if not online than flase that emans it will show offline
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp)
                .toDate() //for last seen
          : DateTime.now(),
    );
  }
}
