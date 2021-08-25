import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final onChange;

  const MyDrawer({Key key, this.onChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text("instagram.com"),
            accountName: Text("Instagram Downloader"),
            currentAccountPicture: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                "assets/images/icon.png",
                fit: BoxFit.cover,
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              onChange(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
              title: Text('History'),
              onTap: () {
                onChange(2);
                Navigator.pop(context);
              }),
          // ListTile(
          //     title: Text('Settings'),
          //     onTap: () {
          //       onChange(3);
          //       Navigator.pop(context);
          //     }),
        ],
      ),
    );
  }
}
