import 'dart:convert';
import 'dart:typed_data';

import 'package:insta_downloader/models/file_info_model.dart';

class History {
  final String url;
  final Uint8List thumbnail;
  final Uint8List accountPhoto;
  final List<FileInfo> files;
  final String description;
  final String tag;

  static const Base64Codec base64 = Base64Codec();

  History(this.url, this.thumbnail, this.accountPhoto, this.files,
      this.description, this.tag);



  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'thumbnail': base64.encode(thumbnail),
      'account_photo': base64.encode(accountPhoto),
      'files': jsonEncode(files),
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
        base64.decode(history['account_photo']),
        fileInfoList,
        history['description'],
        history['tag']);
  }
}
