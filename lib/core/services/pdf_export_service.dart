import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  static final PdfExportService _instance = PdfExportService._internal();
  factory PdfExportService() => _instance;
  PdfExportService._internal();

  /// Helper to get current locale string
  String _tr(String en, String hi, String gu) {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'gu') return gu;
    if (lang == 'hi') return hi;
    return en;
  }

  /// Helper to load Google Fonts with Gujarati & Devanagari fallbacks
  Future<pw.ThemeData> _getPdfTheme() async {
    try {
      final fontLatin = await PdfGoogleFonts.notoSansRegular();
      final fontLatinBold = await PdfGoogleFonts.notoSansBold();
      final fontGujarati = await PdfGoogleFonts.notoSansGujaratiRegular();
      final fontGujaratiBold = await PdfGoogleFonts.notoSansGujaratiBold();
      final fontDevanagari = await PdfGoogleFonts.notoSansDevanagariRegular();
      final fontDevanagariBold = await PdfGoogleFonts.notoSansDevanagariBold();

      return pw.ThemeData.withFont(
        base: fontLatin,
        bold: fontLatinBold,
        fontFallback: [
          fontGujarati,
          fontGujaratiBold,
          fontDevanagari,
          fontDevanagariBold,
        ],
      );
    } catch (_) {
      return pw.ThemeData.base();
    }
  }

  /// Format Panchang values safely without raw JSON toString output
  static String _formatPanchangValue(dynamic val) {
    if (val == null) return 'N/A';
    if (val is Map) {
      final name = val['name'] ?? val['tithi_name'] ?? val['yoga_name'] ?? val['karana_name'];
      if (name != null && name.toString().isNotEmpty) {
        return name.toString();
      }
      if (val['details'] != null && val['details'].toString().isNotEmpty) {
        return val['details'].toString();
      }
      final parts = <String>[];
      if (val['name'] != null) parts.add(val['name'].toString());
      if (val['type'] != null) parts.add('(${val['type']})');
      if (parts.isNotEmpty) return parts.join(' ');
    }
    final str = val.toString().trim();
    return str.isEmpty ? 'N/A' : str;
  }

  String _translateStatus(String val) {
    final v = val.toUpperCase().trim();
    if (v == 'PRESENT' || v == 'YES' || v == 'TRUE') {
      return _tr('PRESENT', 'उपस्थित', 'હાજર');
    }
    if (v == 'ABSENT' || v == 'NO' || v == 'FALSE') {
      return _tr('ABSENT', 'अनुपस्थित', 'ગેરહાજર');
    }
    return val;
  }

  String _translateYesNo(String val) {
    final v = val.toUpperCase().trim();
    if (v == 'YES' || v == 'TRUE' || v == 'HA') {
      return _tr('Yes', 'हाँ', 'હા');
    }
    if (v == 'NO' || v == 'FALSE' || v == 'NA') {
      return _tr('No', 'नहीं', 'ના');
    }
    return val;
  }

  String _translateAttribute(String attr) {
    switch (attr.toLowerCase()) {
      case 'varna':
        return _tr('Varna', 'वर्ण', 'વર્ણ');
      case 'vashya':
      case 'vasya':
        return _tr('Vashya', 'वश्य', 'વશ્ય');
      case 'tara':
        return _tr('Tara', 'तारा', 'તારા');
      case 'yoni':
        return _tr('Yoni', 'योनि', 'યોનિ');
      case 'maitri':
      case 'grahamaitri':
        return _tr('Maitri', 'मैत्री', 'મૈત્રી');
      case 'gana':
        return _tr('Gana', 'गण', 'ગણ');
      case 'bhakoot':
        return _tr('Bhakoot', 'भकूट', 'ભકૂટ');
      case 'nadi':
        return _tr('Nadi', 'नाड़ी', 'નાડી');
      default:
        return attr;
    }
  }

  /// Generate & Print/Save Free Janm Kundli PDF
  Future<void> exportKundliPdf(Map<String, dynamic> res) async {
    final theme = await _getPdfTheme();
    final pdf = pw.Document(theme: theme);

    final birthDetails = Map<String, dynamic>.from(
      res['basic_details'] ?? res['birth_details'] ?? res,
    );
    final panchangDetails = Map<String, dynamic>.from(
      res['panchang_details'] ?? res['panchang'] ?? {},
    );
    final planets = res['planets'] as List? ?? [];
    final dosha = res['dosha'] as Map? ?? {};

    final name = birthDetails['name']?.toString() ?? 'User';
    final dob = birthDetails['dob']?.toString() ?? 'N/A';
    final tob = birthDetails['tob']?.toString() ?? 'N/A';
    final place = birthDetails['place']?.toString() ?? 'N/A';
    final gender = birthDetails['gender']?.toString() ?? 'N/A';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(bottom: 16),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.brown, width: 2),
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'VEDIKVANI WELLNESS',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.brown800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _tr('JANAM KUNDLI REPORT', 'जन्म कुंडली रिपोर्ट', 'જન્મ કુંડળી રિપોર્ટ'),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange900,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Birth Details Section
            pw.Text(
              _tr('BIRTH DETAILS', 'जन्म विवरण', 'જન્મ વિગતો'),
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.brown800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                _buildPdfTableRow(_tr('Full Name', 'पूरा नाम', 'પૂરું નામ'), name),
                _buildPdfTableRow(_tr('Gender', 'लिंग', 'જાતિ'), gender),
                _buildPdfTableRow(_tr('Date of Birth', 'जन्म तिथि', 'જન્મ તારીખ'), dob),
                _buildPdfTableRow(_tr('Time of Birth', 'जन्म समय', 'જન્મ સમય'), tob),
                _buildPdfTableRow(_tr('Place of Birth', 'जन्म स्थान', 'જન્મ સ્થળ'), place),
                _buildPdfTableRow(_tr('Latitude', 'अक्षांश', 'અક્ષાંશ'), birthDetails['lat']?.toString() ?? 'N/A'),
                _buildPdfTableRow(_tr('Longitude', 'रेखांश', 'રેખાંશ'), birthDetails['lon']?.toString() ?? 'N/A'),
                _buildPdfTableRow(_tr('Rashi', 'राशि', 'રાશિ'), birthDetails['rasi']?.toString() ?? 'N/A'),
              ],
            ),
            pw.SizedBox(height: 20),

            // Panchang Details Section
            if (panchangDetails.isNotEmpty) ...[
              pw.Text(
                _tr('PANCHANG DETAILS', 'पंचांग विवरण', 'પંચાંગ વિગતો'),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.brown800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  _buildPdfTableRow(_tr('Tithi', 'तिथि', 'તિથિ'), _formatPanchangValue(panchangDetails['tithi'])),
                  _buildPdfTableRow(_tr('Yoga', 'योग', 'યોગ'), _formatPanchangValue(panchangDetails['yoga'])),
                  _buildPdfTableRow(_tr('Karana', 'करण', 'કરણ'), _formatPanchangValue(panchangDetails['karana'])),
                  _buildPdfTableRow(_tr('Sunrise', 'सूर्योदय', 'સૂર્યોદય'), _formatPanchangValue(panchangDetails['sunrise'])),
                  _buildPdfTableRow(_tr('Sunset', 'सूर्यास्त', 'સૂર્યાસ્ત'), _formatPanchangValue(panchangDetails['sunset'])),
                  _buildPdfTableRow(_tr('Day Lord', 'वार स्वामी', 'વાર સ્વામી'), _formatPanchangValue(panchangDetails['day_lord'])),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Planetary Positions
            if (planets.isNotEmpty) ...[
              pw.Text(
                _tr('PLANETARY POSITIONS', 'ग्रहों की स्थिति', 'ગ્રહોની સ્થિતિ'),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.brown800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.brown),
                cellAlignment: pw.Alignment.centerLeft,
                headers: [
                  _tr('Planet', 'ग्रह', 'ગ્રહ'),
                  _tr('Rashi', 'राशि', 'રાશિ'),
                  _tr('Nakshatra', 'नक्षत्र', 'નક્ષત્ર'),
                  _tr('House', 'भाव/स्थान', 'ભાવ/સ્થાન'),
                  _tr('Degree', 'अंश', 'અંશ'),
                ],
                data: planets.map((p) {
                  final pMap = (p as Map).cast<String, dynamic>();
                  return [
                    pMap['name']?.toString() ?? '',
                    pMap['rashi']?.toString() ?? '',
                    pMap['nakshatra']?.toString() ?? '',
                    pMap['house']?.toString() ?? '',
                    pMap['local_degree']?.toString() ?? '',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
            ],

            // Dosha Information
            if (dosha.isNotEmpty) ...[
              pw.Text(
                _tr('DOSHA ANALYSIS', 'दोष विश्लेषण', 'દોષ વિશ્લેષણ'),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.brown800,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildDoshaPdfBox(_tr('Mangal Dosha', 'मंगल दोष', 'મંગળ દોષ'), dosha['mangal']),
              pw.SizedBox(height: 6),
              _buildDoshaPdfBox(_tr('Kaalsarp Dosha', 'कालसर्प दोष', 'કાલસર્પ દોષ'), dosha['kaalsarp']),
              pw.SizedBox(height: 6),
              _buildDoshaPdfBox(_tr('Pitra Dosha', 'पितृ दोष', 'પિતૃ દોષ'), dosha['pitra']),
            ],

            pw.SizedBox(height: 30),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text(
                _tr(
                  'Report generated by Vedikvani Wellness Astrology App',
                  'वैदिकवाणी वेलनेस एस्ट्रोलॉजी ऐप द्वारा जनरेट की गई रिपोर्ट',
                  'વેદિકવાણી વેલનેસ એસ્ટ્રોલોજી એપ દ્વારા જનરેટ કરાયેલ રિપોર્ટ',
                ),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Kundli_${name.replaceAll(' ', '_')}.pdf',
    );
  }

  /// Generate & Print/Save Kundli Matching PDF
  Future<void> exportMatchmakingPdf(Map<String, dynamic> res) async {
    final theme = await _getPdfTheme();
    final pdf = pw.Document(theme: theme);

    final payload = res['payload'] as Map<String, dynamic>? ?? {};
    final ashtakoot = (res['ashtakoot'] as Map?)?.cast<String, dynamic>() ?? {};
    final manglik = (res['manglik'] as Map?)?.cast<String, dynamic>() ?? {};

    final boyDetails = Map<String, dynamic>.from(res['boy'] ?? res['boy_details'] ?? {});
    final girlDetails = Map<String, dynamic>.from(res['girl'] ?? res['girl_details'] ?? {});

    final boyName = boyDetails['name']?.toString().isNotEmpty == true
        ? boyDetails['name'].toString()
        : (payload['boy_name']?.toString() ?? 'Boy');
    final boyDobTob = boyDetails['dob_tob']?.toString() ??
        '${payload['boy_dob'] ?? ''} ${payload['boy_tob'] ?? ''}'.trim();
    final boyPlace = boyDetails['birth_place']?.toString() ??
        boyDetails['place']?.toString() ??
        payload['boy_place']?.toString() ??
        'N/A';

    final girlName = girlDetails['name']?.toString().isNotEmpty == true
        ? girlDetails['name'].toString()
        : (payload['girl_name']?.toString() ?? 'Girl');
    final girlDobTob = girlDetails['dob_tob']?.toString() ??
        '${payload['girl_dob'] ?? ''} ${payload['girl_tob'] ?? ''}'.trim();
    final girlPlace = girlDetails['birth_place']?.toString() ??
        girlDetails['place']?.toString() ??
        payload['girl_place']?.toString() ??
        'N/A';

    dynamic getVal(Map? map, String key) =>
        map?[key] ?? map?['score'] ?? map?['received_points'] ?? map?['received'];

    final rawGunas = [
      {
        'attr': 'Varna',
        'male': ashtakoot['varna']?['boy_varna']?.toString() ?? '-',
        'female': ashtakoot['varna']?['girl_varna']?.toString() ?? '-',
        'outOf': '1',
        'rec': getVal(ashtakoot['varna'] as Map?, 'varna')?.toString() ?? '0',
      },
      {
        'attr': 'Vashya',
        'male': ashtakoot['vasya']?['boy_vasya']?.toString() ?? '-',
        'female': ashtakoot['vasya']?['girl_vasya']?.toString() ?? '-',
        'outOf': '2',
        'rec': getVal(ashtakoot['vasya'] as Map?, 'vasya')?.toString() ?? '0',
      },
      {
        'attr': 'Tara',
        'male': ashtakoot['tara']?['boy_tara']?.toString() ?? '-',
        'female': ashtakoot['tara']?['girl_tara']?.toString() ?? '-',
        'outOf': '3',
        'rec': getVal(ashtakoot['tara'] as Map?, 'tara')?.toString() ?? '0',
      },
      {
        'attr': 'Yoni',
        'male': ashtakoot['yoni']?['boy_yoni']?.toString() ?? '-',
        'female': ashtakoot['yoni']?['girl_yoni']?.toString() ?? '-',
        'outOf': '4',
        'rec': getVal(ashtakoot['yoni'] as Map?, 'yoni')?.toString() ?? '0',
      },
      {
        'attr': 'Maitri',
        'male': ashtakoot['grahamaitri']?['boy_lord']?.toString() ?? '-',
        'female': ashtakoot['grahamaitri']?['girl_lord']?.toString() ?? '-',
        'outOf': '5',
        'rec': getVal(ashtakoot['grahamaitri'] as Map?, 'grahamaitri')?.toString() ?? '0',
      },
      {
        'attr': 'Gana',
        'male': ashtakoot['gana']?['boy_gana']?.toString() ?? '-',
        'female': ashtakoot['gana']?['girl_gana']?.toString() ?? '-',
        'outOf': '6',
        'rec': getVal(ashtakoot['gana'] as Map?, 'gana')?.toString() ?? '0',
      },
      {
        'attr': 'Bhakoot',
        'male': ashtakoot['bhakoot']?['boy_rasi_name']?.toString() ?? '-',
        'female': ashtakoot['bhakoot']?['girl_rasi_name']?.toString() ?? '-',
        'outOf': '7',
        'rec': getVal(ashtakoot['bhakoot'] as Map?, 'bhakoot')?.toString() ?? '0',
      },
      {
        'attr': 'Nadi',
        'male': ashtakoot['nadi']?['boy_nadi']?.toString() ?? '-',
        'female': ashtakoot['nadi']?['girl_nadi']?.toString() ?? '-',
        'outOf': '8',
        'rec': getVal(ashtakoot['nadi'] as Map?, 'nadi')?.toString() ?? '0',
      },
    ];

    num totalRec = 0;
    for (final g in rawGunas) {
      totalRec += num.tryParse(g['rec']!) ?? 0;
    }
    final scoreDisplay = ashtakoot['score']?.toString() ??
        ashtakoot['total_score']?.toString() ??
        totalRec.toString();

    final rajjuDosha = _translateYesNo(ashtakoot['rajju_dosha']?.toString() ?? 'No');
    final vedhaDosha = _translateYesNo(ashtakoot['vedha_dosha']?.toString() ?? 'No');
    final manglikMatch = _translateYesNo(
      ashtakoot['manglik_match']?.toString() ??
          manglik['manglik_match']?.toString() ??
          'Yes',
    );
    final recommendation = res['recommendation']?.toString() ??
        _tr(
          'Kundali matching completed successfully.',
          'कुंडली मिलान सफलतापूर्वक संपन्न हुआ।',
          'કુંડળી મિલન સફળતાપૂર્વક પૂર્ણ થયું.',
        );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(bottom: 16),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.purple800, width: 2),
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'VEDIKVANI WELLNESS',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _tr('KUNDALI MATCHING REPORT', 'कुंडली मिलान रिपोर्ट', 'કુંડળી મિલન રિપોર્ટ'),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Boy & Girl Side by Side Tables
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _tr("BOY'S DETAILS", "लड़के का विवरण", "છોકરાની વિગતો"),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey300),
                        children: [
                          _buildPdfTableRow(_tr('Name', 'नाम', 'નામ'), boyName),
                          _buildPdfTableRow(_tr('Date & Time', 'तिथि एवं समय', 'તારીખ અને સમય'), boyDobTob),
                          _buildPdfTableRow(_tr('Place of Birth', 'जन्म स्थान', 'જન્મ સ્થળ'), boyPlace),
                          _buildPdfTableRow(_tr('Rashi', 'राशि', 'રાશિ'), boyDetails['janam_rashi']?.toString() ?? 'N/A'),
                          _buildPdfTableRow(_tr('Nakshatra', 'नक्षत्र', 'નક્ષત્ર'), boyDetails['nakshatra']?.toString() ?? 'N/A'),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _tr("GIRL'S DETAILS", "लड़की का विवरण", "છોકરીની વિગતો"),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.pink800,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey300),
                        children: [
                          _buildPdfTableRow(_tr('Name', 'नाम', 'નામ'), girlName),
                          _buildPdfTableRow(_tr('Date & Time', 'तिथि एवं समय', 'તારીખ અને સમય'), girlDobTob),
                          _buildPdfTableRow(_tr('Place of Birth', 'जन्म स्थान', 'જન્મ સ્થળ'), girlPlace),
                          _buildPdfTableRow(_tr('Rashi', 'राशि', 'રાશિ'), girlDetails['janam_rashi']?.toString() ?? 'N/A'),
                          _buildPdfTableRow(_tr('Nakshatra', 'नक्षत्र', 'નક્ષત્ર'), girlDetails['nakshatra']?.toString() ?? 'N/A'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Score Summary Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.purple200),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildScorePdfColumn(_tr('Guna Milan Score', 'गुण मिलान स्कोर', 'ગુણ મિલન સ્કોર'), '$scoreDisplay / 36'),
                  _buildScorePdfColumn(_tr('Rajju Dosha', 'रज्जु दोष', 'રજ્જુ દોષ'), rajjuDosha),
                  _buildScorePdfColumn(_tr('Vedha Dosha', 'वेध दोष', 'વેધ દોષ'), vedhaDosha),
                  _buildScorePdfColumn(_tr('Manglik Match', 'मांगलिक मिलान', 'માંગલિક મિલન'), manglikMatch),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Ashtakoot Guna Breakdown Table
            pw.Text(
              _tr('ASHTAKOOT GUNAS BREAKDOWN', 'अष्टकूट गुण मिलान', 'અષ્ટકૂટ ગુણ મિલન'),
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.purple700),
              cellAlignment: pw.Alignment.centerLeft,
              headers: [
                _tr('Attribute', 'कूट/गुण', 'કૂટ/ગુણ'),
                _tr('Male', 'पुरुष', 'પુરુષ'),
                _tr('Female', 'स्त्री', 'સ્ત્રી'),
                _tr('Out of', 'कुल', 'કુલ'),
                _tr('Received', 'प्राप्त', 'પ્રાપ્ત'),
              ],
              data: rawGunas.map((g) {
                return [
                  _translateAttribute(g['attr']!),
                  g['male']!,
                  g['female']!,
                  g['outOf']!,
                  g['rec']!,
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),

            // Recommendation Summary
            pw.Text(
              _tr('MATCH ANALYSIS & RECOMMENDATION', 'मिलान विश्लेषण एवं सुझाव', 'મિલન વિશ્લેષણ અને ભલામણ'),
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple900,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Text(
                recommendation,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey800,
                ),
              ),
            ),

            pw.SizedBox(height: 30),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text(
                _tr(
                  'Report generated by Vedikvani Wellness Astrology App',
                  'वैदिकवाणी वेलनेस एस्ट्रोलॉजी ऐप द्वारा जनरेट की गई रिपोर्ट',
                  'વેદિકવાણી વેલનેસ એસ્ટ્રોલોજી એપ દ્વારા જનરેટ કરાયેલ રિપોર્ટ',
                ),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Matching_${boyName}_${girlName}.pdf',
    );
  }

  pw.Widget _buildDoshaPdfBox(String title, dynamic doshaData) {
    if (doshaData == null) return pw.SizedBox();

    final isPresent = doshaData['is_dosha_present'] == true ||
        doshaData['is_pitra_dosha_present'] == true ||
        doshaData['manglik_present'] == true ||
        doshaData['manglik_status'] == true;

    final statusText = isPresent ? _tr("PRESENT", "उपस्थित", "હાજર") : _tr("ABSENT", "अनुपस्थित", "ગેરહાજર");
    final text = doshaData['bot_response']?.toString() ?? doshaData.toString();

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: isPresent ? PdfColors.red50 : PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: isPresent ? PdfColors.red200 : PdfColors.green200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$title: $statusText',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: isPresent ? PdfColors.red900 : PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildScorePdfColumn(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.purple900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }
}
