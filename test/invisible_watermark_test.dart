import 'package:flutter_test/flutter_test.dart';

import 'package:invisible_watermark/src/text_processor.dart';

void main() {
  test('test invisible watermark', () {
    final textProcessor = TextProcessor();
    const watermarkText = 'Hello, World!';
    textProcessor.textToBinary(watermarkText);
  });
}
