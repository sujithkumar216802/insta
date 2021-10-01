class FileInfo {
  int type;
  String url;
  String file;
  String name;
  //bool isAvailable;

  FileInfo(this.type, this.url);

  FileInfo.all(this.type, this.url, this.file, this.name);

  Map toJson() =>
      {'type': type, 'url': url, 'file': file, 'name':name};

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo.all(json['type'] as int, json['url'] as String,
        json['file'] as String, json['name'] as String);
  }
}
