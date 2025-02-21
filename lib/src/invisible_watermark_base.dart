import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'watermark_processor.dart';
import 'image_processor.dart';
// import 'text_processor.dart';

/// invisible watermark processor
class InvisibleWatermark {
  /// max image size limit
  static const double maxImageSize = 4096.0;
  
  final WatermarkProcessor _watermarkProcessor;
  final ImageProcessor _imageProcessor;
  // final TextProcessor _textProcessor;
  
  InvisibleWatermark()
      : _watermarkProcessor = WatermarkProcessor(),
        _imageProcessor = ImageProcessor(maxImageSize: maxImageSize);
        // _textProcessor = TextProcessor();

  /// add invisible watermark
  Future<Uint8List> addWatermark(Uint8List originalImage, String watermark) async {
    final image = img.decodeImage(originalImage);
    if (image == null) throw Exception('can\'t decode image');

    final resizedImage = _imageProcessor.resizeIfNeeded(image);
    
    final watermarkedImage = _watermarkProcessor.embedWatermark(
      resizedImage,
     watermark,
    );

    return Uint8List.fromList(img.encodePng(watermarkedImage));
  }

  /// extract and show watermark
  Future<Uint8List> extractVisibleWatermark(Uint8List watermarkedImage) async {
    final image = img.decodeImage(watermarkedImage);
    if (image == null) throw Exception('can\'t decode image');
    
    final visibleImage = _watermarkProcessor.makeWatermarkVisible(image);
    
    return Uint8List.fromList(img.encodePng(visibleImage));
  }
} 