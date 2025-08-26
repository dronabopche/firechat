import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'services/presence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const currentUserId =
      'user1'; //change this 'user2' or 'user3' for other emulators to login from another user
  final presence = PresenceService(currentUserId);
  presence.setOnline();

  runApp(MyApp(currentUserId: currentUserId));

  WidgetsBinding.instance.addObserver(
    LifecycleEventHandler(
      onPause: () => presence.setOffline(),
      onResume: () => presence.setOnline(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String currentUserId;
  const MyApp({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    //name and theme section
    return MaterialApp(
      title: 'FireChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.blue[50], // Light grey background
      ),
      home: Scaffold(
        body: Stack(
          children: [
            // Background with slight gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.lightBlue, Colors.grey.shade100],
                ),
              ),
            ),

            // Main content
            HomePage(currentUserId: currentUserId),

            // Profile icon in top right corner
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.person, color: Colors.lightBlue),
                  onPressed: () {
                    // Add your profile navigation logic here
                    print('Profile button pressed');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Function onPause;
  final Function onResume;

  LifecycleEventHandler({required this.onPause, required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) onPause();
    if (state == AppLifecycleState.resumed) onResume();
  }
}
