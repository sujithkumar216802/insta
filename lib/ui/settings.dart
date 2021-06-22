import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:insta_downloader/utils/permission.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String dirPath;

  @override
  void initState() {
    super.initState();
    getPathFromSharedPref();
    PermissionManager.getDownloadPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('LOCO : '),
            if(dirPath!=null)
              Text(dirPath),
            ElevatedButton(onPressed: folderPicker, child: Text('TOUCH ME!'))
          ],
        )
      ],
    );
  }

  folderPicker() async {
    if (dirPath == null)
      dirPath = (await DownloadsPathProvider.downloadsDirectory).path;

    String path = await FilesystemPicker.open(
        title: 'Save to folder',
        context: context,
        rootDirectory: Directory(dirPath),
        fsType: FilesystemType.folder,
        pickText: 'Save file to this folder');

    if(path!=null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('download_location', path);
      setState(() {
        dirPath = path;
      });
    }
  }

  getPathFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dir = prefs.getString('download_location');
    if (dir != null) {
      setState(() {
        dirPath = dir;
      });
    }
  }
}
