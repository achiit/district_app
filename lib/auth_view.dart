import 'dart:developer';

import 'package:district_app/colors.dart';
import 'package:district_app/user_listpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('districts');
  bool _isObscured = true; // To manage password visibility

  // Function to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  Future<void> _login() async {
    try {
      final snapshot = await _database.once();
      Map<dynamic, dynamic>? districts =
          snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (districts != null) {
        for (var entry in districts.entries) {
          Map<dynamic, dynamic> admin = entry.value['admin'];
          if (admin['email'] == _emailController.text.trim() &&
              admin['password'] == _passwordController.text.trim()) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('districtName', entry.key);
            bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
            String districtName = prefs.getString('districtName') ?? '';
            log("districtName: $districtName");
            log("isLoggedIn: $isLoggedIn");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => UserListPage(districtName: entry.key)),
            );
            return;
          }
        }
      }
      _showErrorDialog('Invalid email or password');
    } catch (e) {
      print(e);
      _showErrorDialog('Error logging in');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset("assets/background.png", fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('மாவட்ட நிர்வாக உள்நுழைவு'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "மாநில நிர்வாகி வழங்கிய அஞ்சல் ஐடி மற்றும் கடவுச்சொல்லை உள்ளிடவும்",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_isObscured
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  obscureText:
                      _isObscured, // Use the state to toggle password visibility
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: AppColors.buttonColor,
                    fixedSize: Size(400, 50),
                  ),
                  onPressed: _login,
                  child: Text('உள்நுழைய',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
