import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/rounded_button.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class RoomCreateScreen extends StatefulWidget {
  static String id = 'room_create_screen';
  @override
  _RoomCreateScreenState createState() => _RoomCreateScreenState();
}

class _RoomCreateScreenState extends State<RoomCreateScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String roomName;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
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

  void createRoom(roomName) async {
    var docref = await _firestore.collection('rooms').add(
      {
        'title': roomName,
        'users': [loggedInUser.email],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  roomName = value;
                },
                decoration: kTextFieldDecorationLightBlueAccent.copyWith(
                    hintText: 'Enter room name'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Create room',
                color: Colors.lightBlueAccent,
                onPressed: () async {
                  //Implement login functionality.
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    if (roomName != null) {
                      createRoom(roomName);
                      Navigator.pop(context);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
