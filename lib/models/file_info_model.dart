import 'dart:convert';
import 'dart:typed_data';

class FileInfo {
  final int type;
  final Uint8List file;

  static const Base64Codec base64 = Base64Codec();

  FileInfo(this.type, this.file);

  Map toJson() =>
      {'type': type, 'file': base64.encode(file)};

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(json['type'] as int,
        base64.decode(json['file']));
  }
}
