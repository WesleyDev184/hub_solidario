class Formats {
  static String formatSerialCode(int itemId) {
    String idString = itemId.toString();
    if (idString.length >= 8) {
      return '${idString.substring(0, 4)}-${idString.substring(4, 8)}';
    } else {
      // Pad with zeros if needed
      idString = idString.padLeft(8, '0');
      return '${idString.substring(0, 4)}-${idString.substring(4, 8)}';
    }
  }
}
