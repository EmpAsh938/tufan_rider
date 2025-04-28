import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:tufan_rider/app/app.dart';
import 'package:tufan_rider/core/di/locator.dart';

void main() {
  setupLocator();
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const MyApp(),
    ),
  );
}
