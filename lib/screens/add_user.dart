import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/rounded_button.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class AddUserScreen extends StatefulWidget {
  AddUserScreen({this.roomId});
  static String id = 'add_user_screen';
  final roomId;
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String roomId;

  @override
  void initState() {
    roomId = widget.roomId;
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

  void addUserToRoom(email) async {
    var room = await _firestore.collection('rooms').document(roomId).get();
    Map roomData = room.data;
    List users = roomData['users'];
    users.add(email);
    roomData['users'] = users;
    _firestore.collection('rooms').document(roomId).updateData(roomData);
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
                  email = value;
                },
                decoration: kTextFieldDecorationLightBlueAccent.copyWith(
                    hintText: 'Enter your friends email'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Add user',
                color: Colors.lightBlueAccent,
                onPressed: () async {
                  //Implement login functionality.
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    if (email != null) {
                      addUserToRoom(email);
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
