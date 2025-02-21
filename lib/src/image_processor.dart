import 'dart:math';
import 'package:image/image.dart' as img;

/// image processor
class ImageProcessor {
  final double maxImageSize;
  ImageProcessor({required this.maxImageSize});

  /// resize image if needed
  img.Image resizeIfNeeded(img.Image image) {
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    
    if (width > maxImageSize || height > maxImageSize) {
      final scale = min(maxImageSize / width, maxImageSize / height);
      final newWidth = (width * scale).round();
      final newHeight = (height * scale).round();
      
      return img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );
    }
    
    return image;
  }
  
} 