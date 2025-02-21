import 'dart:math';
import 'package:image/image.dart' as img;

/// watermark processor
class WatermarkProcessor {
  // 缓存字体渲染结果
  // cache font rendering result
  static img.Image? _cachedTextImage;
  static String? _cachedText;
  final List<WatermarkBox> _watermarkBoxes = [];

  /// embed watermark
  img.Image embedWatermark(img.Image image, String watermarkText) {
    final result = img.Image.from(image);
    _watermarkBoxes.clear();
    
    // String watermarkText = _binaryToText(watermarkBits);
    
    // 调整水印文字大小和间距
    // adjust watermark text size and spacing
    const fontSize = 48;
    const horizontalStep = fontSize * 15;
    const verticalStep = fontSize * 4;
    const boxWidth = fontSize * 12;
    const boxHeight = fontSize + 10;
    
    // 预渲染水印文字图像
    // pre-render watermark text image
    if (_cachedText != watermarkText) {
      _cachedText = watermarkText;
      _cachedTextImage = img.Image(
        width: boxWidth,
        height: boxHeight,
        format: img.Format.uint32,  // 使用 uint32 格式支持透明通道 // use uint32 format to support transparent channel
      );
      
      // 在缓存图像上绘制文字
      // draw text on cached image
      img.drawString(
        _cachedTextImage!,
        watermarkText,
        font: img.arial48,
        x: 5,
        y: 5,
        color: img.ColorRgba8(200, 200, 200, 1),
      );
    }
    
    // 计算网格布局
    final columns = (image.width - fontSize) ~/ horizontalStep + 1;
    final rows = (image.height - fontSize) ~/ verticalStep + 1;
    
    // 批量添加水印
    for (int row = 0; row < rows; row++) {
      final y = fontSize + row * verticalStep;
      if (y >= image.height - fontSize) break;
      
      for (int col = 0; col < columns; col++) {
        final x = fontSize + col * horizontalStep;
        if (x >= image.width - fontSize) break;
        
        // 记录水印框位置
        // record watermark box position
        _watermarkBoxes.add(WatermarkBox(
          x: x,
          y: y,
          width: boxWidth,
          height: boxHeight,
        ));
        
        // 快速填充背景色（使用半透明）
        // fill background color(semi-transparent)
        _fillRectWithAlpha(
          result,
          x,
          y,
          boxWidth,
          boxHeight,
          img.ColorRgba8(100, 100, 100, 1),
        );
        
        // 复制预渲染的文字图像
        // copy text image
        _blendImage(result, _cachedTextImage!, x, y);
      }
    }
    
    return result;
  }

  // 优化的半透明矩形填充
  // optimized semi-transparent rectangle filling
  void _fillRectWithAlpha(img.Image image, int x, int y, int width, int height, img.Color color) {
    final endX = min(x + width, image.width);
    final endY = min(y + height, image.height);
    
    final alpha = color.a / 255.0;
    
    for (int py = y; py < endY; py++) {
      for (int px = x; px < endX; px++) {
        final dst = image.getPixel(px, py);
        final r = ((1 - alpha) * dst.r + alpha * color.r).toInt();
        final g = ((1 - alpha) * dst.g + alpha * color.g).toInt();
        final b = ((1 - alpha) * dst.b + alpha * color.b).toInt();
        image.setPixelRgba(px, py, r, g, b, 255);
      }
    }
  }

  // optimized image blending
  void _blendImage(img.Image dst, img.Image src, int offsetX, int offsetY) {
    final width = min(src.width, dst.width - offsetX);
    final height = min(src.height, dst.height - offsetY);
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final srcPixel = src.getPixel(x, y);
        if (srcPixel.a > 0) {
          final dstPixel = dst.getPixel(x + offsetX, y + offsetY);
          final alpha = srcPixel.a / 255.0;
          
          final r = ((1 - alpha) * dstPixel.r + alpha * srcPixel.r).toInt();
          final g = ((1 - alpha) * dstPixel.g + alpha * srcPixel.g).toInt();
          final b = ((1 - alpha) * dstPixel.b + alpha * srcPixel.b).toInt();
          
          dst.setPixelRgba(x + offsetX, y + offsetY, r, g, b, 255);
        }
      }
    }
  }

  /// make watermark visible
  img.Image makeWatermarkVisible(img.Image image) {
    final visibleImage = img.Image.from(image);
    
    // 根据记录的水印框位置绘制黑色背景和白色文字
    // draw black background and white text based on the watermark box position
    for (final box in _watermarkBoxes) {
      // 绘制黑色背景框
      // draw black background box
      for (int y = box.y; y < box.y + box.height; y++) {
        for (int x = box.x; x < box.x + box.width; x++) {
          if (x < image.width && y < image.height) {
            visibleImage.setPixelRgba(x, y, 0, 0, 0, 255);
          }
        }
      }
      
      // 在黑色背景上绘制白色文字
      // draw white text on black background
      img.drawString(
        visibleImage,
        'Flutter Watermark Demo',
        font: img.arial48,
        x: box.x + 5,
        y: box.y + 5,
        color: img.ColorRgba8(255, 255, 255, 255),
      );
    }
    
    return visibleImage;
  }

  /// convert binary data to text
  String _binaryToText(List<int> bits) {
    final bytes = <int>[];
    for (int i = 0; i < bits.length - 8; i += 8) {
      int byte = 0;
      for (int j = 0; j < 8; j++) {
        byte = (byte << 1) | bits[i + j];
      }
      bytes.add(byte);
    }
    return String.fromCharCodes(bytes);
  }
}

/// watermark box position information
class WatermarkBox {
  final int x;
  final int y;
  final int width;
  final int height;

  WatermarkBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
} 