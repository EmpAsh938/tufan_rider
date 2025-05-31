import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
        await getBitmapDescriptorFromAsset(assetPath, size);

    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: icon,
      infoWindow: title != null ? InfoWindow(title: title) : InfoWindow.noText,
      anchor: const Offset(0.5, 1.0),
    );
  }

  static Future<BitmapDescriptor> getBitmapDescriptorFromAsset(
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

  static Future<BitmapDescriptor> createSimpleMarker(String imagePath,
      {int targetWidth = 180}) async {
    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List imageBytes = data.buffer.asUint8List();

    final ui.Codec codec =
        await ui.instantiateImageCodec(imageBytes, targetWidth: targetWidth);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final Paint paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);

    final ui.Image finalImage =
        await recorder.endRecording().toImage(image.width, image.height);
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }

    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }
}
