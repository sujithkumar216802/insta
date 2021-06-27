import 'package:flutter/services.dart';

class PathProviderUtil {
  static const MethodChannel _channel =
      const MethodChannel('com.example.insta_downloader/folder');

  static Future<String> getDownloadPath() async {
    return await _channel.invokeMethod('downloadPath');
  }

  static Future<String> folderPicker() async {
    return await _channel.invokeMethod('folderPicker');
  }
}
