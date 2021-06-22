class FileInfo {

  int type;
  String url;
  String file;
  bool isAvailable;

  FileInfo(this.type, this.url);

  FileInfo.all(this.type, this.url, this.file, this.isAvailable);

  Map toJson() => {
    'type' : type,
    'url' : url,
    'file' : file,
    'available': isAvailable
  };

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo.all(
        json['type'] as int,
        json['url'] as String,
        json['file'] as String,
        json['available'] as bool
    );
  }

}