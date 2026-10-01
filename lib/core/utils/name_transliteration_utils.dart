import 'package:get/get.dart';
import '../localization/app_language_controller.dart';

class NameTransliterationUtils {
  // Standard honorific titles & prefixes
  static const Map<String, String> _titlesGujarati = {
    'dr.': 'ડૉ.',
    'dr': 'ડૉ.',
    'pt.': 'પં.',
    'pt': 'પં.',
    'pandit': 'પંડિત',
    'acharya': 'આચાર્ય',
    'shri': 'શ્રી',
    'smt.': 'શ્રીમતી',
    'smt': 'શ્રીમતી',
    'swami': 'સ્વામી',
    'tarot': 'ટેરોટ',
    'astrologer': 'જ્યોતિષી',
    'astrologers': 'જ્યોતિષીઓ',
  };

  static const Map<String, String> _titlesHindi = {
    'dr.': 'डॉ.',
    'dr': 'डॉ.',
    'pt.': 'पं.',
    'pt': 'पं.',
    'pandit': 'पंडित',
    'acharya': 'आचार्य',
    'shri': 'श्री',
    'smt.': 'श्रीमती',
    'smt': 'श्रीमती',
    'swami': 'स्वामी',
    'tarot': 'टैरो',
    'astrologer': 'ज्योतिषी',
    'astrologers': 'ज्योतिषी',
  };

  // Dynamic Indic Specializations
  static const Map<String, String> _specializationsGujarati = {
    'astrology skills': 'જ્યોતિષ કૌશલ્ય',
    'vedic astrology': 'વૈદિક જ્યોતિષ',
    'vedic astrologer': 'વૈદિક જ્યોતિષી',
    'kundali matching': 'કુંડળી મિલાન',
    'numerology': 'અંકશાસ્ત્ર',
    'tarot reading': 'ટેરોટ રીડિંગ',
    'tarot card reading': 'ટેરોટ કાર્ડ રીડિંગ',
    'palmistry': 'હસ્તરેખા શાસ્ત્ર',
    'vastu shastra': 'વાસ્તુ શાસ્ત્ર',
    'gemology': 'રત્નશાસ્ત્ર',
    'horoscope': 'રાશિફળ',
    'love compatibility': 'પ્રેમ સુસંગતતા',
    'prashna horary': 'પ્રશ્ન કુંડળી',
    'spiritual counseling': 'આધ્યાત્મિક માર્ગદર્શન',
    'vedic astrology & kundali': 'વૈદિક જ્યોતિષ અને કુંડળી',
    'numerology & career growth': 'અંકશાસ્ત્ર અને કરિયર',
    'vastu shastra & gemstones': 'વાસ્તુ શાસ્ત્ર અને રત્નો',
    'love, marriage & relationships': 'પ્રેમ, લગ્ન અને સંબંધો',
    'tarot reading & intuitive healing': 'ટેરોટ રીડિંગ અને હીલિંગ',
    'prashna kundali & palmistry': 'પ્રશ્ન કુંડળી અને હસ્તરેખા',
    'astrologer': 'જ્યોતિષી',
  };

  static const Map<String, String> _specializationsHindi = {
    'astrology skills': 'ज्योतिष कौशल',
    'vedic astrology': 'वैदिक ज्योतिष',
    'vedic astrologer': 'वैदिक ज्योतिषी',
    'kundali matching': 'कुंडली मिलान',
    'numerology': 'अंकशास्त्र',
    'tarot reading': 'टैरो रीडिंग',
    'tarot card reading': 'टैरो कार्ड रीडिंग',
    'palmistry': 'हस्तरेखा शास्त्र',
    'vastu shastra': 'वास्तु शास्त्र',
    'gemology': 'रत्नशास्त्र',
    'horoscope': 'कुंडली / राशिफल',
    'love compatibility': 'प्रेम अनुकूलता',
    'prashna horary': 'प्रश्न कुंडली',
    'spiritual counseling': 'आध्यात्मिक परामर्श',
    'vedic astrology & kundali': 'वैदिक ज्योतिष और कुंडली',
    'numerology & career growth': 'अंकशास्त्र और करियर',
    'vastu shastra & gemstones': 'वास्तु शास्त्र और रत्न',
    'love, marriage & relationships': 'प्रेम, विवाह और संबंध',
    'tarot reading & intuitive healing': 'टैरो रीडिंग और हीलिंग',
    'prashna kundali & palmistry': 'प्रश्न कुंडली और हस्तरेखा',
    'astrologer': 'ज्योतिषी',
  };

  static bool hasDevanagari(String text) =>
      RegExp(r'[\u0900-\u097F]').hasMatch(text);

  static bool hasGujarati(String text) =>
      RegExp(r'[\u0A80-\u0AFF]').hasMatch(text);

  /// Dynamic 1-to-1 Unicode point mapping (+0x0180) converting Devanagari script to Gujarati script.
  static String devanagariToGujarati(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final cp = text.codeUnitAt(i);
      if ((cp >= 0x0901 && cp <= 0x0963) || (cp >= 0x0966 && cp <= 0x096F)) {
        buffer.writeCharCode(cp + 0x0180);
      } else {
        buffer.write(text[i]);
      }
    }
    return buffer.toString();
  }

  /// Dynamic 1-to-1 Unicode point mapping (-0x0180) converting Gujarati script to Devanagari script.
  static String gujaratiToDevanagari(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final cp = text.codeUnitAt(i);
      if ((cp >= 0x0A81 && cp <= 0x0AE3) || (cp >= 0x0AE6 && cp <= 0x0AEF)) {
        buffer.writeCharCode(cp - 0x0180);
      } else {
        buffer.write(text[i]);
      }
    }
    return buffer.toString();
  }

  /// Transliterates any English name dynamically into Gujarati / Hindi script live.
  static String toLocalizedName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return name;

    String lang = 'en';
    if (Get.isRegistered<AppLanguageController>()) {
      lang = Get.find<AppLanguageController>().currentLanguageCode;
    } else {
      lang = Get.locale?.languageCode ?? 'en';
    }

    if (lang == 'gu') {
      if (hasDevanagari(trimmed)) {
        return devanagariToGujarati(trimmed);
      }
      if (hasGujarati(trimmed)) {
        return trimmed;
      }
      return _liveTransliterate(trimmed, isGu: true);
    } else if (lang == 'hi') {
      if (hasGujarati(trimmed)) {
        return gujaratiToDevanagari(trimmed);
      }
      if (hasDevanagari(trimmed)) {
        return trimmed;
      }
      return _liveTransliterate(trimmed, isGu: false);
    }

    return trimmed;
  }

  /// Live phonetic transliteration algorithm
  static String _liveTransliterate(String fullName, {required bool isGu}) {
    final words = fullName.split(RegExp(r'\s+'));
    final convertedWords = words.map((w) {
      if (w.isEmpty) return '';
      final lower = w.toLowerCase().replaceAll(RegExp(r'[^a-z\.]'), '');
      if (isGu && _titlesGujarati.containsKey(lower)) {
        return _titlesGujarati[lower]!;
      } else if (!isGu && _titlesHindi.containsKey(lower)) {
        return _titlesHindi[lower]!;
      }

      return _transliterateSingleWord(w, isGu: isGu);
    }).where((w) => w.isNotEmpty).toList();

    return convertedWords.join(' ');
  }

  static String _transliterateSingleWord(String word, {required bool isGu}) {
    var s = word.toLowerCase().trim();
    if (s.isEmpty) return word;

    final virama = isGu ? '\u0ACD' : '\u094D';
    final aaMatra = isGu ? 'ા' : 'ा';
    final anusvara = isGu ? 'ં' : 'ं';

    // Systematic phonetic refinement for Indic romanization patterns
    s = s.replaceAllMapped(RegExp(r'eht'), (_) => 'ehat');
    s = s.replaceAllMapped(RegExp(r'^ra([jhkmp])'), (m) => 'raa${m[1]}');
    s = s.replaceAllMapped(RegExp(r'kumar'), (_) => 'kumaar');
    s = s.replaceAllMapped(RegExp(r'^verma'), (_) => 'varma');
    s = s.replaceAllMapped(RegExp(r'^dix'), (_) => 'deex');
    s = s.replaceAllMapped(RegExp(r'tel$'), (_) => 'Tel');
    s = s.replaceAllMapped(RegExp(r'tt'), (_) => 'Tt');
    s = s.replaceAllMapped(RegExp(r'singh$'), (_) => 'siMh');
    s = s.replaceAllMapped(RegExp(r'chauhan$'), (_) => isGu ? 'chouhaaN' : 'chouhaan');
    s = s.replaceAllMapped(RegExp(r'anand$'), (_) => 'aaNaMd');

    final indVowels = isGu
        ? {
            'aa': 'આ', 'a': 'અ', 'ee': 'ઈ', 'ii': 'ઈ', 'i': 'ઇ',
            'oo': 'ઊ', 'uu': 'ઊ', 'u': 'ઉ', 'ai': 'ઐ', 'ay': 'ઐ',
            'au': 'ઔ', 'ou': 'ઔ', 'e': 'એ', 'o': 'ઓ', 'ri': 'ઋ'
          }
        : {
            'aa': 'आ', 'a': 'अ', 'ee': 'ई', 'ii': 'ई', 'i': 'इ',
            'oo': 'ऊ', 'uu': 'ऊ', 'u': 'उ', 'ai': 'ऐ', 'ay': 'ऐ',
            'au': 'औ', 'ou': 'औ', 'e': 'ए', 'o': 'ओ', 'ri': 'ऋ'
          };

    final depVowels = isGu
        ? {
            'aa': 'ા', 'ee': 'ી', 'ii': 'ી', 'i': 'િ',
            'oo': 'ૂ', 'uu': 'ૂ', 'u': 'ુ', 'ai': 'ૈ', 'ay': 'ૈ',
            'au': 'ૌ', 'ou': 'ૌ', 'e': 'ે', 'o': 'ો'
          }
        : {
            'aa': 'ा', 'ee': 'ी', 'ii': 'ी', 'i': 'ि',
            'oo': 'ू', 'uu': 'ू', 'u': 'ु', 'ai': 'ै', 'ay': 'ै',
            'au': 'ौ', 'ou': 'ौ', 'e': 'े', 'o': 'ो'
          };

    final consonants = isGu
        ? {
            'shh': 'ષ', 'chh': 'છ', 'thh': 'ઠ', 'dhh': 'ઢ', 'kh': 'ખ',
            'gh': 'ઘ', 'ch': 'ચ', 'jh': 'ઝ', 'th': 'થ', 'dh': 'ધ',
            'ph': 'ફ', 'bh': 'ભ', 'sh': 'શ', 'Tt': 'ટ્ટ', 'T': 'ટ',
            'k': 'ક', 'g': 'ગ', 'c': 'ક', 'j': 'જ', 't': 'ત',
            'd': 'દ', 'N': 'ણ', 'n': 'ન', 'p': 'પ', 'f': 'ફ',
            'b': 'બ', 'm': 'મ', 'y': 'ય', 'r': 'ર', 'l': 'લ',
            'v': 'વ', 'w': 'વ', 's': 'સ', 'h': 'હ', 'z': 'ઝ'
          }
        : {
            'shh': 'ष', 'chh': 'छ', 'thh': 'ठ', 'dhh': 'ढ', 'kh': 'ख',
            'gh': 'घ', 'ch': 'च', 'jh': 'झ', 'th': 'थ', 'dh': 'ध',
            'ph': 'फ', 'bh': 'भ', 'sh': 'श', 'Tt': 'ट्ट', 'T': 'ट',
            'k': 'क', 'g': 'ग', 'c': 'क', 'j': 'ज', 't': 'त',
            'd': 'द', 'N': 'ण', 'n': 'न', 'p': 'प', 'f': 'फ़',
            'b': 'ब', 'm': 'म', 'y': 'य', 'r': 'र', 'l': 'ल',
            'v': 'व', 'w': 'व', 's': 'स', 'h': 'ह', 'z': 'ज़'
          };

    final kLetter = isGu ? 'ક' : 'क';
    final shLetter = isGu ? 'ષ' : 'ष';
    final xCluster = '$kLetter$virama$shLetter';

    final buffer = StringBuffer();
    int i = 0;
    bool lastWasConsonant = false;

    while (i < s.length) {
      // Anusvara token 'M'
      if (s[i] == 'M') {
        buffer.write(anusvara);
        lastWasConsonant = false;
        i++;
        continue;
      }

      // Rule: word-ending 'ai' after consonant -> ાઈ / ाई (e.g. Desai, Bhai, Rai)
      if (s.substring(i).startsWith('ai') && (i + 2 == s.length || !RegExp(r'[a-zA-Z]').hasMatch(s[i + 2]))) {
        if (lastWasConsonant) {
          buffer.write(aaMatra + (isGu ? 'ઈ' : 'ई'));
          lastWasConsonant = false;
          i += 2;
          continue;
        }
      }

      // Rule: word-ending 'ah' after consonant -> ા + હ (e.g. Shah)
      if (s.substring(i).startsWith('ah') && (i + 2 == s.length || !RegExp(r'[a-zA-Z]').hasMatch(s[i + 2]))) {
        if (lastWasConsonant) {
          buffer.write(aaMatra + (isGu ? 'હ' : 'ह'));
          lastWasConsonant = true;
          i += 2;
          continue;
        }
      }

      // Rule: word-ending 'ay' after consonant -> ાય or ય (e.g. Vijay, Sanjay, Ajay)
      if (s.substring(i).startsWith('ay') && (i + 2 == s.length || !RegExp(r'[a-zA-Z]').hasMatch(s[i + 2]))) {
        if (lastWasConsonant) {
          buffer.write(isGu ? 'ય' : 'य');
          lastWasConsonant = true;
          i += 2;
          continue;
        }
      }

      // Rule: word-ending 'ey' after consonant -> ે / े (e.g. Dubey, Pandey)
      if (s.substring(i).startsWith('ey') && (i + 2 == s.length || !RegExp(r'[a-zA-Z]').hasMatch(s[i + 2]))) {
        if (lastWasConsonant) {
          buffer.write(isGu ? 'ે' : 'े');
          lastWasConsonant = false;
          i += 2;
          continue;
        }
      }

      // Special 'x' cluster -> k + virama + sh
      if (s[i] == 'x') {
        if (lastWasConsonant) buffer.write(virama);
        buffer.write(xCluster);
        lastWasConsonant = true;
        i++;
        continue;
      }

      // Multi-char consonants
      String? cMatch;
      int cLen = 0;
      for (final len in [3, 2, 1]) {
        if (i + len <= s.length) {
          final sub = s.substring(i, i + len);
          if (consonants.containsKey(sub)) {
            cMatch = consonants[sub];
            cLen = len;
            break;
          }
        }
      }

      if (cMatch != null) {
        if (lastWasConsonant) {
          buffer.write(virama);
        }
        buffer.write(cMatch);
        lastWasConsonant = true;
        i += cLen;
        continue;
      }

      // Vowels
      String? vMatch;
      int vLen = 0;
      for (final len in [2, 1]) {
        if (i + len <= s.length) {
          final sub = s.substring(i, i + len);
          if (depVowels.containsKey(sub) || sub == 'a') {
            vMatch = sub;
            vLen = len;
            break;
          }
        }
      }

      if (vMatch != null) {
        if (vMatch == 'a') {
          if (lastWasConsonant) {
            // Word-final 'a' after a consonant (e.g. Kavita, Pooja, Shloka) gets aa matra
            if (i == s.length - 1 && s.length > 2) {
              buffer.write(aaMatra);
            }
            // Inherent 'a' - consonant already has inherent vowel
          } else {
            buffer.write(indVowels['a']);
          }
        } else {
          if (lastWasConsonant) {
            buffer.write(depVowels[vMatch]);
          } else {
            buffer.write(indVowels[vMatch] ?? '');
          }
        }
        lastWasConsonant = false;
        i += vLen;
        continue;
      }

      // Any other character (e.g. punctuation, symbols)
      buffer.write(s[i]);
      lastWasConsonant = false;
      i++;
    }

    return buffer.toString();
  }

  /// Localizes an astrologer's specialization or skills cleanly.
  static String toLocalizedSpecialization(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    final lang = Get.locale?.languageCode ?? 'en';

    if (lang == 'gu') {
      if (hasDevanagari(trimmed)) {
        if (trimmed.contains('—')) {
          final parts = trimmed.split('—');
          return devanagariToGujarati(parts.last.trim());
        }
        return devanagariToGujarati(trimmed);
      }
      final lower = trimmed.toLowerCase();
      if (_specializationsGujarati.containsKey(lower)) {
        return _specializationsGujarati[lower]!;
      }
      if (trimmed.contains('—')) {
        final firstPart = trimmed.split('—').first.trim().toLowerCase();
        if (_specializationsGujarati.containsKey(firstPart)) {
          return _specializationsGujarati[firstPart]!;
        }
      }
      return trimmed;
    } else if (lang == 'hi') {
      if (hasGujarati(trimmed)) {
        return gujaratiToDevanagari(trimmed);
      }
      if (trimmed.contains('—')) {
        final parts = trimmed.split('—');
        final lastPart = parts.last.trim();
        if (hasDevanagari(lastPart)) return lastPart;
      }
      final lower = trimmed.toLowerCase();
      if (_specializationsHindi.containsKey(lower)) {
        return _specializationsHindi[lower]!;
      }
      return trimmed;
    } else {
      if (trimmed.contains('—')) {
        return trimmed.split('—').first.trim();
      }
      return trimmed;
    }
  }

  /// Converts ASCII digits to localized digits based on active language.
  static String toLocalizedNumber(dynamic input) {
    final str = input.toString();
    final lang = Get.locale?.languageCode ?? 'en';

    if (lang == 'gu') {
      const digits = ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'];
      return str.replaceAllMapped(RegExp(r'\d'), (m) => digits[int.parse(m.group(0)!)]);
    } else if (lang == 'hi') {
      const digits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
      return str.replaceAllMapped(RegExp(r'\d'), (m) => digits[int.parse(m.group(0)!)]);
    }

    return str;
  }
}
