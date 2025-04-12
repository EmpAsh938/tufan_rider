/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/alert.png
  AssetGenImage get alert => const AssetGenImage('assets/icons/alert.png');

  /// File path: assets/icons/bike.png
  AssetGenImage get bike => const AssetGenImage('assets/icons/bike.png');

  /// File path: assets/icons/car.png
  AssetGenImage get car => const AssetGenImage('assets/icons/car.png');

  /// File path: assets/icons/carbon_map.png
  AssetGenImage get carbonMap =>
      const AssetGenImage('assets/icons/carbon_map.png');

  /// File path: assets/icons/contact.png
  AssetGenImage get contact => const AssetGenImage('assets/icons/contact.png');

  /// File path: assets/icons/facebook.png
  AssetGenImage get facebook =>
      const AssetGenImage('assets/icons/facebook.png');

  /// File path: assets/icons/flag_nepal.png
  AssetGenImage get flagNepal =>
      const AssetGenImage('assets/icons/flag_nepal.png');

  /// File path: assets/icons/hide-eye-crossbar.png
  AssetGenImage get hideEyeCrossbar =>
      const AssetGenImage('assets/icons/hide-eye-crossbar.png');

  /// File path: assets/icons/instagram.png
  AssetGenImage get instagram =>
      const AssetGenImage('assets/icons/instagram.png');

  /// File path: assets/icons/linkedin.png
  AssetGenImage get linkedin =>
      const AssetGenImage('assets/icons/linkedin.png');

  /// File path: assets/icons/location_pin_destination.png
  AssetGenImage get locationPinDestination =>
      const AssetGenImage('assets/icons/location_pin_destination.png');

  /// File path: assets/icons/location_pin_source.png
  AssetGenImage get locationPinSource =>
      const AssetGenImage('assets/icons/location_pin_source.png');

  /// File path: assets/icons/material-symbols_search.png
  AssetGenImage get materialSymbolsSearch =>
      const AssetGenImage('assets/icons/material-symbols_search.png');

  /// File path: assets/icons/prime_asteriks.png
  AssetGenImage get primeAsteriks =>
      const AssetGenImage('assets/icons/prime_asteriks.png');

  /// File path: assets/icons/rivet-icons_question-mark.png
  AssetGenImage get rivetIconsQuestionMark =>
      const AssetGenImage('assets/icons/rivet-icons_question-mark.png');

  /// File path: assets/icons/tiktok.png
  AssetGenImage get tiktok => const AssetGenImage('assets/icons/tiktok.png');

  /// File path: assets/icons/warning.png
  AssetGenImage get warning => const AssetGenImage('assets/icons/warning.png');

  /// File path: assets/icons/youtube.png
  AssetGenImage get youtube => const AssetGenImage('assets/icons/youtube.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    alert,
    bike,
    car,
    carbonMap,
    contact,
    facebook,
    flagNepal,
    hideEyeCrossbar,
    instagram,
    linkedin,
    locationPinDestination,
    locationPinSource,
    materialSymbolsSearch,
    primeAsteriks,
    rivetIconsQuestionMark,
    tiktok,
    warning,
    youtube,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/map_placeholder.png
  AssetGenImage get mapPlaceholder =>
      const AssetGenImage('assets/images/map_placeholder.png');

  /// File path: assets/images/tufan.png
  AssetGenImage get tufan => const AssetGenImage('assets/images/tufan.png');

  /// List of all assets
  List<AssetGenImage> get values => [mapPlaceholder, tufan];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const AssetGenImage logo = AssetGenImage('assets/logo.png');
  static const String mapStyles = 'assets/map_styles.json';

  /// List of all assets
  static List<dynamic> get values => [logo, mapStyles];
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
