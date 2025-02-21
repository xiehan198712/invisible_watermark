/// text processor
class TextProcessor {
  /// text to binary-list
  List<int> textToBinary(String text) {
    final bits = List<int>.filled(text.length * 8 + 8, 0);
    var index = 0;
    
    for (final byte in text.codeUnits) {
      for (int i = 7; i >= 0; i--) {
        bits[index++] = (byte >> i) & 0x01;
      }
    }
    
    // add end mark
    for (int i = 0; i < 8; i++) {
      bits[index++] = 1;
    }
    
    return bits;
  }

  /// binary-list to text string
  String binaryToText(List<int> bits) {
    final bytes = List<int>.filled(bits.length ~/ 8, 0);
    var byteIndex = 0;
    
    for (int i = 0; i < bits.length; i += 8) {
      if (i + 8 > bits.length) break;
      
      int byte = 0;
      for (int j = 0; j < 8; j++) {
        byte = (byte << 1) | bits[i + j];
      }
      bytes[byteIndex++] = byte;
    }
    
    return String.fromCharCodes(bytes.sublist(0, byteIndex));
  }
} 