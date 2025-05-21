import 'package:permission_handler/permission_handler.dart';

class PermissionChecker {
  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.request();
    final alwaysStatus = await Permission.locationAlways.request();
    final whenStatus = await Permission.locationWhenInUse.request();

    return status == PermissionStatus.granted ||
        alwaysStatus == PermissionStatus.granted ||
        whenStatus == PermissionStatus.granted;
  }

  static Future<bool> checkCallPermission() async {
    final status = await Permission.phone.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> checkGalleryPermission() async {
    // Use `photos` on iOS, `storage` on Android
    final isGranted = await Permission.photos.isGranted;
    final isDenied = await Permission.photos.isDenied;
    final permission =
        isGranted || isDenied ? Permission.photos : Permission.storage;

    final status = await permission.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> requestAllPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.phone,
      Permission.storage, // Covers gallery selection
    ].request();

    return statuses.values
        .every((status) => status == PermissionStatus.granted);
  }
}
