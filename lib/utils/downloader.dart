import 'package:http/http.dart' as http;
import 'package:insta_downloader/models/fileInfoModel.dart';
import 'package:insta_downloader/utils/Extractor.dart';
import 'package:url_launcher/url_launcher.dart';

class Downloader {
  static downloadFile(var values, String postUrl) async {
    //post download
    var urls = values["links"];
    for (FileInfo url in urls) {
      await canLaunch(url.url)
          ? await launch(url.url)
          : throw 'Could not launch ${url.url}';
    }
  }

  static getDetails(String url) async {
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await downloadFile(Extractor.extract(response.body), url);
        return;
      } else {
        return null;
      }
    } catch (ex) {
      return null;
    }
  }
}
