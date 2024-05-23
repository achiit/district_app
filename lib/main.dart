import 'package:district_app/auth_view.dart';
import 'package:district_app/user_listpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyBr7o7GIcECLTOnlDZaWNwZYJIwjV-6o10",

    databaseURL: "https://admk-bf35c-default-rtdb.firebaseio.com",
    projectId: "admk-bf35c",
    storageBucket: "admk-bf35c.appspot.com",
    messagingSenderId: "252494194514",
    appId: "1:252494194514:web:016555fb8ef2d892147c8b",
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String districtName = prefs.getString('districtName') ?? '';
  runApp(MyApp(isLoggedIn: isLoggedIn, districtName: districtName));
}

class MyApp extends StatelessWidget {
  final bool? isLoggedIn;
  final String? districtName;

  MyApp({this.isLoggedIn, this.districtName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'District App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          isLoggedIn! ? UserListPage(districtName: districtName!) : AuthPage(),
    );
  }
}
