import 'package:insta_downloader/enums/file_type_enum.dart';

class FileInfo {
  FileType fileType;
  String url;
  String uri;
  String name;

  FileInfo(this.fileType, this.url);

  FileInfo.all(this.fileType, this.url, this.uri, this.name);

  Map toJson() =>
      {'type': fileType.toInt(), 'url': url, 'uri': uri, 'name': name};

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo.all(FileType.toFileType[json['type']],
        json['url'] as String, json['uri'] as String, json['name'] as String);
  }
}
