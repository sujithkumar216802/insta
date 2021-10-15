class PathType {
  final int _value;

  const PathType._privateConstructor(this._value);

  toInt() => _value;

  static const PICTURE = const PathType._privateConstructor(1);
  static const MOVIE = const PathType._privateConstructor(2);
  static const APP = const PathType._privateConstructor(3);

  static const toPathType = {1: PICTURE, 2: MOVIE, 3: APP};
}
