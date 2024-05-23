import 'dart:developer';

import 'package:district_app/userdetailsitem.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

class UserDetailPage extends StatelessWidget {
  final String userKey;

  UserDetailPage({required this.userKey});

  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('users');

  void _acceptUser(BuildContext context) {
    _database.child(userKey).update({'district_accepted': true});
    Navigator.pop(context);
  }

  void _deleteUser(BuildContext context) {
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
                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
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
            backgroundColor: Colors.transparent,
            title: Text(
              'பயனர் விவரங்கள்',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          body: FutureBuilder(
            future: _database
                .child(userKey)
                .once()
                .then((DatabaseEvent event) => event.snapshot),
            builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData &&
                    !snapshot.hasError &&
                    snapshot.data != null) {
                  Map<dynamic, dynamic>? user =
                      snapshot.data!.value as Map<dynamic, dynamic>?;
                  if (user == null) {
                    return Center(child: Text('No data available'));
                  }
                  return Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(
                                user['imageUrl'],
                              ),
                            ),
                            Row(
                              children: [
                                if (!user['district_accepted'])
                                  ElevatedButton(
                                    child:
                                        Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _acceptUser(context),
                                  ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  child: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _deleteUser(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        UserDetailsItem(
                          label: 'பெயர்:',
                          value: user['name'],
                        ),
                        UserDetailsItem(
                          label: 'ஆதார் அட்டை எண்:',
                          value: user['aadhar'],
                        ),
                        UserDetailsItem(
                          label: 'பிறந்த தேதி:',
                          value: user['dob'].toString().substring(0, 10),
                        ),
                        UserDetailsItem(
                          label: 'தந்தையின் பெயர்:',
                          value: user['fathername'],
                        ),
                        UserDetailsItem(
                          label: 'தாலுகா:',
                          value: user['taluk'],
                        ),
                        UserDetailsItem(
                          label: 'மாவட்டம்:',
                          value: user['district'],
                        ),
                        UserDetailsItem(
                          label: 'தொலைபேசி:',
                          value: "+91${userKey}",
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('தரவை ஏற்றுவதில் பிழை'));
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
}
