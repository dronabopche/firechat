import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  final String currentUserId;
  const HomePage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FireChat')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data!.docs.where(
            (doc) => doc.id != currentUserId,
          );

          return ListView(
            children: users.map((user) {
              final userData = user.data() as Map<String, dynamic>;
              final isOnline = userData['isOnline'] ?? false;
              final lastSeen = userData['lastSeen'] != null
                  ? (userData['lastSeen'] as Timestamp).toDate()
                  : DateTime.now();

              return ListTile(
                tileColor: Colors.white12, // Added background color
                leading: CircleAvatar(
                  backgroundColor: isOnline ? Colors.blue[200] : Colors.grey,
                  child: Text(
                    userData['name'] != null
                        ? userData['name'][0].toUpperCase()
                        : '?',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
                title: Text(
                  userData['name'] ?? 'Unknown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                subtitle: isOnline
                    ? Text('Online', style: TextStyle(color: Colors.green))
                    : Text('Last seen ${formatLastSeen(lastSeen)}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        currentUserId: currentUserId,
                        peerId: user.id,
                        peerName: userData['name'] ?? 'Unknown',
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  //to format last seen time on home page
  String formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
  }
}
