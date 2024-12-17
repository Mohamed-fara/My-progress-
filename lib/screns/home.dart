

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milieryforce/screns/entrydata.dart';
import 'package:milieryforce/screns/viewdata.dart';





class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('event app')),
      body: Center(child: Text('WELCOME EVENT APP')),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text('MENUE'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),

            ListTile(
              title: Text('Add Event'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EventEntry()),
                );
              },
            ),
            ListTile(
              title: Text('View event'),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EventDisplayScreen()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
    );
  }
}