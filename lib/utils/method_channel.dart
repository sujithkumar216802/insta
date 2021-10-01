import 'dart:typed_data';
import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel(
    'com.example.insta_downloader/folder');

saveFile(Uint8List file, String name, int type) async {
  return await _channel.invokeMethod('save', {'file': file, 'name': name, 'type': type});
}

getFile(String path) async {
  return await _channel.invokeMethod<Uint8List>('get', {'path': path});
}

Future<bool> checkIfFileExists(String path) async {
  return await _channel.invokeMethod<bool>('check', {'path': path});
}

shareFiles(List<String> paths) {
  _channel.invokeMethod<bool>('share', {'paths': paths});
}
