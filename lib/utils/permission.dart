import 'package:permission_handler/permission_handler.dart';

getDownloadPermission() async {
  var status = await Permission.storage.status;
  var ret = false;

  if (status.isDenied) {
    status = await Permission.storage.request();
  }

  if (status.isLimited) {
//IDKb
  }

  if (status.isPermanentlyDenied) {
    openAppSettings();
  }

  if (status.isRestricted) {
//IDK
  }

  if (status.isGranted) ret = true;

  return ret;
}
