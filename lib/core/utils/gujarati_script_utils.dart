import 'name_transliteration_utils.dart';

class GujaratiScriptUtils {
  /// Transliterates an English name into active language script (Gujarati, Hindi, or original English).
  static String toGujaratiName(String name) {
    return NameTransliterationUtils.toLocalizedName(name);
  }

  /// Converts ASCII digits to localized digits based on active language.
  static String toGujaratiNumber(dynamic input) {
    return NameTransliterationUtils.toLocalizedNumber(input);
  }
}
