import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pic_to_text/AuthService.dart';
import 'package:pic_to_text/LoadingState.dart';
import 'package:provider/provider.dart';

import 'package:pic_to_text/HomePage.dart';
import 'package:pic_to_text/LoginPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
              create: (context) => AuthService(),
              child: Consumer<AuthService>(
                builder: (context, provider, child) => MaterialApp(
                  title: 'Pic to Text',
                  debugShowCheckedModeBanner: false,
                  home: FutureBuilder(
                    // future: AuthService.getUser(),
                    future: Provider.of<AuthService>(context).getUser(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.hasData
                            ? HomePage(snapshot.data)
                            : LoginPage();
                      } else {
                        return Container(color: Colors.white);
                      }
                    },
                  ),
                ),
              ));
        }

        return LoadingCircle();
      },
    );
  }
}
