class TextUtils {
  static String capitalizeEachWord(String? text) {
    if (text == null || text.trim().isEmpty) return '';
    return text.trim().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
