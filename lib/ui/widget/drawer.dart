import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:insta_downloader/utils/page_routes.dart';
import 'package:insta_downloader/utils/permission.dart';
import 'package:insta_downloader/utils/reponse_helper.dart';

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
              // Navigator.pop(context);
            },
          ),
          ListTile(
              title: Text('History'),
              onTap: () /*async*/ {
                // if (await getSdk() < 29 && !(await getDownloadPermission()))
                //   responseHelper(context, Status.PERMISSION_NOT_GRANTED);
                Navigator.pushReplacementNamed(context, PageRoutes.history);
                //Navigator.pop(context);
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
