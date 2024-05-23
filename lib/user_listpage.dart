import 'dart:developer';

import 'package:district_app/auth_view.dart';
import 'package:district_app/user_detailpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserListPage extends StatefulWidget {
  final String districtName;

  UserListPage({required this.districtName});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('users');
  String phoneNumber = '';
  Future<void> _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('வெளியேறு'),
          content: Text('நீங்கள் நிச்சயமாக வெளியேற விரும்புகிறீர்களா?'),
          actions: [
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                await prefs.setString('districtName', '');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
              },
              child: Text('ஆம்'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('இல்லை'),
            ),
          ],
        );
      },
    );
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/background.png", fit: BoxFit.cover),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: () async {
                    await _logout();
                  },
                  icon: Icon(
                    Icons.logout,
                  ),
                )
              ],
              title: Text('${widget.districtName} பயனர்கள்'),
              bottom: TabBar(
                labelStyle: TextStyle(fontSize: 20),
                tabs: [
                  Tab(
                    text: 'ஏற்றுக்கொள்ளப்பட்டது',
                  ),
                  Tab(
                    text: 'ஏற்கப்படவில்லை',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildUserList(true),
                _buildUserList(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(bool accepted) {
    return FutureBuilder(
      future: _database.once(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic>? users =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
            if (users == null) {
              return Center(child: Text('தரவு எதுவும் கிடைக்கவில்லை'));
            }
            List<MapEntry<dynamic, dynamic>> filteredUsers = users.entries
                .where((entry) =>
                    entry.value['district'] == widget.districtName &&
                    entry.value['district_accepted'] == accepted)
                .toList();
            if (filteredUsers.isEmpty) {
              return Center(child: Text('பயனர்கள் யாரும் இல்லை'));
            }
            return ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                MapEntry<dynamic, dynamic> userEntry = filteredUsers[index];
                String phoneNumber =
                    userEntry.key.toString(); // Extract phone number from key
                phoneNumber = "+91$phoneNumber";
                Map<dynamic, dynamic> userData = userEntry.value;
                return ListTile(
                  title: Text(userData['name'], style: TextStyle(fontSize: 20)),
                  subtitle: Text('தொலைபேசி எண்: ${phoneNumber}',
                      style: TextStyle(fontSize: 17)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!accepted)
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () =>
                              _acceptUser(userEntry.key.toString()),
                        ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _deleteUser(userEntry.key.toString()),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserDetailPage(userKey: userEntry.key.toString()),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: Text('Error loading data'));
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _acceptUser(String userKey) {
    _database.child(userKey).update({'district_accepted': true});
    setState(() {});
  }

  void _deleteUser(String userKey) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('பயனரை நீக்கு'),
          content: Text('இந்தப் பயனரை நிச்சயமாக நீக்க விரும்புகிறீர்களா?'),
          actions: [
            TextButton(
              onPressed: () {
                _database.child(userKey).remove();
                Navigator.pop(context);
                setState(() {});
              },
              child: Text('ஆம்'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('இல்லை'),
            ),
          ],
        );
      },
    );
  }
}
