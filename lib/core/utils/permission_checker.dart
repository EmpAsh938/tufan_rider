import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionChecker {
  static Future<bool> checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status == PermissionStatus.granted;
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
    final List<Permission> permissions = [
      Permission.location,
      Permission.phone,
      if (Platform.isAndroid) Permission.storage,
      if (Platform.isIOS) Permission.photos,
    ];

    final statuses = await permissions.request();

    return statuses.values
        .every((status) => status == PermissionStatus.granted);
  }
}
