import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:pic_to_text/AuthService.dart';
import 'package:pic_to_text/mockData.dart';

class HomePage extends StatefulWidget {
  final User currentUser;

  HomePage(this.currentUser);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker picker = ImagePicker();

  String string = "TextRecognition";
  File _userImageFile;

  List<String> history = mockHistory;

  final snackBar = SnackBar(content: Text('Copiado'));

  var result = "";

  void _pickImage(ImageSource imageSource) async {
    final pickedImageFile = await picker.getImage(
      source: imageSource,
    );

    if (pickedImageFile != null) {
      setState(() {
        _userImageFile = File(pickedImageFile.path);
      });

      recogniseText();
    } else {
      print('No image was selected');
    }
  }

  recogniseText() async {
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(_userImageFile);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(myImage);

    setState(() {
      result = readText.text;
      history = [result] + history;
      _userImageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Pic to Text'),
        backgroundColor: Color(0xFFf1c40f),
        actions: [
          IconButton(
            onPressed: () async {
              await Provider.of<AuthService>(context).logout();
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: history.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text('${history[index]}'),
                onTap: () {
                  FlutterClipboard.copy(history[index]).then((value) {
                    Scaffold.of(context).showSnackBar(snackBar);
                  });
                },
              );
            }),
      ),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add_a_photo_outlined),
        backgroundColor: Color(0xFFf1c40f),
        children: [
          SpeedDialChild(
            child: Icon(CupertinoIcons.camera),
            onTap: () {
              _pickImage(ImageSource.camera);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.image),
            onTap: () {
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
      drawer: HomeDrawer(widget.currentUser),
    );
  }
}

class HomeDrawer extends StatefulWidget {
  final User currentUser;

  HomeDrawer(this.currentUser);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
              widget.currentUser.photoURL,
            ),
            radius: 80,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 40),
          Text(
            'NAME',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            widget.currentUser.displayName,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF34495e),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'EMAIL',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          Text(
            widget.currentUser.email,
            style: TextStyle(
                fontSize: 16,
                color: Color(0xFF34495e),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40),
          RaisedButton(
            onPressed: () async {
              await Provider.of<AuthService>(context).logout();
            },
            color: Color(0xFFf1c40f),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          )
        ],
      ),
    );
  }
}
