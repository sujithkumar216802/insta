import 'dart:typed_data';

import 'package:flutter/services.dart';

const MethodChannel _channel =
    MethodChannel('com.example.insta_downloader/folder');

saveFile(Uint8List byteArray, String name, int fileType) async {
  return await _channel
      .invokeMethod('save', {'byte_array': byteArray, 'name': name, 'file_type': fileType});
}

getFile(String uri) async {
  return await _channel.invokeMethod<Uint8List>('get', {'uri': uri});
}

Future<bool> checkIfFileExists(String uri) async {
  return await _channel.invokeMethod<bool>('check', {'uri': uri});
}

shareFiles(List<String> uris) {
  _channel.invokeMethod('share', {'uris': uris});
}

deleteFiles(List<String> uris) {
  _channel.invokeMethod('delete', {'uris': uris});
}

deleteFile(String uri) async {
  await _channel.invokeMethod('delete_single', {'uri': uri});
}
