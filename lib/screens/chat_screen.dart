import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  static String id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;

  void getUser() async {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void messageStream() async {
    await for (var snapshot in _firestore.collection("messages").snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              //Implement logout functionality
              messageStream();
            },
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: StreamBuilder(
                stream: _firestore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  return (!snapshot.hasData)
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Expanded(
                        child: ListView.builder(itemCount: snapshot.data.docs.length,itemBuilder: (context,index) {
                          var messages = snapshot.data.docs[index];
                          final messageText = messages['text'];
                          final messageSender = messages['sender'];
                          return Center(child: Container(child: Text('$messageText by $messageSender'),));
                  }),
                      );
                },
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firestore.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// builder: (context, snapshot) {
// if (!snapshot.hasData) {
// return Center(
// child: CircularProgressIndicator(),
// );
// } else {
// final messages = snapshot.data.docs;
// List<Text> messagesWidgets = [];
// for (var message in messages) {
// final messageText = message['text'];
// final messageSender = message['sender'];
//
// final messageWidget =
// Text('$messageText from $messageSender');
// messagesWidgets.add(messageWidget);
// }
// return Column(
// children: messagesWidgets,
// );
// }
// },
