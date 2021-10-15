import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:insta_downloader/enums/file_type_enum.dart';
import 'package:insta_downloader/enums/path_enum.dart';

const MethodChannel _channel =
    MethodChannel('com.example.insta_downloader/folder');

saveFile(Uint8List byteArray, String name, FileType fileType) async {
  if (await getSdk() < 29) {
    String path = await getPath(PathType.toPathType[fileType.toInt()]);
    path += "/Insta Downloader/";
    if(!Directory(path).existsSync())
      Directory(path).createSync();
    path += name;
    switch (fileType) {
      case FileType.VIDEO:
        path += ".mp4";
        await File(path).writeAsBytes(byteArray);
        break;
      case FileType.IMAGE:
        path += ".jpg";
        await File(path).writeAsBytes(byteArray);
        break;
    }
    return path;
  } else
    return await _channel.invokeMethod('save',
        {'byte_array': byteArray, 'name': name, 'file_type': fileType.toInt()});
}

getFile(String uri) async {
  if (await getSdk() < 29)
    return File(uri);
  else
    return await _channel.invokeMethod<Uint8List>('get', {'uri': uri});
}

Future<bool> checkIfFileExists(String uri) async {
  if (await getSdk() < 29)
    return File(uri).existsSync();
  else
    return await _channel.invokeMethod<bool>('check', {'uri': uri});
}

shareFiles(List<String> uris) {
  _channel.invokeMethod('share', {'uris': uris});
}

//async can be removed
deleteFiles(List<String> uris) async {
  if (await getSdk() < 29) {
    for (String uri in uris) File(uri).delete();
  } else
    _channel.invokeMethod('delete', {'uris': uris});
}

deleteFile(String uri) async {
  if (await getSdk() < 29)
    File(uri).deleteSync();
  else
    await _channel.invokeMethod('delete_single', {'uri': uri});
}

getSdk() async {
  return await _channel.invokeMethod<int>('get_sdk');
}

getPath(PathType path) async {
  return await _channel.invokeMethod<String>('path', {'type': path.toInt()});
}
