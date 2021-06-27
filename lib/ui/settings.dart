import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_downloader/utils/path_provider_util.dart';
import 'package:insta_downloader/utils/permission.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String dirPath;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    PermissionManager.getDownloadPermission();
    getPathFromSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('LOCO : '),
            if (dirPath != null) Text(dirPath),
          ],
        ),
        ElevatedButton(onPressed: folderPicker, child: Text('TOUCH ME!'))
      ],
    );
  }

  folderPicker() async {
    try {
      String path = await PathProviderUtil.folderPicker();

      print(path);

      if (path != null) {
        await prefs.setString('download_location', path);
        setState(() {
          dirPath = path;
        });
      }
    } on PlatformException catch (e) {
      print('cancelled');
    }
  }

  getPathFromSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    dirPath = prefs.getString('download_location') ??
        await PathProviderUtil.getDownloadPath();
    setState(() {});
  }
}
