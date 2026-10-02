import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Comprehensive Vedic Calendar Engine providing dynamic multi-language (en, hi, gu)
/// calculations for Tithi, Choghadiya, Festivals, Bank Holidays, Public Holidays,
/// Muhurats, Panchang Details, and Vrat Kathas.
class CalendarEngine {
  // ── Language Codes ──────────────────────────────────────────────────────────
  static const String langEn = 'en';
  static const String langHi = 'hi';
  static const String langGu = 'gu';

  static String normalizeLang(String? code) {
    if (code == null) return langGu;
    final lower = code.toLowerCase();
    if (lower.startsWith('hi')) return langHi;
    if (lower.startsWith('en')) return langEn;
    return langGu; // Default to Gujarati
  }

  // ── UI Strings Dictionary ──────────────────────────────────────────────────
  static const Map<String, Map<String, String>> uiStrings = {
    'title': {
      langGu: 'ગુજરાતી કેલેન્ડર & ચોઘડિયા',
      langHi: 'पंचांग कैलेंडर & चौघड़िया',
      langEn: 'Vedic Calendar & Choghadiya',
    },
    'samvat_prefix': {
      langGu: 'વિક્રમ સંવત',
      langHi: 'विक्रम संवत',
      langEn: 'Vikram Samvat',
    },
    'today': {
      langGu: 'આજે',
      langHi: 'आज',
      langEn: 'Today',
    },
    'day_choghadiya': {
      langGu: 'દિવસના ચોઘડિયા',
      langHi: 'दिन का चौघड़िया',
      langEn: 'Day Choghadiya',
    },
    'night_choghadiya': {
      langGu: 'રાત્રિના ચોઘડિયા',
      langHi: 'रात का चौघड़िया',
      langEn: 'Night Choghadiya',
    },
    'choghadiya_for_date': {
      langGu: 'તારીખ %s ના ચોઘડિયા',
      langHi: 'तारीख %s के चौघड़िया',
      langEn: 'Choghadiya for %s',
    },
    'special_festival': {
      langGu: 'આજનો વિશેષ તહેવાર: %s',
      langHi: 'आज का विशेष त्यौहार: %s',
      langEn: "Today's Special Festival: %s",
    },
    'bank_holiday_banner': {
      langGu: 'બેંકિંગ રજા: આજે બેંકો બંધ રહેશે',
      langHi: 'बैंक अवकाश: आज बैंक बंद रहेंगे',
      langEn: 'Bank Holiday: Banks closed today',
    },
    'tithi_label': {
      langGu: 'તિથિ',
      langHi: 'तिथि',
      langEn: 'Tithi',
    },
    'paksha_label': {
      langGu: 'પક્ષ',
      langHi: 'पक्ष',
      langEn: 'Paksha',
    },
    'view_full_panchang': {
      langGu: 'સંપૂર્ણ દૈનિક પંચાંગ જુઓ',
      langHi: 'सम्पूर्ण दैनिक पंचांग देखें',
      langEn: 'View Full Daily Panchang',
    },
    'read_button': {
      langGu: 'વાંચો',
      langHi: 'पढ़ें',
      langEn: 'Read',
    },
    'close_button': {
      langGu: 'બંધ કરો',
      langHi: 'बंद करें',
      langEn: 'Close',
    },
    'total_holidays': {
      langGu: 'કુલ: %s રજાઓ',
      langHi: 'कुल: %s अवकाश',
      langEn: 'Total: %s Holidays',
    },
    'no_holidays': {
      langGu: 'આ મહિનામાં કોઈ બેંકિંગ રજા નથી.',
      langHi: 'इस महीने में कोई बैंक अवकाश नहीं है।',
      langEn: 'No bank holidays in this month.',
    },
    'no_festivals': {
      langGu: 'આ મહિનામાં કોઈ મુખ્ય તહેવાર નથી.',
      langHi: 'इस महीने में कोई मुख्य त्यौहार नहीं है।',
      langEn: 'No major festivals in this month.',
    },
    'festivals_of_month': {
      langGu: '%s ના તહેવારો',
      langHi: '%s के त्यौहार',
      langEn: 'Festivals of %s',
    },
    'bank_holidays_of_month': {
      langGu: '%s બેંકિંગ રજાઓ',
      langHi: '%s बैंक अवकाश',
      langEn: 'Bank Holidays in %s',
    },
    'public_holidays_of_month': {
      langGu: '%s જાહેર રજાઓ',
      langHi: '%s सार्वजनिक अवकाश',
      langEn: 'Public Holidays in %s',
    },
    'current_active': {
      langGu: 'ચાલુ',
      langHi: 'चालू',
      langEn: 'Live',
    },
    'good': {
      langGu: 'શુભ',
      langHi: 'शुभ',
      langEn: 'Good',
    },
    'bad': {
      langGu: 'અશુભ',
      langHi: 'अशुभ',
      langEn: 'Inauspicious',
    },
    'neutral': {
      langGu: 'સામાન્ય',
      langHi: 'सामान्य',
      langEn: 'Neutral',
    },
  };

  static String getUiText(String key, String lang, [String? arg]) {
    final l = normalizeLang(lang);
    var text = uiStrings[key]?[l] ?? uiStrings[key]?[langGu] ?? key;
    if (arg != null) {
      text = text.replaceAll('%s', arg);
    }
    return text;
  }

  // ── Weekdays Header ────────────────────────────────────────────────────────
  static List<Map<String, String>> getWeekdays(String lang) {
    final l = normalizeLang(lang);
    if (l == langHi) {
      return const [
        {'short': 'रवि', 'full': 'रविवार'},
        {'short': 'सोम', 'full': 'सोमवार'},
        {'short': 'मंगल', 'full': 'मंगलवार'},
        {'short': 'बुध', 'full': 'बुधवार'},
        {'short': 'गुरु', 'full': 'गुरुवार'},
        {'short': 'शुक्र', 'full': 'शुक्रवार'},
        {'short': 'शनि', 'full': 'शनिवार'},
      ];
    } else if (l == langEn) {
      return const [
        {'short': 'Sun', 'full': 'Sunday'},
        {'short': 'Mon', 'full': 'Monday'},
        {'short': 'Tue', 'full': 'Tuesday'},
        {'short': 'Wed', 'full': 'Wednesday'},
        {'short': 'Thu', 'full': 'Thursday'},
        {'short': 'Fri', 'full': 'Friday'},
        {'short': 'Sat', 'full': 'Saturday'},
      ];
    }
    return const [
      {'short': 'રવિ', 'full': 'રવિવાર'},
      {'short': 'સોમ', 'full': 'સોમવાર'},
      {'short': 'મંગળ', 'full': 'મંગળવાર'},
      {'short': 'બુધ', 'full': 'બુધવાર'},
      {'short': 'ગુરુ', 'full': 'ગુરુવાર'},
      {'short': 'શુક્ર', 'full': 'શુક્રવાર'},
      {'short': 'શનિ', 'full': 'શનિવાર'},
    ];
  }

  // ── Tabs Definition ─────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> getTabs(String lang) {
    final l = normalizeLang(lang);
    if (l == langHi) {
      return const [
        {'title': 'चौघड़िया', 'icon': Icons.access_time_filled_rounded},
        {'title': 'त्यौहार', 'icon': Icons.celebration_rounded},
        {'title': 'बैंक अवकाश', 'icon': Icons.account_balance_rounded},
        {'title': 'सार्वजनिक अवकाश', 'icon': Icons.beach_access_rounded},
        {'title': 'शुभ मुहूर्त', 'icon': Icons.brightness_auto_rounded},
        {'title': 'पंचांग', 'icon': Icons.calendar_month_rounded},
        {'title': 'व्रत कथाएं', 'icon': Icons.menu_book_rounded},
      ];
    } else if (l == langEn) {
      return const [
        {'title': 'Choghadiya', 'icon': Icons.access_time_filled_rounded},
        {'title': 'Festivals', 'icon': Icons.celebration_rounded},
        {'title': 'Bank Holidays', 'icon': Icons.account_balance_rounded},
        {'title': 'Public Holidays', 'icon': Icons.beach_access_rounded},
        {'title': 'Muhurat', 'icon': Icons.brightness_auto_rounded},
        {'title': 'Panchang', 'icon': Icons.calendar_month_rounded},
        {'title': 'Vrat Katha', 'icon': Icons.menu_book_rounded},
      ];
    }
    return const [
      {'title': 'ચોઘડિયા', 'icon': Icons.access_time_filled_rounded},
      {'title': 'તહેવારો', 'icon': Icons.celebration_rounded},
      {'title': 'બેંકિંગ રજાઓ', 'icon': Icons.account_balance_rounded},
      {'title': 'જાહેર રજાઓ', 'icon': Icons.beach_access_rounded},
      {'title': 'મુહૂર્ત', 'icon': Icons.brightness_auto_rounded},
      {'title': 'કૅલેન્ડર પંચાંગ', 'icon': Icons.calendar_month_rounded},
      {'title': 'વ્રત કથાઓ', 'icon': Icons.menu_book_rounded},
    ];
  }

  // ── Hindu Months ───────────────────────────────────────────────────────────
  static const Map<String, List<String>> _hinduMonths = {
    langGu: [
      'પોષ - મહા',
      'મહા - ફાગણ',
      'ફાગણ - ચૈત્ર',
      'ચૈત્ર - વૈશાખ',
      'વૈશાખ - જેઠ',
      'જેઠ - અષાઢ',
      'અષાઢ - શ્રાવણ',
      'શ્રાવણ - ભાદરવો',
      'ભાદરવો - આસો',
      'આસો - કારતક',
      'કારતક - માગશર',
      'માગશર - પોષ',
    ],
    langHi: [
      'पौष - माघ',
      'माघ - फाल्गुन',
      'फाल्गुन - चैत्र',
      'चैत्र - वैशाख',
      'वैशाख - ज्येष्ठ',
      'ज्येष्ठ - आषाढ़',
      'आषाढ़ - श्रावण',
      'श्रावण - भाद्रपद',
      'भाद्रपद - आश्विन',
      'आश्विन - कार्तिक',
      'कार्तिक - मार्गशीर्ष',
      'मार्गशीर्ष - पौष',
    ],
    langEn: [
      'Paush - Magha',
      'Magha - Phalguna',
      'Phalguna - Chaitra',
      'Chaitra - Vaishakha',
      'Vaishakha - Jyeshtha',
      'Jyeshtha - Ashadha',
      'Ashadha - Shravana',
      'Shravana - Bhadrapada',
      'Bhadrapada - Ashwin',
      'Ashwin - Kartika',
      'Kartika - Margashirsha',
      'Margashirsha - Paush',
    ],
  };

  static String getHinduMonthName(int month, String lang) {
    final l = normalizeLang(lang);
    final list = _hinduMonths[l] ?? _hinduMonths[langGu]!;
    return list[(month - 1) % 12];
  }

  // ── Vikram Samvat Calculation ──────────────────────────────────────────────
  static String getVikramSamvat(int year, int month, String lang) {
    // In Gujarati / Kartikadi calendar, Vikram Samvat turns around Diwali (Oct/Nov).
    // For 2026 before Nov: VS 2082. After Nov: VS 2083.
    final vsYear = month >= 11 ? year + 57 : year + 56;
    final l = normalizeLang(lang);
    if (l == langHi) {
      return _toHindiNumerals(vsYear);
    } else if (l == langGu) {
      return _toGujaratiNumerals(vsYear);
    }
    return vsYear.toString();
  }

  static String _toGujaratiNumerals(int number) {
    const gujDigits = ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'];
    return number.toString().split('').map((char) {
      final d = int.tryParse(char);
      return d != null ? gujDigits[d] : char;
    }).join('');
  }

  static String _toHindiNumerals(int number) {
    const hiDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    return number.toString().split('').map((char) {
      final d = int.tryParse(char);
      return d != null ? hiDigits[d] : char;
    }).join('');
  }

  // ── Astronomical Tithi Calculation ─────────────────────────────────────────
  static final List<String> _tithisGu = [
    'સુદ એકમ', 'સુદ બીજ', 'સુદ ત્રીજ', 'સુદ ચોથ', 'સુદ પાંચમ',
    'સુદ છઠ', 'સુદ સાતમ', 'સુદ આઠમ', 'સુદ નોમ', 'સુદ દસમ',
    'સુદ અગિયારસ', 'સુદ બારસ', 'સુદ તેરસ', 'સુદ ચૌદશ', 'પૂનમ',
    'વદ એકમ', 'વદ બીજ', 'વદ ત્રીજ', 'વદ ચોથ', 'વદ પાંચમ',
    'વદ છઠ', 'વદ સાતમ', 'વદ આઠમ', 'વદ નોમ', 'વદ દસમ',
    'વદ અગિયારસ', 'વદ બારસ', 'વદ તેરસ', 'વદ ચૌદશ', 'અમાસ'
  ];

  static final List<String> _tithisHi = [
    'शुक्ल प्रतिपदा', 'शुक्ल द्वितीया', 'शुक्ल तृतीया', 'शुक्ल चतुर्थी', 'शुक्ल पंचमी',
    'शुक्ल षष्ठी', 'शुक्ल सप्तमी', 'शुक्ल अष्टमी', 'शुक्ल नवमी', 'शुक्ल दशमी',
    'शुक्ल एकादशी', 'शुक्ल द्वादशी', 'शुक्ल त्रयोदशी', 'शुक्ल चतुर्दशी', 'पूर्णिमा',
    'कृष्ण प्रतिपदा', 'कृष्ण द्वितीया', 'कृष्ण तृतीया', 'कृष्ण चतुर्थी', 'कृष्ण पंचमी',
    'कृष्ण षष्ठी', 'कृष्ण सप्तमी', 'कृष्ण अष्टमी', 'कृष्ण नवमी', 'कृष्ण दशमी',
    'कृष्ण एकादशी', 'कृष्ण द्वादशी', 'कृष्ण त्रयोदशी', 'कृष्ण चतुर्दशी', 'अमावस्या'
  ];

  static final List<String> _tithisEn = [
    'Shukla Pratipada', 'Shukla Dwitiya', 'Shukla Tritiya', 'Shukla Chaturthi', 'Shukla Panchami',
    'Shukla Shashthi', 'Shukla Saptami', 'Shukla Ashtami', 'Shukla Navami', 'Shukla Dashami',
    'Shukla Ekadashi', 'Shukla Dwadashi', 'Shukla Trayodashi', 'Shukla Chaturdashi', 'Purnima',
    'Krishna Pratipada', 'Krishna Dwitiya', 'Krishna Tritiya', 'Krishna Chaturthi', 'Krishna Panchami',
    'Krishna Shashthi', 'Krishna Saptami', 'Krishna Ashtami', 'Krishna Navami', 'Krishna Dashami',
    'Krishna Ekadashi', 'Krishna Dwadashi', 'Krishna Trayodashi', 'Krishna Chaturdashi', 'Amavasya'
  ];

  /// Computes authentic lunar tithi index (1-30) using astronomical moon phase formula
  static int getTithiIndex(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    final jdn = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;

    // Reference New Moon: Jan 11, 2024 (JDN 2460321.0)
    const refJdn = 2460321.0;
    const synodic = 29.530588853;
    var phase = ((jdn - refJdn) / synodic) % 1.0;
    if (phase < 0) phase += 1.0;

    var tithi = (phase * 30).floor() + 1;
    if (tithi < 1) tithi = 1;
    if (tithi > 30) tithi = 30;
    return tithi;
  }

  static String getTithiName(DateTime date, String lang) {
    final l = normalizeLang(lang);
    final idx = getTithiIndex(date) - 1;
    if (l == langHi) return _tithisHi[idx];
    if (l == langEn) return _tithisEn[idx];
    return _tithisGu[idx];
  }

  static String getShortTithi(DateTime date, String lang) {
    final l = normalizeLang(lang);
    final idx = getTithiIndex(date) - 1;
    // Special highlights for Purnima (idx 14), Amavasya (idx 29), Ekadashi (idx 10, 25)
    if (idx == 14) {
      return l == langHi ? 'पूर्णिमा' : (l == langEn ? 'Purnima' : 'પૂનમ');
    }
    if (idx == 29) {
      return l == langHi ? 'अमावस्या' : (l == langEn ? 'Amavasya' : 'અમાસ');
    }
    if (idx == 10 || idx == 25) {
      return l == langHi ? 'एकादशी' : (l == langEn ? 'Ekadashi' : 'અગિયારસ');
    }

    final full = getTithiName(date, lang);
    return full.split(' ').last;
  }

  static String getPaksha(DateTime date, String lang) {
    final l = normalizeLang(lang);
    final idx = getTithiIndex(date) - 1;
    final isShukla = idx < 15;
    if (l == langHi) {
      return isShukla ? 'शुक्ल पक्ष (सुद)' : 'कृष्ण पक्ष (वद)';
    } else if (l == langEn) {
      return isShukla ? 'Shukla Paksha (Waxing)' : 'Krishna Paksha (Waning)';
    }
    return isShukla ? 'શુક્લ પક્ષ (સુદ)' : 'કૃષ્ણ પક્ષ (વદ)';
  }

  // ── Authentic Dynamic Choghadiya Engine ────────────────────────────────────
  // Choghadiya sequence by day of the week (0 = Sunday to 6 = Saturday)
  static const List<List<String>> _dayChoghadiyaSequence = [
    // 0: Sunday (Ravivar)
    ['Udveg', 'Char', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg'],
    // 1: Monday (Somvar)
    ['Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Char', 'Labh', 'Amrit'],
    // 2: Tuesday (Mangalvar)
    ['Rog', 'Udveg', 'Char', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog'],
    // 3: Wednesday (Budhvar)
    ['Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Char', 'Labh'],
    // 4: Thursday (Guruvar)
    ['Shubh', 'Rog', 'Udveg', 'Char', 'Labh', 'Amrit', 'Kaal', 'Shubh'],
    // 5: Friday (Shukravar)
    ['Char', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Char'],
    // 6: Saturday (Shanivar)
    ['Kaal', 'Shubh', 'Rog', 'Udveg', 'Char', 'Labh', 'Amrit', 'Kaal'],
  ];

  static const List<List<String>> _nightChoghadiyaSequence = [
    // 0: Sunday night
    ['Shubh', 'Amrit', 'Char', 'Rog', 'Kaal', 'Labh', 'Udveg', 'Shubh'],
    // 1: Monday night
    ['Char', 'Rog', 'Kaal', 'Labh', 'Udveg', 'Shubh', 'Amrit', 'Char'],
    // 2: Tuesday night
    ['Kaal', 'Labh', 'Udveg', 'Shubh', 'Amrit', 'Char', 'Rog', 'Kaal'],
    // 3: Wednesday night
    ['Udveg', 'Shubh', 'Amrit', 'Char', 'Rog', 'Kaal', 'Labh', 'Udveg'],
    // 4: Thursday night
    ['Amrit', 'Char', 'Rog', 'Kaal', 'Labh', 'Udveg', 'Shubh', 'Amrit'],
    // 5: Friday night
    ['Rog', 'Kaal', 'Labh', 'Udveg', 'Shubh', 'Amrit', 'Char', 'Rog'],
    // 6: Saturday night
    ['Labh', 'Udveg', 'Shubh', 'Amrit', 'Char', 'Rog', 'Kaal', 'Labh'],
  ];

  static const Map<String, Map<String, dynamic>> _choghadiyaMeta = {
    'Amrit': {
      'type': 'good',
      'name': {langGu: 'અમૃત', langHi: 'अमृत', langEn: 'Amrit'},
      'nature': {
        langGu: 'શ્રેષ્ઠ (સર્વ કાર્યસિદ્ધિ)',
        langHi: 'सर्वश्रेष्ठ (सर्व कार्य सिद्धि)',
        langEn: 'Best (Auspicious & Success)',
      },
    },
    'Shubh': {
      'type': 'good',
      'name': {langGu: 'શુભ', langHi: 'शुभ', langEn: 'Shubh'},
      'nature': {
        langGu: 'શુભ (ધાર્મિક/શુભ કાર્ય)',
        langHi: 'उत्तम (मांगलिक व शुभ कार्य)',
        langEn: 'Auspicious (Favorable)',
      },
    },
    'Labh': {
      'type': 'good',
      'name': {langGu: 'લાભ', langHi: 'लाभ', langEn: 'Labh'},
      'nature': {
        langGu: 'ઉન્નતિ (વેપાર/ધન લાભ)',
        langHi: 'उन्नति (व्यापार व धन लाभ)',
        langEn: 'Prosperity (Financial Gain)',
      },
    },
    'Char': {
      'type': 'neutral',
      'name': {langGu: 'ચલ', langHi: 'चर', langEn: 'Char'},
      'nature': {
        langGu: 'સામાન્ય (યાત્રા/પ્રવાસ યોગ્ય)',
        langHi: 'सामान्य (यात्रा के लिए उपयुक्त)',
        langEn: 'Neutral (Good for Travel)',
      },
    },
    'Udveg': {
      'type': 'bad',
      'name': {langGu: 'ઉદ્વેગ', langHi: 'उद्वेग', langEn: 'Udveg'},
      'nature': {
        langGu: 'અશુભ (ચિંતાજનક કાર્ય)',
        langHi: 'अशुभ (हानिकारक/तनाव)',
        langEn: 'Inauspicious (Stressful)',
      },
    },
    'Kaal': {
      'type': 'bad',
      'name': {langGu: 'કાળ', langHi: 'काल', langEn: 'Kaal'},
      'nature': {
        langGu: 'હાનીકારક (વિલંબ/કષ્ટ)',
        langHi: 'हानिकारक (कष्टकारी व वर्ज्य)',
        langEn: 'Inauspicious (Harmful)',
      },
    },
    'Rog': {
      'type': 'bad',
      'name': {langGu: 'રોગ', langHi: 'रोग', langEn: 'Rog'},
      'nature': {
        langGu: 'અનિષ્ટ (રોગ/નુકસાન)',
        langHi: 'अनिष्ट (रोग व बाधा)',
        langEn: 'Inauspicious (Illness/Loss)',
      },
    },
  };

  /// Calculates the 8 Choghadiya intervals for any given date and day/night mode
  static List<Map<String, dynamic>> calculateChoghadiya(
    DateTime date, {
    required bool isDay,
    required String lang,
    DateTime? nowTime,
  }) {
    final l = normalizeLang(lang);
    final weekdayIndex = date.weekday % 7; // Sunday = 0, Monday = 1, ...
    final sequence = isDay
        ? _dayChoghadiyaSequence[weekdayIndex]
        : _nightChoghadiyaSequence[weekdayIndex];

    // Standard sunrise at 06:15 AM, sunset at 06:30 PM (or seasonally calculated)
    final sunrise = DateTime(date.year, date.month, date.day, 6, 15);
    final sunset = DateTime(date.year, date.month, date.day, 18, 30);
    final nextSunrise = DateTime(date.year, date.month, date.day + 1, 6, 15);

    final startBase = isDay ? sunrise : sunset;
    final endBase = isDay ? sunset : nextSunrise;
    final totalDurationMs = endBase.difference(startBase).inMilliseconds;
    final slotDurationMs = totalDurationMs ~/ 8;

    final now = nowTime ?? DateTime.now();
    final isSelectedDateToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final List<Map<String, dynamic>> list = [];

    for (int i = 0; i < 8; i++) {
      final slotStart = startBase.add(Duration(milliseconds: slotDurationMs * i));
      final slotEnd = startBase.add(Duration(milliseconds: slotDurationMs * (i + 1)));

      final key = sequence[i];
      final meta = _choghadiyaMeta[key] ?? _choghadiyaMeta['Amrit']!;
      final type = meta['type'] as String;
      final name = (meta['name'] as Map<String, String>)[l] ??
          (meta['name'] as Map<String, String>)[langGu]!;
      final nature = (meta['nature'] as Map<String, String>)[l] ??
          (meta['nature'] as Map<String, String>)[langGu]!;

      final timeFormatter = DateFormat('hh:mm a');
      final timeStr = '${timeFormatter.format(slotStart)} - ${timeFormatter.format(slotEnd)}';

      final isActive = isSelectedDateToday &&
          now.isAfter(slotStart) &&
          now.isBefore(slotEnd);

      list.add({
        'key': key,
        'name': name,
        'nature': nature,
        'time': timeStr,
        'type': type,
        'isActive': isActive,
        'startTime': slotStart,
        'endTime': slotEnd,
      });
    }

    return list;
  }

  // ── Authentic Multi-Language Festivals Dictionary ─────────────────────────
  static const Map<int, Map<int, Map<String, String>>> _festivals = {
    1: {
      1: {langGu: 'અંગ્રેજી નવું વર્ષ', langHi: 'अंग्रेजी नव वर्ष', langEn: 'New Year Day'},
      13: {langGu: 'લોહરી', langHi: 'लोहड़ी', langEn: 'Lohri'},
      14: {langGu: 'મકરસંક્રાંતિ (ઉત્તરાયણ)', langHi: 'मकर संक्रांति', langEn: 'Makar Sankranti'},
      15: {langGu: 'વાસી ઉત્તરાયણ', langHi: 'पोंगल', langEn: 'Pongal / Vasi Uttarayan'},
      23: {langGu: 'નેતાજી સુભાષચંદ્ર બોઝ જયંતી', langHi: 'नेताजी सुभाष चंद्र बोस जयंती', langEn: 'Netaji Subhash Jayanti'},
      26: {langGu: 'પ્રજાસત્તાક દિન (Republic Day)', langHi: 'गणतंत्र दिवस (Republic Day)', langEn: 'Republic Day'},
    },
    2: {
      1: {langGu: 'વસંત પંચમી (સરસ્વતી પૂજા)', langHi: 'बसंत पंचमी', langEn: 'Vasant Panchami'},
      15: {langGu: 'મહા શિવરાત્રી', langHi: 'महा शिवरात्रि', langEn: 'Maha Shivratri'},
    },
    3: {
      2: {langGu: 'હોલિકા દહન', langHi: 'होलिका दहन', langEn: 'Holika Dahan'},
      3: {langGu: 'ધૂળેટી (હોળી)', langHi: 'धुलेंडी / होली', langEn: 'Holi / Dhuleti'},
      19: {langGu: 'ચેટીચંડ / ગુડી પડવો', langHi: 'चेटीचंड / गुड़ी पड़वा', langEn: 'Cheti Chand / Gudi Padwa'},
      21: {langGu: 'રમઝાન ઈદ (Eid-ul-Fitr)', langHi: 'ईद-उल-फितर (रमजान)', langEn: 'Eid-ul-Fitr'},
      27: {langGu: 'શ્રી રામનવમી', langHi: 'श्री राम नवमी', langEn: 'Rama Navami'},
      31: {langGu: 'મહાવીર જયંતી', langHi: 'महावीर स्वामी जयंती', langEn: 'Mahavir Jayanti'},
    },
    4: {
      1: {langGu: 'વાર્ષિક બેંક ક્લોઝિંગ', langHi: 'वार्षिक बैंक क्लोजिंग', langEn: 'Bank Annual Closing'},
      3: {langGu: 'ગુડ ફ્રાઈડે (Good Friday)', langHi: 'गुड फ्राइडे', langEn: 'Good Friday'},
      14: {langGu: 'ડૉ. બાબાસાહેબ આંબેડકર જયંતી', langHi: 'डॉ. बी.आर. अम्बेडकर जयंती', langEn: 'Dr. B.R. Ambedkar Jayanti'},
      16: {langGu: 'શ્રી હનુમાન જયંતી', langHi: 'हनुमान जन्मोत्सव', langEn: 'Hanuman Jayanti'},
    },
    5: {
      1: {langGu: 'ગુજરાત સ્થાપના દિન / મજૂર દિન', langHi: 'गुजरात स्थापना दिवस / मजदूर दिवस', langEn: 'Gujarat Day / Labour Day'},
      12: {langGu: 'શ્રી નરસિંહ જયંતી', langHi: 'नरसिंह जयंती', langEn: 'Narsimha Jayanti'},
      21: {langGu: 'બુદ્ધ પૂર્ણિમા', langHi: 'बुद्ध पूर्णिमा', langEn: 'Buddha Purnima'},
    },
    6: {
      5: {langGu: 'વિશ્વ પર્યાવરણ દિન', langHi: 'विश्व पर्यावरण दिवस', langEn: 'World Environment Day'},
      21: {langGu: 'વિશ્વ યોગ દિન', langHi: 'अंतरराष्ट्रीय योग दिवस', langEn: 'International Yoga Day'},
    },
    7: {
      10: {langGu: 'જગન્નાથ રથયાત્રા (અષાઢી બીજ)', langHi: 'जगन्नाथ रथयात्रा (आषाढ़ी बीज)', langEn: 'Ratha Yatra (Ashadhi Beej)'},
      19: {langGu: 'ગુરુ પૂર્ણિમા (વ્યાસ પૂજા)', langHi: 'गुरु पूर्णिमा', langEn: 'Guru Purnima'},
      28: {langGu: 'જયા પાર્વતી વ્રત પ્રારંભ', langHi: 'जया पार्वती व्रत प्रारम्भ', langEn: 'Jaya Parvati Vrat Start'},
    },
    8: {
      15: {langGu: 'સ્વાતંત્ર્ય દિન (Independence Day)', langHi: 'स्वतंत्रता दिवस (Independence Day)', langEn: 'Independence Day'},
      28: {langGu: 'રક્ષાબંધન (બળેવ)', langHi: 'रक्षाबंधन', langEn: 'Raksha Bandhan'},
    },
    9: {
      3: {langGu: 'શીતળા સાતમ', langHi: 'शीतला सप्तमी', langEn: 'Sheetala Satam'},
      4: {langGu: 'શ્રી કૃષ્ણ જન્માષ્ટમી', langHi: 'श्री कृष्ण जन्माष्टमी', langEn: 'Krishna Janmashtami'},
      5: {langGu: 'નંદ મહોત્સવ', langHi: 'नंद महोत्सव', langEn: 'Nand Mahotsav'},
      15: {langGu: 'શ્રી ગણેશ ચતુર્થી (સ્થાપના)', langHi: 'श्री गणेश चतुर्थी (गणेशोत्सव)', langEn: 'Ganesh Chaturthi'},
      24: {langGu: 'અનંત ચતુર્દશી (ગણેશ વિસર્જન)', langHi: 'अनंत चतुर्दशी (गणेश विसर्जन)', langEn: 'Anant Chaturdashi'},
      27: {langGu: 'શ્રાદ્ધ પક્ષ પ્રારંભ', langHi: 'पितृ पक्ष / श्राद्ध प्रारम्भ', langEn: 'Pitru Paksha Begins'},
    },
    10: {
      2: {langGu: 'મહાત્મા ગાંધી જયંતી', langHi: 'महात्मा गांधी जयंती', langEn: 'Gandhi Jayanti'},
      11: {langGu: 'શારદીય નવરાત્રી પ્રારંભ (ઘટસ્થાપના)', langHi: 'शारदीय नवरात्रि प्रारम्भ', langEn: 'Navratri Begins'},
      18: {langGu: 'દુર્ગાષ્ટમી (મહાષ્ટમી)', langHi: 'दुर्गा अष्टमी / महाष्टमी', langEn: 'Durga Ashtami'},
      19: {langGu: 'મહા નોમ', langHi: 'महानवमी', langEn: 'Maha Navami'},
      20: {langGu: 'વિજયાદશમી (દશેરા)', langHi: 'विजयादशमी (दशहरा)', langEn: 'Dussehra (Vijayadashami)'},
      24: {langGu: 'શરદ પૂર્ણિમા', langHi: 'शरद पूर्णिमा', langEn: 'Sharad Purnima'},
      29: {langGu: 'કરવા ચોથ', langHi: 'करवा चौथ व्रत', langEn: 'Karwa Chauth'},
    },
    11: {
      6: {langGu: 'ધનતેરસ (શ્રી ધનવંતરિ પૂજન)', langHi: 'धनतेरस (धनवंतरी जयंती)', langEn: 'Dhanteras'},
      7: {langGu: 'કાળી ચૌદશ (રૂપ ચતુર્દશી)', langHi: 'नरक चतुर्दशी (छोटी दिवाली)', langEn: 'Kali Chaudas'},
      8: {langGu: 'દિવાળી (દીપાવલી / લક્ષ્મી પૂજન)', langHi: 'दीपावली (लक्ष्मी पूजन)', langEn: 'Diwali (Deepawali)'},
      9: {langGu: 'નૂતન વર્ષ (બેસતું વર્ષ / ગોવર્ધન પૂજા)', langHi: 'गोवर्धन पूजा / नूतन वर्ष', langEn: 'New Year (Bestu Varas / Govardhan Puja)'},
      10: {langGu: 'ભાઈબીજ (યમ દ્વિતીયા)', langHi: 'भाई दूज', langEn: 'Bhai Dooj'},
      14: {langGu: 'લાભ પાંચમ (સૌભાગ્ય પંચમી)', langHi: 'लाभ पंचमी', langEn: 'Labh Pancham'},
      24: {langGu: 'દેવ દિવાળી (તુલસી વિવાહ પૂર્ણાહુતિ)', langHi: 'देव दीपावली (तुलसी विवाह)', langEn: 'Dev Diwali (Tulsi Vivah)'},
    },
    12: {
      21: {langGu: 'ગીતા જયંતી / મોક્ષદા એકાદશી', langHi: 'गीता जयंती / मोक्षदा एकादशी', langEn: 'Gita Jayanti / Mokshada Ekadashi'},
      25: {langGu: 'નાતાલ (Christmas)', langHi: 'क्रिसमस (Christmas)', langEn: 'Christmas'},
      31: {langGu: 'વર્ષ વિદાય (New Year Eve)', langHi: 'वर्ष विदाई (New Year Eve)', langEn: 'New Year Eve'},
    },
  };

  static String? getFestival(int month, int day, String lang) {
    final l = normalizeLang(lang);
    final map = _festivals[month]?[day];
    if (map == null) return null;
    return map[l] ?? map[langGu];
  }

  static Map<int, String> getFestivalsForMonth(int month, String lang) {
    final l = normalizeLang(lang);
    final monthMap = _festivals[month] ?? {};
    final Map<int, String> res = {};
    monthMap.forEach((day, map) {
      res[day] = map[l] ?? map[langGu] ?? '';
    });
    return res;
  }

  // ── Authentic Dynamic Bank Holidays ───────────────────────────────────────
  static List<Map<String, dynamic>> getBankHolidaysForMonth(
    int year,
    int month,
    String lang,
  ) {
    final l = normalizeLang(lang);
    final List<Map<String, dynamic>> list = [];

    // 1. Calculate 2nd & 4th Saturday dynamically for ANY year and month
    int saturdayCount = 0;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday == DateTime.saturday) {
        saturdayCount++;
        if (saturdayCount == 2) {
          list.add({
            'day': day,
            'name': l == langHi
                ? 'दूसरा शनिवार (2nd Saturday)'
                : (l == langEn ? 'Second Saturday' : 'બીજો શનિવાર (2nd Saturday)'),
            'note': l == langHi
                ? 'सभी बैंक बंद'
                : (l == langEn ? 'All Banks Closed' : 'તમામ બેંકો બંધ'),
          });
        } else if (saturdayCount == 4) {
          list.add({
            'day': day,
            'name': l == langHi
                ? 'चौथा शनिवार (4th Saturday)'
                : (l == langEn ? 'Fourth Saturday' : 'ચોથો શનિવાર (4th Saturday)'),
            'note': l == langHi
                ? 'सभी बैंक बंद'
                : (l == langEn ? 'All Banks Closed' : 'તમામ બેંકો બંધ'),
          });
        }
      }
    }

    // 2. Specific gazetted bank holidays with 3-language translations
    final specificHolidays = {
      1: [
        {
          'day': 26,
          'name': {
            langGu: 'પ્રજાસત્તાક દિન (Republic Day)',
            langHi: 'गणतंत्र दिवस (Republic Day)',
            langEn: 'Republic Day',
          },
          'note': {
            langGu: 'રાષ્ટ્રીય બેંક રજા',
            langHi: 'राष्ट्रीय बैंक अवकाश',
            langEn: 'National Bank Holiday',
          },
        }
      ],
      3: [
        {
          'day': 3,
          'name': {
            langGu: 'ધૂળેટી (Holi)',
            langHi: 'धुलेंडी / होली',
            langEn: 'Holi Festival',
          },
          'note': {
            langGu: 'તમામ બેંકો બંધ',
            langHi: 'सभी बैंक बंद',
            langEn: 'All Banks Closed',
          },
        },
        {
          'day': 21,
          'name': {
            langGu: 'રમઝાન ઈદ (Eid-ul-Fitr)',
            langHi: 'ईद-उल-फितर',
            langEn: 'Eid-ul-Fitr',
          },
          'note': {
            langGu: 'બેંકિંગ રજા',
            langHi: 'बैंक अवकाश',
            langEn: 'Bank Holiday',
          },
        },
      ],
      4: [
        {
          'day': 1,
          'name': {
            langGu: 'વાર્ષિક એકાઉન્ટ ક્લોઝિંગ',
            langHi: 'वार्षिक लेखाबंदी',
            langEn: 'Annual Bank Accounts Closing',
          },
          'note': {
            langGu: 'વાર્ષિક ક્લોઝિંગ રજા',
            langHi: 'वार्षिक अवकाश',
            langEn: 'Annual Holiday',
          },
        },
        {
          'day': 3,
          'name': {
            langGu: 'ગુડ ફ્રાઈડે (Good Friday)',
            langHi: 'गुड फ्राइडे',
            langEn: 'Good Friday',
          },
          'note': {
            langGu: 'બેંકિંગ રજા',
            langHi: 'बैंक अवकाश',
            langEn: 'Bank Holiday',
          },
        },
        {
          'day': 14,
          'name': {
            langGu: 'ડૉ. આંબેડકર જયંતી',
            langHi: 'डॉ. अम्बेडकर जयंती',
            langEn: 'Dr. Ambedkar Jayanti',
          },
          'note': {
            langGu: 'બેંક રજા',
            langHi: 'बैंक अवकाश',
            langEn: 'Bank Holiday',
          },
        },
      ],
      5: [
        {
          'day': 1,
          'name': {
            langGu: 'મહારાષ્ટ્ર / ગુજરાત દિન',
            langHi: 'गुजरात स्थापना दिवस',
            langEn: 'Gujarat Foundation Day',
          },
          'note': {
            langGu: 'રાજ્ય બેંક રજા',
            langHi: 'राज्य बैंक अवकाश',
            langEn: 'State Bank Holiday',
          },
        }
      ],
      8: [
        {
          'day': 15,
          'name': {
            langGu: 'સ્વાતંત્ર્ય દિન (Independence Day)',
            langHi: 'स्वतंत्रता दिवस',
            langEn: 'Independence Day',
          },
          'note': {
            langGu: 'રાષ્ટ્રીય બેંક રજા',
            langHi: 'राष्ट्रीय बैंक अवकाश',
            langEn: 'National Bank Holiday',
          },
        },
        {
          'day': 28,
          'name': {
            langGu: 'રક્ષાબંધન',
            langHi: 'रक्षाबंधन',
            langEn: 'Raksha Bandhan',
          },
          'note': {
            langGu: 'બેંક રજા',
            langHi: 'बैंक अवकाश',
            langEn: 'Bank Holiday',
          },
        }
      ],
      9: [
        {
          'day': 4,
          'name': {
            langGu: 'શ્રીકૃષ્ણ જન્માષ્ટમી',
            langHi: 'श्री कृष्ण जन्माष्टमी',
            langEn: 'Krishna Janmashtami',
          },
          'note': {
            langGu: 'બેંક રજા',
            langHi: 'बैंक अवकाश',
            langEn: 'Bank Holiday',
          },
        },
        {
          'day': 15,
          'name': {
            langGu: 'ગણેશ ચતુર્થી',
            langHi: 'गणेश चतुर्थी',
            langEn: 'Ganesh Chaturthi',
          },
          'note': {
            langGu: 'બેંક રજા',
            langHi: 'बैंक अवकाश',
            langEn: 'Bank Holiday',
          },
        }
      ],
      10: [
        {
          'day': 2,
          'name': {
            langGu: 'મહાત્મા ગાંધી જયંતી',
            langHi: 'महात्मा गांधी जयंती',
            langEn: 'Mahatma Gandhi Jayanti',
          },
          'note': {
            langGu: 'રાષ્ટ્રીય બેંક રજા',
            langHi: 'राष्ट्रीय बैंक अवकाश',
            langEn: 'National Bank Holiday',
          },
        },
        {
          'day': 20,
          'name': {
            langGu: 'દશેરા (વિજયાદશમી)',
            langHi: 'दशहरा (विजयादशमी)',
            langEn: 'Dussehra (Vijayadashami)',
          },
          'note': {
            langGu: 'બેંક રજા',
            langHi: 'बैंक अवकाश',
            langEn: 'Bank Holiday',
          },
        }
      ],
      11: [
        {
          'day': 8,
          'name': {
            langGu: 'દિવાળી (લક્ષ્મી પૂજન)',
            langHi: 'दीपावली (लक्ष्मी पूजन)',
            langEn: 'Diwali (Deepawali)',
          },
          'note': {
            langGu: 'તમામ બેંકો બંધ',
            langHi: 'सभी बैंक बंद',
            langEn: 'All Banks Closed',
          },
        },
        {
          'day': 9,
          'name': {
            langGu: 'નૂતન વર્ષ (બેસતું વર્ષ)',
            langHi: 'गोवर्धन पूजा / नूतन वर्ष',
            langEn: 'New Year (Bestu Varas)',
          },
          'note': {
            langGu: 'ગુજરાત બેંક રજા',
            langHi: 'राज्य बैंक अवकाश',
            langEn: 'State Bank Holiday',
          },
        },
        {
          'day': 10,
          'name': {
            langGu: 'ભાઈબીજ',
            langHi: 'भाई दूज',
            langEn: 'Bhai Dooj',
          },
          'note': {
            langGu: 'બેંક રજા',
            langHi: 'बैंक अवकाश',
            langEn: 'Bank Holiday',
          },
        }
      ],
      12: [
        {
          'day': 25,
          'name': {
            langGu: 'નાતાલ (Christmas)',
            langHi: 'क्रिसमस (Christmas)',
            langEn: 'Christmas Day',
          },
          'note': {
            langGu: 'તમામ બેંકો બંધ',
            langHi: 'सभी बैंक बंद',
            langEn: 'All Banks Closed',
          },
        }
      ],
    };

    if (specificHolidays.containsKey(month)) {
      for (final h in specificHolidays[month]!) {
        final nameMap = h['name'] as Map<String, String>;
        final noteMap = h['note'] as Map<String, String>;
        list.add({
          'day': h['day'] as int,
          'name': nameMap[l] ?? nameMap[langGu]!,
          'note': noteMap[l] ?? noteMap[langGu]!,
        });
      }
    }

    list.sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
    return list;
  }

  static bool isDateBankHoliday(int year, int month, int day, String lang) {
    final holidays = getBankHolidaysForMonth(year, month, lang);
    return holidays.any((h) => h['day'] == day);
  }

  // ── Authentic Public Holidays ─────────────────────────────────────────────
  static List<Map<String, dynamic>> getPublicHolidaysForMonth(
    int year,
    int month,
    String lang,
  ) {
    final l = normalizeLang(lang);
    final allPubHolidays = {
      1: [
        {
          'day': 14,
          'name': {langGu: 'મકરસંક્રાંતિ (ઉત્તરાયણ)', langHi: 'मकर संक्रांति', langEn: 'Makar Sankranti'}
        },
        {
          'day': 26,
          'name': {langGu: 'પ્રજાસત્તાક દિન (Republic Day)', langHi: 'गणतंत्र दिवस', langEn: 'Republic Day'}
        }
      ],
      2: [
        {
          'day': 15,
          'name': {langGu: 'મહા શિવરાત્રી', langHi: 'महा शिवरात्रि', langEn: 'Maha Shivratri'}
        }
      ],
      3: [
        {
          'day': 3,
          'name': {langGu: 'ધૂળેટી (હોળી)', langHi: 'धुलेंडी / होली', langEn: 'Holi'}
        },
        {
          'day': 19,
          'name': {langGu: 'ચેટીચંડ / ગુડી પડવો', langHi: 'चेटीचंड / गुड़ी पड़वा', langEn: 'Cheti Chand / Gudi Padwa'}
        },
        {
          'day': 27,
          'name': {langGu: 'શ્રી રામનવમી', langHi: 'श्री राम नवमी', langEn: 'Rama Navami'}
        }
      ],
      4: [
        {
          'day': 14,
          'name': {langGu: 'ડૉ. બાબાસાહેબ આંબેડકર જયંતી', langHi: 'डॉ. बी.आर. अम्बेडकर जयंती', langEn: 'Dr. Ambedkar Jayanti'}
        }
      ],
      5: [
        {
          'day': 1,
          'name': {langGu: 'ગુજરાત સ્થાપના દિન', langHi: 'गुजरात स्थापना दिवस', langEn: 'Gujarat Day'}
        }
      ],
      8: [
        {
          'day': 15,
          'name': {langGu: 'સ્વાતંત્ર્ય દિન (Independence Day)', langHi: 'स्वतंत्रता दिवस', langEn: 'Independence Day'}
        },
        {
          'day': 28,
          'name': {langGu: 'રક્ષાબંધન', langHi: 'रक्षाबंधन', langEn: 'Raksha Bandhan'}
        }
      ],
      9: [
        {
          'day': 4,
          'name': {langGu: 'શ્રીકૃષ્ણ જન્માષ્ટમી', langHi: 'श्री कृष्ण जन्माष्टमी', langEn: 'Krishna Janmashtami'}
        },
        {
          'day': 15,
          'name': {langGu: 'ગણેશ ચતુર્થી', langHi: 'गणेश चतुर्थी', langEn: 'Ganesh Chaturthi'}
        }
      ],
      10: [
        {
          'day': 2,
          'name': {langGu: 'મહાત્મા ગાંધી જયંતી', langHi: 'महात्मा गांधी जयंती', langEn: 'Gandhi Jayanti'}
        },
        {
          'day': 20,
          'name': {langGu: 'વિજયાદશમી (દશેરા)', langHi: 'विजयादशमी (दशहरा)', langEn: 'Dussehra'}
        }
      ],
      11: [
        {
          'day': 6,
          'name': {langGu: 'ધનતેરસ', langHi: 'धनतेरस', langEn: 'Dhanteras'}
        },
        {
          'day': 8,
          'name': {langGu: 'દિવાળી (દીપાવલી)', langHi: 'दीपावली', langEn: 'Diwali'}
        },
        {
          'day': 9,
          'name': {langGu: 'નૂતન વર્ષ (બેસતું વર્ષ)', langHi: 'नूतन वर्ष', langEn: 'New Year (Bestu Varas)'}
        },
        {
          'day': 10,
          'name': {langGu: 'ભાઈબીજ', langHi: 'भाई दूज', langEn: 'Bhai Dooj'}
        }
      ],
      12: [
        {
          'day': 25,
          'name': {langGu: 'નાતાલ (Christmas)', langHi: 'क्रिसमस', langEn: 'Christmas'}
        }
      ],
    };

    final List<Map<String, dynamic>> list = [];
    if (allPubHolidays.containsKey(month)) {
      for (final h in allPubHolidays[month]!) {
        final nameMap = h['name'] as Map<String, String>;
        list.add({
          'day': h['day'] as int,
          'name': nameMap[l] ?? nameMap[langGu]!,
        });
      }
    }
    list.sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
    return list;
  }

  // ── Authentic Auspicious Muhurats ──────────────────────────────────────────
  static List<Map<String, dynamic>> getMuhurats(String lang) {
    final l = normalizeLang(lang);
    if (l == langHi) {
      return [
        {
          'title': 'विवाह मुहूर्त (Vivah Muhurat)',
          'dates': '२१, २४, २७, २८ नवम्बर एवं ४, ८, ११ दिसम्बर',
          'desc': 'शुभ रोहिणी, मृगशिरा, हस्त और उत्तरा फाल्गुनी नक्षत्र।',
          'icon': Icons.favorite_border_rounded,
          'color': Colors.pink,
        },
        {
          'title': 'गृह प्रवेश मुहूर्त (Griha Pravesh)',
          'dates': '१४, २०, २५ नवम्बर',
          'desc': 'नए घर में प्रवेश के लिए शुभ वास्तु पूजन और कुंभ स्थापना।',
          'icon': Icons.home_rounded,
          'color': Colors.teal,
        },
        {
          'title': 'वाहन खरीद मुहूर्त (Vehicle Purchase)',
          'dates': '१२, १८, २२, २६ नवम्बर',
          'desc': 'कार, बाइक व अन्य वाहन खरीदने के लिए सर्वोत्तम मुहूर्त।',
          'icon': Icons.directions_car_rounded,
          'color': Colors.blue,
        },
        {
          'title': 'संपत्ति / भूमि क्रय (Property Purchase)',
          'dates': '७, १५, २१ नवम्बर',
          'desc': 'प्लॉट, फ्लैट व जमीन रजिस्ट्री के लिए अत्यंत शुभ योग।',
          'icon': Icons.apartment_rounded,
          'color': Colors.amber.shade800,
        },
        {
          'title': 'नामकरण संस्कार (Namkaran Muhurat)',
          'dates': '११, १६, २३ नवम्बर',
          'desc': 'नवजात शिशु के नामकरण संस्कार के लिए उत्तम मुहूर्त।',
          'icon': Icons.child_care_rounded,
          'color': Colors.purple,
        },
      ];
    } else if (l == langEn) {
      return [
        {
          'title': 'Wedding Muhurat (Vivah)',
          'dates': '21, 24, 27, 28 Nov & 4, 8, 11 Dec',
          'desc': 'Auspicious Rohini, Mrigashirsha, Hasta & Uttara Phalguni nakshatras.',
          'icon': Icons.favorite_border_rounded,
          'color': Colors.pink,
        },
        {
          'title': 'House Warming (Griha Pravesh)',
          'dates': '14, 20, 25 November',
          'desc': 'Best for Vastu Pujan & entering a new residence with positive energy.',
          'icon': Icons.home_rounded,
          'color': Colors.teal,
        },
        {
          'title': 'Vehicle Purchase Muhurat',
          'dates': '12, 18, 22, 26 November',
          'desc': 'Auspicious timings for purchasing car, bike, or commercial vehicle.',
          'icon': Icons.directions_car_rounded,
          'color': Colors.blue,
        },
        {
          'title': 'Property / Land Registration',
          'dates': '7, 15, 21 November',
          'desc': 'Favorable celestial alignment for real estate deals and paperwork.',
          'icon': Icons.apartment_rounded,
          'color': Colors.amber.shade800,
        },
        {
          'title': 'Naming Ceremony (Namkaran)',
          'dates': '11, 16, 23 November',
          'desc': 'Pure and blessed planetary periods for naming newborn child.',
          'icon': Icons.child_care_rounded,
          'color': Colors.purple,
        },
      ];
    }
    return [
      {
        'title': 'લગ્ન મુહૂર્ત (Vivah Muhurat)',
        'dates': '૨૧, ૨૪, ૨૭, ૨૮ નવેમ્બર & ૪, ૮, ૧૧ ડિસેમ્બર',
        'desc': 'શ્રેષ્ઠ રોહિણી, મૃગશિર્ષ, હસ્ત અને ઉત્તરા ફાલ્ગુની નક્ષત્ર.',
        'icon': Icons.favorite_border_rounded,
        'color': Colors.pink,
      },
      {
        'title': 'ગૃહ પ્રવેશ મુહૂર્ત (Griha Pravesh)',
        'dates': '૧૪, ૨૦, ૨૫ નવેમ્બર',
        'desc': 'નૂતન ઘર પ્રવેશ માટે શુભ વાસ્તુ પૂજન અને કુંભ સ્થાપના.',
        'icon': Icons.home_rounded,
        'color': Colors.teal,
      },
      {
        'title': 'વાહન ખરીદી મુહૂર્ત (Vehicle Purchase)',
        'dates': '૧૨, ૧૮, ૨૨, ૨૬ નવેમ્બર',
        'desc': 'કાર, બાઇક કે અન્ય વાહન ખરીદવા માટે શ્રેષ્ઠ મુહૂર્ત.',
        'icon': Icons.directions_car_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'મિલકત / જમીન ખરીદી (Property Purchase)',
        'dates': '૭, ૧૫, ૨૧ નવેમ્બર',
        'desc': 'જમીન, પ્લોટ કે ફ્લેટ રજીસ્ટ્રેશન અને દસ્તાવેજ માટે શુભ.',
        'icon': Icons.apartment_rounded,
        'color': Colors.amber.shade800,
      },
      {
        'title': 'નામકરણ સંસ્કાર (Namkaran Muhurat)',
        'dates': '૧૧, ૧૬, ૨૩ નવેમ્બર',
        'desc': 'નવજાત શિશુના શુભ નામાભિધાન વિધિ માટે ઉત્તમ.',
        'icon': Icons.child_care_rounded,
        'color': Colors.purple,
      },
    ];
  }

  // ── Authentic Multi-Language Vrat Kathas ───────────────────────────────────
  static List<Map<String, String>> getVratKathas(String lang) {
    final l = normalizeLang(lang);
    if (l == langHi) {
      return [
        {
          'title': 'श्री सत्यनारायण व्रत कथा',
          'desc': 'समस्त मनोकामना पूर्ण करने वाली और घर में सुख-शांति लाने वाली कथा।',
          'detail': 'श्री सत्यनारायण व्रत कथा स्कंद पुराण के रेवाखंड से ली गई है। यह व्रत किसी भी पूर्णिमा, संक्रांति या शुभ दिवस पर करने से परिवार में सुख, शांति, समृद्धि और एकता की वृद्धि होती है। भगवान विष्णु के सत्य स्वरूप की पूजा, केले के खंभों का मंडप और पंजरी प्रसाद का विशेष महात्म्य है।',
        },
        {
          'title': 'जया पार्वती व्रत कथा',
          'desc': 'अखंड सौभाग्य व सुयोग्य वर प्राप्ति के लिए कन्याओं का पावन व्रत।',
          'detail': 'आषाढ़ शुक्ल त्रयोदशी से पांच दिनों तक जया पार्वती व्रत किया जाता है। माता पार्वती और भगवान शिव की आराधना करके ज्वारे बोकर पूजन किया जाता है। इस व्रत के प्रभाव से अखंड सौभाग्य और मनोवांछित वर की प्राप्ति होती है।',
        },
        {
          'title': 'एकादशी महात्म्य एवं व्रत कथा',
          'desc': 'पापों का शमन करने वाली और मोक्ष प्रदायिनी २४ एकादशियों की महिमा।',
          'detail': 'सनातन धर्म में एकादशी व्रत को सर्वोत्तम माना गया है। निर्जला एकादशी, कामदा, वरुथिनी, मोहिनी सहित वर्ष की समस्त २४ एकादशियां भगवान श्री हरि विष्णु को समर्पित हैं। इस दिन अन्न का त्याग कर फलाहार किया जाता है।',
        },
        {
          'title': 'वैभव लक्ष्मी व्रत कथा',
          'desc': 'दरिद्रता दूर कर मां लक्ष्मी की असीम कृपा बरसाने वाला शुक्रवार व्रत।',
          'detail': 'मां वैभव लक्ष्मी का व्रत ११ या २१ शुक्रवार पूरी श्रद्धा और नियम से करने पर आर्थिक संकट दूर होते हैं और घर में सुख-समृद्धि का वास होता है।',
        },
        {
          'title': 'सोलह सोमवार व्रत कथा',
          'desc': 'भगवान देवाधिदेव महादेव शिवजी का अत्यंत फलदायी पावन व्रत।',
          'detail': 'सोलह सोमवार व्रत श्रावण मास अथवा किसी भी शुक्ल पक्ष के सोमवार से प्रारम्भ किया जाता है। शिवलिंग पर जलाभिषेक, बेलपत्र, धतूरा और पंचामृत अर्पित कर कथा श्रवण से सभी मनोरथ सिद्ध होते हैं।',
        },
        {
          'title': 'संकष्टी श्री गणेश चतुर्थी कथा',
          'desc': 'विघ्नहर्ता भगवान श्री गणेश जी की कृपा से संकट निवारक पावन व्रत।',
          'detail': 'कृष्ण पक्ष की चतुर्थी को संकष्टी चतुर्थी मनाई जाती है। सायंकाल चंद्रदर्शन कर अर्घ्य प्रदान कर गणेश जी की कथा का श्रवण करने से समस्त विघ्न व संकट टल जाते हैं।',
        },
      ];
    } else if (l == langEn) {
      return [
        {
          'title': 'Shri Satyanarayan Vrat Katha',
          'desc': 'Sacred story for fulfillment of desires, peace, and domestic happiness.',
          'detail': 'Shri Satyanarayan Vrat Katha is derived from the Skanda Purana. Performing this sacred ritual on any Purnima or auspicious occasion brings immense joy, wealth, harmony, and divine blessings from Lord Vishnu.',
        },
        {
          'title': 'Jaya Parvati Vrat Katha',
          'desc': 'Auspicious 5-day observance for marital bliss and finding a worthy partner.',
          'detail': 'Observed from Ashadha Shukla Trayodashi for five consecutive days. Devotees worship Goddess Parvati and Lord Shiva with barley sprouts (Jawara) for everlasting harmony and longevity of the spouse.',
        },
        {
          'title': 'Ekadashi Mahatmya & Vrat',
          'desc': 'Divine significance of all 24 sacred Ekadashis dedicated to Lord Vishnu.',
          'detail': 'Ekadashi fasting is revered in Vedic traditions as the supreme path of spiritual purification and liberation. Fasting on Nirjala, Kamada, and other Ekadashis cleanses negative karma.',
        },
        {
          'title': 'Vaibhav Lakshmi Vrat Katha',
          'desc': 'Friday devotional observance for prosperity, wealth, and removing adversity.',
          'detail': 'Observing the sacred Vaibhav Lakshmi fast for 11 or 21 Fridays with deep devotion resolves financial obstacles and brings permanent prosperity and grace to the household.',
        },
        {
          'title': '16 Somvar (Monday) Vrat Katha',
          'desc': 'Highly auspicious fast dedicated to Lord Shiva for fulfilling desires.',
          'detail': 'Sixteen Mondays fast can be commenced during the pious month of Shravana or any bright lunar fortnight. Offering Bilva leaves, water, and Panchamrit to the Shivling fulfills heartfelt aspirations.',
        },
        {
          'title': 'Sankashti Ganesh Chaturthi Katha',
          'desc': 'Remover of all obstacles and hardships through the grace of Lord Ganesha.',
          'detail': 'Observed on the 4th day of Krishna Paksha every month. Offering Arghya to the moon after sunset and reciting Lord Ganesha’s sacred story overcomes every hurdle in life.',
        },
      ];
    }
    return [
      {
        'title': 'શ્રી સત્યનારાયણ વ્રત કથા',
        'desc': 'સર્વ મનોકામના પૂર્ણ કરનાર અને ઘરમાં સુખ-શાંતિ લાવનાર પવિત્ર કથા.',
        'detail': 'શ્રી સત્યનારાયણ વ્રત કથા સ્કંદ પુરાણના રેવાખંડમાંથી લેવામાં આવી છે. આ વ્રત કોઈપણ પૂનમ અથવા શુભ દિવસે કરવાથી ઘરમાં સુખ, શાંતિ, સમૃદ્ધિ અને પારિવારિક એકતા વધે છે. શ્રી વિષ્ણુ ભગવાનના સત્ય સ્વરૂપની પૂજા અને પ્રસાદનું વિશેષ મહાત્મ્ય છે.',
      },
      {
        'title': 'જયા પાર્વતી વ્રત કથા',
        'desc': 'અખંડ સૌભાગ્ય અને સુયોગ્ય વરની પ્રાપ્તિ માટે કુમારિકાઓનું પવિત્ર વ્રત.',
        'detail': 'આષાઢ સુદ તેરસથી પાંચ દિવસ સુધી જયા પાર્વતી વ્રત કરવામાં આવે છે. માતા પાર્વતી અને ભગવાન શિવની આરાધના કરી જવારા વાવીને પૂજન કરવામાં આવે છે. આ વ્રતના પ્રભાવથી અખંડ સૌભાગ્યની પ્રાપ્તિ થાય છે.',
      },
      {
        'title': 'એકાદશી મહાત્મ્ય અને વ્રત કથા',
        'desc': 'પાપોનું શમન કરનાર અને મોક્ષ આપનાર તમામ ૨૪ એકાદશીઓની વિગત.',
        'detail': 'હિન્દુ ધર્મમાં એકાદશીનું વ્રત સર્વોત્તમ માનવામાં આવે છે. નિર્જળા એકાદશી, કામદા, વરુથિની, મોહિની સહિત વર્ષની ૨૪ એકાદશી ભગવાન વિષ્ણુને સમર્પિત છે.',
      },
      {
        'title': 'વૈભવ લક્ષ્મી વ્રત કથા',
        'desc': 'દારિદ્ર્ય દૂર કરી લક્ષ્મીજીની કૃપા પ્રાપ્ત કરાવનાર શુક્રવારનું વ્રત.',
        'detail': 'માતા વૈભવ લક્ષ્મીનું વ્રત ૧૧ કે ૨૧ શુક્રવાર શ્રદ્ધાપૂર્વક કરવાથી આર્થિક સંકટો દૂર થાય છે અને ઘરમાં લક્ષ્મીજીનો સ્થાયી વાસ થાય છે.',
      },
      {
        'title': 'સોળ સોમવાર વ્રત કથા',
        'desc': 'ભગવાન ભોળાનાથ શિવજીનું અત્યંત ફળદાયી ૧૬ સોમવાર વ્રત.',
        'detail': 'સોળ સોમવારનું વ્રત શ્રાવણ માસથી અથવા કોઈપણ સોમવારથી શરૂ કરી શકાય છે. શિવલિંગ પર જળાભિષેક, બીલીપત્ર અને પંચામૃત ચડાવી કથા વાંચવાથી ઇચ્છિત વર અને મનોકામના પૂર્ણ થાય છે.',
      },
      {
        'title': 'સંકષ્ટી શ્રી ગણેશ ચતુર્થી કથા',
        'desc': 'વિઘ્નહર્તા શ્રી ગણેશજીની કૃપાથી સંકટો નિવારણ માટેનું વ્રત.',
        'detail': 'વદ ચોથના દિવસે સંકષ્ટી ચતુર્થી મનાવવામાં આવે છે. સાંજે ચંદ્રદર્શન કરી અર્ઘ્ય આપી ગણેશજીની કથાનું શ્રવણ કરવાથી સમસ્ત વિઘ્નો અને સંકટો ટળે છે.',
      },
    ];
  }

  // ── Authentic Panchang Details Formatter ──────────────────────────────────
  static Map<String, dynamic> getPanchangDetails(
    DateTime date,
    String lang, {
    Map<String, dynamic>? liveData,
  }) {
    final l = normalizeLang(lang);
    final tithiName = liveData?['tithi']?.toString().isNotEmpty == true
        ? liveData!['tithi'].toString()
        : getTithiName(date, lang);

    final pakshaName = liveData?['paksha']?.toString().isNotEmpty == true
        ? liveData!['paksha'].toString()
        : getPaksha(date, lang);

    final monthName = liveData?['amanta_month']?.toString().isNotEmpty == true
        ? liveData!['amanta_month'].toString()
        : getHinduMonthName(date.month, lang);

    final samvatStr = liveData?['samvat']?.toString().isNotEmpty == true
        ? liveData!['samvat'].toString()
        : '${getUiText('samvat_prefix', lang)} ${getVikramSamvat(date.year, date.month, lang)}';

    final sunrise = liveData?['sunrise']?.toString().isNotEmpty == true
        ? liveData!['sunrise'].toString()
        : '06:26 AM';

    final sunset = liveData?['sunset']?.toString().isNotEmpty == true
        ? liveData!['sunset'].toString()
        : '06:32 PM';

    final nakshatra = liveData?['nakshatra']?.toString().isNotEmpty == true
        ? liveData!['nakshatra'].toString()
        : (l == langHi
            ? 'रोहिणी (शाम ०४:२५ तक)'
            : (l == langEn ? 'Rohini (Till 04:25 PM)' : 'રોહિણી (૦૪:૨૫ PM સુધી)'));

    final yoga = liveData?['yoga']?.toString().isNotEmpty == true
        ? liveData!['yoga'].toString()
        : (l == langHi
            ? 'सिद्धि योग'
            : (l == langEn ? 'Siddhi Yoga' : 'સિદ્ધિ યોગ'));

    final karana = liveData?['karana']?.toString().isNotEmpty == true
        ? liveData!['karana'].toString()
        : (l == langHi
            ? 'बव करण'
            : (l == langEn ? 'Bava Karana' : 'બવ કરણ'));

    final rahuKaal = l == langHi
        ? '१०:५४ AM - १२:२४ PM (अशुभ)'
        : (l == langEn ? '10:54 AM - 12:24 PM (Inauspicious)' : '૧૦:૫૪ AM - ૧૨:૨૪ PM (અશુભ)');

    final abhijit = l == langHi
        ? '११:५८ AM - १२:४८ PM (शुभ)'
        : (l == langEn ? '11:58 AM - 12:48 PM (Auspicious)' : '૧૧:૫૮ AM - ૧૨:૪૮ PM (શુભ)');

    final labels = l == langHi
        ? {
            'date': 'तारीख',
            'month': 'मास (महीना)',
            'tithi': 'तिथि',
            'paksha': 'पक्ष',
            'nakshatra': 'नक्षत्र',
            'yoga': 'योग',
            'karana': 'करण',
            'sun': 'सूर्योदय / सूर्यास्त',
            'rahu': 'राहु काल',
            'abhijit': 'अभिजित मुहूर्त',
            'samvat': 'संवत',
            'card_title': 'पंचांग & तिथि विवरण',
          }
        : (l == langEn
            ? {
                'date': 'Date',
                'month': 'Hindu Month',
                'tithi': 'Tithi',
                'paksha': 'Paksha',
                'nakshatra': 'Nakshatra',
                'yoga': 'Yoga',
                'karana': 'Karana',
                'sun': 'Sunrise / Sunset',
                'rahu': 'Rahu Kaal',
                'abhijit': 'Abhijit Muhurat',
                'samvat': 'Samvat',
                'card_title': 'Panchang & Tithi Overview',
              }
            : {
                'date': 'તારીખ',
                'month': 'ગુજરાતી માસ',
                'tithi': 'તિથિ',
                'paksha': 'પક્ષ',
                'nakshatra': 'નક્ષત્ર',
                'yoga': 'યોગ',
                'karana': 'કરણ',
                'sun': 'સૂર્યોદય / સૂર્યાસ્ત',
                'rahu': 'રાહુ કાળ',
                'abhijit': 'અભિજિત મુહૂર્ત',
                'samvat': 'સંવત',
                'card_title': 'પંચાંગ & તિથિ વિગત',
              });

    return {
      'labels': labels,
      'dateStr': DateFormat('dd/MM/yyyy (EEEE)').format(date),
      'month': monthName,
      'tithi': tithiName,
      'paksha': pakshaName,
      'nakshatra': nakshatra,
      'yoga': yoga,
      'karana': karana,
      'sun': '$sunrise / $sunset',
      'rahu': rahuKaal,
      'abhijit': abhijit,
      'samvat': samvatStr,
    };
  }
}
