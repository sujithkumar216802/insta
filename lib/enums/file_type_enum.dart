class FileType {
  final int _value;

  const FileType._privateConstructor(this._value);

  toInt() => _value;

  static const IMAGE = const FileType._privateConstructor(1);
  static const VIDEO = const FileType._privateConstructor(2);

  static const toFileType = {1: IMAGE, 2: VIDEO};
}
