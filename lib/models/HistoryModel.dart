import 'dart:convert';
import 'dart:typed_data';

import 'package:insta_downloader/models/fileInfoModel.dart';

class History {
  final String url;
  final Uint8List thumbnail;
  final List<FileInfo> files;
  final bool isAvailableOnline;
  final String description;
  final String tag;

  static const Base64Codec base64 = Base64Codec();

  History(this.url, this.thumbnail, this.files, this.isAvailableOnline,
      this.description, this.tag);

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'thumbnail': base64.encode(thumbnail),
      'files': jsonEncode(files),
      'isAvailableOnline': isAvailableOnline ? 1 : 0,
      'description': description,
      'tag': tag
    };
  }

  static History fromMap(Map<String, dynamic> history) {
    List decodedFileInfoList = jsonDecode(history['files']);
    List<FileInfo> fileInfoList = List<FileInfo>.generate(
        decodedFileInfoList.length,
        (index) => FileInfo.fromJson(decodedFileInfoList[index]));
    return History(
        history['url'],
        base64.decode(history['thumbnail']),
        fileInfoList,
        history['isAvailableOnline']==1,
        history['description'],
        history['tag']);
  }
}
