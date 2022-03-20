import 'package:flutter/material.dart';
import 'package:insta_downloader/enums/page_routes.dart';
import 'package:insta_downloader/ui/screen/history_view.dart';

import '../../utils/globals.dart';
import '../screen/browser.dart';
import '../screen/input.dart';

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
            title: Text('Input'),
            onTap: () {
              Navigator.pop(context);
              if (screens.contains(PageRoutes.input)) {
                Navigator.popUntil(
                    context, ModalRoute.withName(PageRoutes.input));
                while (screens.isNotEmpty && screens.top() != PageRoutes.input)
                  screens.pop();
              } else {
                screens.push(PageRoutes.input);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: PageRoutes.input),
                    builder: (context) => Input(),
                  ),
                );
              }
            },
          ),
          ListTile(
              title: Text('History'),
              onTap: () {
                Navigator.pop(context);
                if (screens.contains(PageRoutes.history)) {
                  Navigator.popUntil(
                      context, ModalRoute.withName(PageRoutes.history));
                  while (screens.isNotEmpty &&
                      screens.top() != PageRoutes.history) screens.pop();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: PageRoutes.history),
                      builder: (context) => HistoryView(),
                    ),
                  ); //to reload the data from db... TODO: find a better way
                } else {
                  screens.push(PageRoutes.history);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: PageRoutes.history),
                      builder: (context) => HistoryView(),
                    ),
                  );
                }
              }),
          ListTile(
              title: Text('Browser'),
              onTap: () {
                Navigator.pop(context);
                if (screens.contains(PageRoutes.browser)) {
                  Navigator.popUntil(
                      context, ModalRoute.withName(PageRoutes.browser));
                  while (screens.isNotEmpty &&
                      screens.top() != PageRoutes.browser) screens.pop();
                } else {
                  screens.push(PageRoutes.browser);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: PageRoutes.browser),
                      builder: (context) => Browser(),
                    ),
                  );
                }
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
