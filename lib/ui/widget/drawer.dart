import 'package:flutter/material.dart';
import 'package:insta_downloader/enums/page_routes.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key key}) : super(key: key);

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
              Navigator.pushReplacementNamed(context, PageRoutes.input);
            },
          ),
          ListTile(
              title: Text('History'),
              onTap: () {
                Navigator.pushReplacementNamed(context, PageRoutes.history);
              }),
          // ListTile(
          //     title: Text('Settings'),
          //     onTap: () {
          //     }),
        ],
      ),
    );
  }
}
