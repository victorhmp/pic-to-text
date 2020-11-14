import 'dart:io';
import 'dart:developer' as developer;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';

import 'package:image_picker/image_picker.dart';
import 'package:pic_to_text/mockData.dart';

void main() => runApp(MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    ));

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    } else {
      print('No image was selected');
    }
  }

  recogniseText() async {
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(_userImageFile);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(myImage);

    developer.log('This is the result: ${readText.text}');

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
        backgroundColor: Colors.amber[400],
        actions: [
          IconButton(
            onPressed: () {
              recogniseText();
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Container(
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: history.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                // trailing: Icon(Icons.delete_rounded),
                title: Text('${history[index]}'),
                onTap: () {
                  FlutterClipboard.copy(history[index]).then((value) {
                    Scaffold.of(context).showSnackBar(snackBar);
                  });
                },
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text(
                    "Complete your action using..",
                  ),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                      ),
                    ),
                  ],
                  content: Container(
                    height: 120,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.camera),
                          title: Text(
                            "Camera",
                          ),
                          onTap: () {
                            _pickImage(ImageSource.camera);
                            Navigator.of(context).pop();
                          },
                        ),
                        Divider(
                          height: 1,
                          color: Colors.black,
                        ),
                        ListTile(
                          leading: Icon(Icons.image),
                          title: Text(
                            "Gallery",
                          ),
                          onTap: () {
                            _pickImage(ImageSource.gallery);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Icon(Icons.add_a_photo_outlined),
        backgroundColor: Colors.amberAccent,
      ),
    );
  }
}
