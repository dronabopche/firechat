import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceService {
  final String userId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  PresenceService(this.userId);

  void setOnline() {
    //to set online
    firestore.collection('users').doc(userId).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  void setOffline() {
    //to set offline
    firestore.collection('users').doc(userId).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}
