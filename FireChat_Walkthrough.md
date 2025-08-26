# FireChat Project Walkthrough

## Step 1: Project Setup
1. Create a new Flutter project: `flutter create firechat`
2. Open the project in your IDE
3. Add Firebase dependencies to `pubspec.yaml`:
   - `firebase_core: ^2.15.1`
   - `cloud_firestore: ^4.9.1`
   - `firebase_database: ^10.2.1`

## Step 2: Firebase Setup
1. Go to Firebase Console (console.firebase.google.com)
2. Create a new project called "FireChat"
3. Enable Firestore Database
4. Set up authentication (optional for future)
5. Download the configuration files
6. Place `google-services.json` in `android/app/` directory

## Step 3: Project Structure
Create these files in your `lib/` folder:
- `main.dart` - App entry point
- `pages/home_page.dart` - User list screen
- `pages/chat_page.dart` - Chat interface
- `services/presence_service.dart` - Online status handler
- `models/user_model.dart` - User data structure

## Step 4: Implementing Main App (main.dart)
```dart
// Initialize Firebase and set up basic app structure
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
```

## Step 5: Presence Service (presence_service.dart)
```dart
// Handles user online/offline status
class PresenceService {
  final String userId;
  final DatabaseReference userStatusRef;

  PresenceService(this.userId) : 
    userStatusRef = FirebaseDatabase.instance.ref('status/$userId');

  void setOnline() {
    userStatusRef.set({
      'isOnline': true, 
      'lastSeen': ServerValue.timestamp
    });
  }

  void setOffline() {
    userStatusRef.set({
      'isOnline': false, 
      'lastSeen': ServerValue.timestamp
    });
  }
}
```

## Step 6: Home Page (home_page.dart)
```dart
// Shows list of users to chat with
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          // Display users list with online status
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              final user = snapshot.data!.docs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: user['isOnline'] ? Colors.green : Colors.grey,
                ),
                title: Text(user['name']),
                subtitle: Text(user['isOnline'] ? 'Online' : 'Offline'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatPage(peerId: user.id, peerName: user['name'])
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

## Step 7: Chat Page (chat_page.dart)
```dart
// Main chat interface
class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerName;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  
  void sendMessage(String text) {
    FirebaseFirestore.instance.collection('messages').add({
      'senderId': currentUserId,
      'receiverId': widget.peerId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'delivered': false,
      'seen': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.peerName)),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                // Build chat messages
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data!.docs[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          
          // Message input
          MessageInput(controller: _controller, onSend: sendMessage),
        ],
      ),
    );
  }
}
```

## Step 8: Database Setup in Firebase
1. Go to Firestore Database in Firebase Console
2. Create two collections:
   - `users` - for storing user information
   - `messages` - for storing chat messages

3. Add sample users to the `users` collection:
```javascript
{
  uid: "user1"
  name: "cherry",
  isOnline: true,
  lastSeen: [timestamp]
}
```

## Step 9: Testing the App
1. Run the app: `flutter run`
2. Test sending messages between users
3. Verify online/offline status works
4. Check message delivery status (single/double ticks)

## Step 10: Adding Enhancements
1. Add authentication
2. Implement push notifications
3. Add image sharing capability
4. Include voice messages
5. Add group chat functionality

## Common Issues & Solutions:
1. **Firebase not initializing**: Check your configuration files
2. **Permission errors**: Update Firestore security rules
3. **Messages not updating**: Check your StreamBuilder implementation
4. **Status not updating**: Verify presence service is called correctly



