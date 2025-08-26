import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String peerId;
  final String peerName;

  ChatPage({
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool _isComposing = false;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    //firestore to store messagaes data
    firestore
        .collection('messages')
        .add({
          'senderId': widget.currentUserId,
          'receiverId': widget.peerId,
          'text': text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'delivered': false,
          'seen': false,
        })
        .then((value) {
          _messageController.clear();
          setState(() {
            _isComposing = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        });
  }

  void markDeliveredAndSeen() async {
    //mark as delivered (double tick )
    final undeliveredMessages = await firestore
        .collection('messages')
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('senderId', isEqualTo: widget.peerId)
        .where('delivered', isEqualTo: false)
        .get();

    final batch = firestore.batch();
    for (var doc in undeliveredMessages.docs) {
      batch.update(doc.reference, {'delivered': true});
    }

    //mark  as seen(blue and doubvle tick)
    final unseenMessages = await firestore
        .collection('messages')
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('senderId', isEqualTo: widget.peerId)
        .where('seen', isEqualTo: false)
        .get();

    for (var doc in unseenMessages.docs) {
      batch.update(doc.reference, {'seen': true});
    }
    //mark as single tick
    if (undeliveredMessages.docs.isNotEmpty || unseenMessages.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  @override
  void initState() {
    super.initState();
    markDeliveredAndSeen();

    //scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Widget _buildMessageInput() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[100], // input box color
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          //emoji button to add emojis
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: Colors.blueGrey),
            onPressed: () {
              //press for emoji picking
            },
          ),
          SizedBox(width: 4),

          //text field to type message
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                hintStyle: TextStyle(color: Colors.black),
              ),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.trim().isNotEmpty;
                });
              },
              onSubmitted: (text) {
                if (_isComposing) {
                  sendMessage(text);
                }
              },
            ),
          ),
          SizedBox(width: 4),

          //to attach image
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.black),
            onPressed: () {
              //image uplaod
            },
          ),
          SizedBox(width: 4),

          //carmera button
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.black),
            onPressed: () {
              //turn on camera
            },
          ),
          SizedBox(width: 4),

          //to send message sending button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isComposing
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.lightBlueAccent,
            ),
            child: IconButton(
              icon: Icon(
                _isComposing ? Icons.send : Icons.mic,
                color: Colors.black,
                size: 22,
              ),
              onPressed: () {
                if (_isComposing) {
                  sendMessage(_messageController.text);
                } else {
                  //for voice message
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    DocumentSnapshot message,
    bool isMe,
    bool delivered,
    bool seen,
  ) {
    final messageData = message.data() as Map<String, dynamic>;
    final timestamp = messageData['timestamp'] != null
        ? (messageData['timestamp'] as Timestamp).toDate()
        : DateTime.now();

    //to set time of deleveriy
    final timeText =
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    //a status icon
    Icon statusIcon;
    if (seen) {
      statusIcon = Icon(Icons.done_all, size: 18, color: Colors.lightBlue);
    } else if (delivered) {
      statusIcon = Icon(Icons.done_all, size: 18, color: Colors.grey);
    } else {
      statusIcon = Icon(Icons.done, size: 18, color: Colors.grey);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundColor: Colors.blue[200], //peer profile color ke liye
              child: Text(widget.peerName[0]),
            ),
          SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.blueGrey[400]
                    : Colors.blue[100], //message color box  ke liye
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageData['text'] ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ), //text color forom sender if not reciver
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 14,
                          color: isMe
                              ? Colors.white70
                              : Colors.grey[700], //timing ke liye hai
                        ),
                      ),
                      if (isMe) SizedBox(width: 4),
                      if (isMe) statusIcon,
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              backgroundColor: Colors.blueGrey[400],
              child: Text('Me', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[200], //peer profile color ke liye
              child: Text(widget.peerName[0]),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peerName, style: TextStyle(fontSize: 16)),
                StreamBuilder<DocumentSnapshot>(
                  stream: firestore
                      .collection('users')
                      .doc(widget.peerId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final isOnline = userData?['isOnline'] ?? false;
                      final lastSeen = userData?['lastSeen'] != null
                          ? (userData?['lastSeen'] as Timestamp).toDate()
                          : DateTime.now();

                      return Text(
                        isOnline
                            ? 'online'
                            : 'last seen at ${formatLastSeen(lastSeen)}',
                        style: TextStyle(fontSize: 12),
                      );
                    }
                    return Text('', style: TextStyle(fontSize: 12));
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('View contact')),
              PopupMenuItem(child: Text('Media, links, and docs')),
              PopupMenuItem(child: Text('Search')),
              PopupMenuItem(child: Text('Mute notifications')),
              PopupMenuItem(child: Text('Wallpaper')),
              PopupMenuItem(child: Text('More')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Date divider
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'TODAY',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          //message list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // whereIn clauses used flutter documnenation for it
              stream: firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet\nSend a message to start the conversation',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                //filter messages client-side makes websited refresh
                final messages = snapshot.data!.docs.where((doc) {
                  final msgData = doc.data() as Map<String, dynamic>;
                  final sender = msgData['senderId'];
                  final receiver = msgData['receiverId'];
                  return (sender == widget.currentUserId &&
                          receiver == widget.peerId) ||
                      (sender == widget.peerId &&
                          receiver == widget.currentUserId);
                }).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final msgData = msg.data() as Map<String, dynamic>;
                    final isMe = msgData['senderId'] == widget.currentUserId;
                    final delivered = msgData['delivered'] ?? false;
                    final seen = msgData['seen'] ?? false;

                    return _buildMessageBubble(msg, isMe, delivered, seen);
                  },
                );
              },
            ),
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }

  // to set last seen time of user on chat page
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
