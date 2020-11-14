import 'dart:io';
import 'dart:developer' as developer;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pic_to_text/userImagePicker.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ));

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String string = "TextRecognition";
  File _userImageFile;
  var result = "";

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  recogniseText() async {
    developer.log('recogniseText was called');

    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(_userImageFile);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(myImage);

    developer.log(readText.text);

    setState(() {
      result = readText.text;
    });
  }

  Widget drawerItem(String title, IconData iconData, String _string) {
    return InkWell(
      onTap: () {
        setState(() {
          string = _string;
        });
        Navigator.of(context).pop();
      },
      child: Column(
        children: [
          ListTile(
            leading: Icon(iconData),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Image.network(
                    "https://1.bp.blogspot.com/-B3K1G5D9sPQ/WvDZJGvkqVI/AAAAAAAAFSc/zx6VYIc0IXQmB8oR4c0i7SKjSNL-2xiTQCLcBGAs/s1600/ml-kit-logo.png"),
              ),
              Divider(),
              drawerItem("Text recognition", Icons.title, "TextRecognition"),
              drawerItem("Image labeling", Icons.terrain, "ImageLabeling"),
              drawerItem("Barcode scanning", Icons.workspaces_outline,
                  "BarcodeScanning"),
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          title: Text(string),
          backgroundColor: Colors.blue[300],
          actions: [
            IconButton(
              onPressed: () {
                if (string == "TextRecognition") recogniseText();
              },
              icon: Icon(Icons.check),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                UserImagePicker(_pickedImage),
                Padding(
                    padding: const EdgeInsets.all(16.0), child: Text(result)),
              ],
            ),
          ),
        ));
  }
}
