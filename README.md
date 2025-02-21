<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Invisible Watermark

A Flutter package for adding and extracting invisible watermarks in images. This package allows you to embed hidden text watermarks into images that can later be revealed through special processing.

## Features

- Add invisible text watermarks to images
- Extract and visualize hidden watermarks
- Maximum image size protection (4096x4096)
- [x]Todo: add app UI InvisibleWatermarkWidget

## Getting started

Add this package to your Flutter project by adding the following to your `pubspec.yaml`:

```yaml
dependencies:
  invisible_watermark: ^0.0.1
```

Then run:
```bash
flutter pub get
```

## Usage

Basic example of how to use the package:

```dart
import 'package:invisible_watermark/invisible_watermark.dart';

// Create an instance
final watermark = InvisibleWatermark();

// Add watermark
final watermarkedBytes = await watermark.addWatermark(
  imageBytes,
  'Your Watermark Text'
);

// Extract watermark
final extractedBytes = await watermark.extractVisibleWatermark(watermarkedBytes);
```

For a complete example, check out the `/example` folder in the repository.

## Additional information

### Requirements
- Dart SDK: ^3.5.4
- Flutter: >=1.17.0

### Dependencies
- image: ^4.5.2

### Limitations
- Maximum supported image size: 4096x4096 pixels
- Performance depends on image size and device capabilities
- Watermark extraction quality may vary based on image modifications

### Contributing
Contributions are welcome! Please feel free to submit issues and pull requests.

### License
This project is licensed under the MIT License - see the LICENSE file for details.
