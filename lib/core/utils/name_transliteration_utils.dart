import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NameTransliterationUtils {
  static const Map<String, String> _knownGujarati = {
    'Shloka Patel': 'શ્લોકા પટેલ',
    'Siddhi Chauhan': 'સિદ્ધિ ચૌહાણ',
    'Rahul Sharma': 'રાહુલ શર્મા',
    'Priya Patel': 'પ્રિયા પટેલ',
    'Anand Shastri': 'આનંદ શાસ્ત્રી',
    'Acharya Vraj': 'આચાર્ય વ્રજ',
    'Pandit Ji': 'પંડિત જી',
    'Astrologer': 'જ્યોતિષી',
    'Astrologers': 'જ્યોતિષીઓ',
    'Acharya': 'આચાર્ય',
    'Pandit': 'પંડિત',
    'Dr.': 'ડૉ.',
    'Shri': 'શ્રી',
    'Smt.': 'શ્રીમતી',
    'Swami': 'સ્વામી',
  };

  static const Map<String, String> _knownHindi = {
    'Shloka Patel': 'श्लोका पटेल',
    'Siddhi Chauhan': 'सिद्धि चौहान',
    'Rahul Sharma': 'राहुल शर्मा',
    'Priya Patel': 'प्रिया पटेल',
    'Anand Shastri': 'आनंद शास्त्री',
    'Acharya Vraj': 'आचार्य व्रज',
    'Pandit Ji': 'पंडित जी',
    'Astrologer': 'ज्योतिषी',
    'Astrologers': 'ज्योतिषी',
    'Acharya': 'आचार्य',
    'Pandit': 'पंडित',
    'Dr.': 'डॉ.',
    'Shri': 'श्री',
    'Smt.': 'श्रीमती',
    'Swami': 'स्वामी',
  };

  static const Map<String, String> _phoneticGujarati = {
    'shloka': 'શ્લોકા',
    'siddhi': 'સિદ્ધિ',
    'chauhan': 'ચૌહાણ',
    'rahul': 'રાહુલ',
    'sharma': 'શર્મા',
    'priya': 'પ્રિયા',
    'patel': 'પટેલ',
    'anand': 'આનંદ',
    'shastri': 'શાસ્ત્રી',
    'vraj': 'વ્રજ',
    'vijay': 'વિજય',
    'amit': 'અમિત',
    'pooja': 'પૂજા',
    'neha': 'નેહા',
    'rohit': 'રોહિત',
    'sunil': 'સુનીલ',
    'rajesh': 'રાજેશ',
    'meena': 'મીના',
    'geeta': 'ગીતા',
    'sanjay': 'સંજય',
    'deepak': 'દીપક',
    'kavita': 'કવિતા',
    'ramesh': 'રમેશ',
    'manish': 'મનીષ',
    'suresh': 'સુરેશ',
    'dinesh': 'દિનેશ',
    'mahesh': 'મહેશ',
    'kiran': 'કિરણ',
    'rekha': 'રેખા',
    'aarti': 'આરતી',
    'kajal': 'કાજલ',
    'divya': 'દિવ્યા',
    'bhavin': 'ભાવિન',
    'rushabh': 'ઋષભ',
    'desai': 'દેસાઈ',
    'joshi': 'જોષી',
    'trivedi': 'ત્રિવેદી',
    'bhatt': 'ભટ્ટ',
    'pandya': 'પંડ્યા',
    'dave': 'દવે',
    'vyas': 'વ્યાસ',
    'parikh': 'પરીખ',
    'shah': 'શાહ',
    'mehta': 'મહેતા',
  };

  static const Map<String, String> _phoneticHindi = {
    'shloka': 'श्लोका',
    'siddhi': 'सिद्धि',
    'chauhan': 'चौहान',
    'rahul': 'राहुल',
    'sharma': 'शर्मा',
    'priya': 'प्रिया',
    'patel': 'पटेल',
    'anand': 'आनंद',
    'shastri': 'शास्त्री',
    'vraj': 'व्रज',
    'vijay': 'विजय',
    'amit': 'अमित',
    'pooja': 'पूजा',
    'neha': 'नेहा',
    'rohit': 'रोहित',
    'sunil': 'सुनील',
    'rajesh': 'राजेश',
    'meena': 'मीना',
    'geeta': 'गीता',
    'sanjay': 'संजय',
    'deepak': 'दीपक',
    'kavita': 'कविता',
    'ramesh': 'रमेश',
    'manish': 'मनीष',
    'suresh': 'सुरेश',
    'dinesh': 'दिनेश',
    'mahesh': 'महेश',
    'kiran': 'किरण',
    'rekha': 'रेखा',
    'aarti': 'आरती',
    'kajal': 'काजल',
    'divya': 'दिव्या',
    'bhavin': 'भाविन',
    'rushabh': 'ऋषभ',
    'desai': 'देसाई',
    'joshi': 'जोशी',
    'trivedi': 'त्रिवेदी',
    'bhatt': 'भट्ट',
    'pandya': 'पंड्या',
    'dave': 'दवे',
    'vyas': 'व्यास',
    'parikh': 'पारीख',
    'shah': 'शाह',
    'mehta': 'मेहता',
  };

  /// Transliterates an English name into active language script (Gujarati, Hindi, or original English).
  static String toLocalizedName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return name;

    // If already contains Gujarati script (U+0A80 to U+0AFF) or Devanagari (U+0900 to U+097F), keep as is
    if (RegExp(r'[\u0A80-\u0AFF]').hasMatch(trimmed) || RegExp(r'[\u0900-\u097F]').hasMatch(trimmed)) {
      return trimmed;
    }

    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'gu') {
      final res = _transliterate(trimmed, _knownGujarati, _phoneticGujarati, _toGujaratiScriptFallback);
      return res.trim().isNotEmpty ? res.trim() : trimmed;
    } else if (lang == 'hi') {
      final res = _transliterate(trimmed, _knownHindi, _phoneticHindi, _toHindiScriptFallback);
      return res.trim().isNotEmpty ? res.trim() : trimmed;
    }

    return trimmed;
  }

  static String _transliterate(
    String name,
    Map<String, String> knownMap,
    Map<String, String> phoneticMap,
    String Function(String) fallbackFn,
  ) {
    if (knownMap.containsKey(name)) {
      return knownMap[name]!;
    }

    final words = name.split(RegExp(r'\s+'));
    final translatedWords = words.map((word) {
      if (word.isEmpty) return '';
      if (knownMap.containsKey(word)) {
        return knownMap[word]!;
      }
      final cleanWord = word.replaceAll(RegExp(r'[^\w\.]'), '');
      if (cleanWord.isEmpty) return word;

      final lower = cleanWord.toLowerCase();
      if (knownMap.containsKey(cleanWord)) {
        return knownMap[cleanWord]!;
      }
      if (phoneticMap.containsKey(lower)) {
        return phoneticMap[lower]!;
      }

      final fallback = fallbackFn(cleanWord);
      return fallback.trim().isNotEmpty ? fallback : word;
    }).where((w) => w.isNotEmpty).toList();

    final result = translatedWords.join(' ');
    return result.trim().isNotEmpty ? result : name;
  }

  static String _toGujaratiScriptFallback(String word) {
    String res = word.toLowerCase();
    res = res.replaceAll('sh', 'શ');
    res = res.replaceAll('ch', 'ચ');
    res = res.replaceAll('th', 'થ');
    res = res.replaceAll('dh', 'ધ');
    res = res.replaceAll('bh', 'ભ');
    res = res.replaceAll('kh', 'ખ');
    res = res.replaceAll('gh', 'ઘ');
    res = res.replaceAll('ph', 'ફ');
    res = res.replaceAll('aa', 'આ');
    res = res.replaceAll('ee', 'ઈ');
    res = res.replaceAll('oo', 'ઊ');
    res = res.replaceAll('ai', 'ઐ');
    res = res.replaceAll('au', 'ઔ');

    final map = {
      'a': 'અ', 'b': 'બ', 'c': 'ક', 'd': 'દ', 'e': 'એ', 'f': 'ફ',
      'g': 'ગ', 'h': 'હ', 'i': 'ઇ', 'j': 'જ', 'k': 'ક', 'l': 'લ',
      'm': 'મ', 'n': 'ન', 'o': 'ઓ', 'p': 'પ', 'q': 'ક', 'r': 'ર',
      's': 'સ', 't': 'ત', 'u': 'ઉ', 'v': 'વ', 'w': 'વ', 'x': 'ક્ષ',
      'y': 'ય', 'z': 'ઝ',
    };

    final buffer = StringBuffer();
    for (int i = 0; i < res.length; i++) {
      final char = res[i];
      buffer.write(map[char] ?? char);
    }
    return buffer.toString();
  }

  static String _toHindiScriptFallback(String word) {
    String res = word.toLowerCase();
    res = res.replaceAll('sh', 'श');
    res = res.replaceAll('ch', 'च');
    res = res.replaceAll('th', 'थ');
    res = res.replaceAll('dh', 'ध');
    res = res.replaceAll('bh', 'भ');
    res = res.replaceAll('kh', 'ख');
    res = res.replaceAll('gh', 'घ');
    res = res.replaceAll('ph', 'फ');
    res = res.replaceAll('aa', 'आ');
    res = res.replaceAll('ee', 'ई');
    res = res.replaceAll('oo', 'ऊ');
    res = res.replaceAll('ai', 'ऐ');
    res = res.replaceAll('au', 'औ');

    final map = {
      'a': 'अ', 'b': 'ब', 'c': 'क', 'd': 'द', 'e': 'ए', 'f': 'फ',
      'g': 'ग', 'h': 'ह', 'i': 'इ', 'j': 'ज', 'k': 'क', 'l': 'ल',
      'm': 'म', 'n': 'न', 'o': 'ओ', 'p': 'प', 'q': 'क', 'r': 'र',
      's': 'स', 't': 'त', 'u': 'उ', 'v': 'व', 'w': 'व', 'x': 'क्ष',
      'y': 'य', 'z': 'ज़',
    };

    final buffer = StringBuffer();
    for (int i = 0; i < res.length; i++) {
      final char = res[i];
      buffer.write(map[char] ?? char);
    }
    return buffer.toString();
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
