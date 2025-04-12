import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerUtil {
  static Future<Marker> createMarker({
    required String markerId,
    required LatLng position,
    required String assetPath,
    String? title,
    double size = 100, // adjust this for desired marker size
  }) async {
    final BitmapDescriptor icon =
        await _getBitmapDescriptorFromAsset(assetPath, size);

    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: icon,
      infoWindow: title != null ? InfoWindow(title: title) : InfoWindow.noText,
    );
  }

  static Future<BitmapDescriptor> _getBitmapDescriptorFromAsset(
      String assetPath, double size) async {
    final ByteData data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: size.toInt(),
    );
    final frame = await codec.getNextFrame();
    final byteData =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedBytes = byteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(resizedBytes);
  }
}
