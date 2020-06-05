import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/room_create_screen.dart';
import 'package:flutter/material.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class RoomsScreen extends StatefulWidget {
  static String id = 'room_screen';
  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _auth.signOut();
                  Navigator.pop(context);
                }),
          ],
          title: Text('⚡️Rooms'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, RoomCreateScreen.id);
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: RoomsStream(),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomsStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('rooms').snapshots(),
      builder: (context, snapshot) {
        List<Widget> roomList = [];
        bool userIdInList = false;
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
          final rooms = snapshot.data.documents;
          for (var room in rooms) {
            userIdInList = false;
            var users = room.data['users'];
            print(users);
            for (var user in users) {
              print(user);
              if (user == loggedInUser.email) {
                userIdInList = true;
              }
              print(userIdInList);
            }
            if (userIdInList) {
              final roomTitle = room.data['title'];
              roomList.add(
                RoomButton(
                  title: roomTitle,
                  roomId: room.documentID,
                ),
              );
            }
          }
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: roomList);
      },
    );
  }
}

void getMessages(room) async {
  var stuff = await _firestore
      .collection('rooms')
      .document(room.documentID.toString())
      .collection('messages')
      .getDocuments();
  var blob = stuff.documents;
  for (var document in blob) {
    print(document.data);
  }
}

class RoomButton extends StatelessWidget {
  RoomButton({@required this.title, @required this.roomId});

  final String title;
  final String roomId;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: FlatButton(
        color: Colors.lightBlueAccent,
        child: Text(title),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                roomId: roomId,
              ),
            ),
          );
        },
      ),
    );
  }
}
