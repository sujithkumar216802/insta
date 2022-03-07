import '../enums/status_enum.dart';

urlChecker(Uri uri) {
  String url;
  if (uri.pathSegments.contains('stories') ||
      uri.pathSegments.contains('s') ||
      uri.pathSegments.contains('p') ||
      uri.pathSegments.contains('tv') ||
      uri.pathSegments.contains('reel')) {
    url = 'https://www.instagram.com' + uri.path;
    if (uri.queryParameters.containsKey('story_media_id') &&
        uri.pathSegments.contains('s'))
      url += '?story_media_id=' + uri.queryParameters['story_media_id'];
    return url;
  } else {
    return Status.INVALID_URL;
  }
}
