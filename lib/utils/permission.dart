import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static getDownloadPermission() async {
    var status = await Permission.storage.status;
    var status2 = await Permission.manageExternalStorage.status;
    var ret = false;

    //TODO
    if (status.isDenied){
      status = await Permission.storage.request();
    }

    if(status.isLimited) {
//IDKb
    }

    if(status.isPermanentlyDenied) {
      openAppSettings();
    }

    if(status.isRestricted) {
//IDK
    }

    if(status.isGranted)
      ret = true;

    return ret;
  }
}
