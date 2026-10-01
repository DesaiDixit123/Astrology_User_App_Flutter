import 'package:get/get.dart';
import 'name_transliteration_utils.dart';

class AstrologerUtils {
  /// Safely extracts the astrologer's name from any API JSON structure and transliterates it to active language script.
  static String getLocalizedAstrologerName(dynamic rawData) {
    if (rawData is! Map) {
      final fallback = 'astrologer'.tr;
      return (fallback.isNotEmpty && fallback != 'astrologer') ? fallback : 'જ્યોતિષી';
    }
    final astro = Map<String, dynamic>.from(rawData);

    // List of candidate name keys
    final candidateKeys = [
      'name',
      'display_name',
      'displayName',
      'full_name',
      'fullName',
      'astrologer_name',
      'astrologerName',
      'title',
    ];

    // Helper to try extraction from a map
    String? tryMap(Map map) {
      for (final key in candidateKeys) {
        final val = map[key]?.toString().trim();
        if (val != null && val.isNotEmpty && val != 'null' && val != 'undefined') {
          return val;
        }
      }
      return null;
    }

    String? foundName;

    // 1. Nested personal_details (authoritative astrologer profile name)
    if (astro['personal_details'] is Map) {
      foundName = tryMap(astro['personal_details'] as Map);
    }

    // 2. Nested astrologer_id map (e.g. live sessions, calls, or chat history)
    if (foundName == null && astro['astrologer_id'] is Map) {
      final astroIdMap = astro['astrologer_id'] as Map;
      if (astroIdMap['personal_details'] is Map) {
        foundName = tryMap(astroIdMap['personal_details'] as Map);
      }
      if (foundName == null) {
        foundName = tryMap(astroIdMap);
      }
    }

    // 3. Nested partner map
    if (foundName == null && astro['partner'] is Map) {
      final partner = astro['partner'] as Map;
      if (partner['personal_details'] is Map) {
        foundName = tryMap(partner['personal_details'] as Map);
      }
      if (foundName == null) {
        foundName = tryMap(partner);
      }
    }

    // 4. Nested user map
    if (foundName == null && astro['user'] is Map) {
      foundName = tryMap(astro['user'] as Map);
    }

    // 5. Direct top-level map (legacy fallback)
    if (foundName == null) {
      foundName = tryMap(astro);
    }

    // If a non-empty name string was found from ANY structure:
    if (foundName != null && foundName.trim().isNotEmpty) {
      final localized = NameTransliterationUtils.toLocalizedName(foundName);
      return localized.trim().isNotEmpty ? localized : foundName;
    }

    // Fallback if no name exists anywhere in JSON
    final fallback = 'astrologer'.tr;
    return (fallback.isNotEmpty && fallback != 'astrologer') ? fallback : 'જ્યોતિષી';
  }

  /// Safely extracts the astrologer's specialization or skills and localizes it cleanly.
  static String getLocalizedAstrologerSpecialization(dynamic rawData) {
    if (rawData is! Map) {
      return 'astrologer'.tr;
    }
    final astro = Map<String, dynamic>.from(rawData);

    // 1. Check skills list
    final skills = astro['skills'];
    if (skills is List && skills.isNotEmpty) {
      final skillStr = skills.first.toString().trim();
      if (skillStr.isNotEmpty) {
        return NameTransliterationUtils.toLocalizedSpecialization(skillStr);
      }
    }

    // 2. Check specialization fields
    final candidateKeys = [
      'specialization',
      'skill',
      'category',
      'primary_skill',
      'main_skill',
    ];

    for (final key in candidateKeys) {
      final val = astro[key]?.toString().trim();
      if (val != null && val.isNotEmpty && val != 'null' && val != 'undefined') {
        return NameTransliterationUtils.toLocalizedSpecialization(val);
      }
    }

    return 'astrologer'.tr;
  }

  /// Safely extracts the astrologer's bio/about text from any nested API JSON structure (including other_details.long_bio, biography, etc.).
  static String getLocalizedAstrologerBio(dynamic rawData) {
    if (rawData is! Map) {
      return 'no_description'.tr;
    }
    final astro = Map<String, dynamic>.from(rawData);

    final candidateKeys = [
      'long_bio',
      'bio',
      'biography',
      'about',
      'about_me',
      'aboutMe',
      'description',
      'short_bio',
      'details',
    ];

    String? tryMap(Map map) {
      for (final key in candidateKeys) {
        final val = map[key]?.toString().trim();
        if (val != null && val.isNotEmpty && val != 'null' && val != 'undefined') {
          return val;
        }
      }
      return null;
    }

    // 1. Direct top-level map
    String? foundBio = tryMap(astro);

    // 2. Nested other_details map
    if (foundBio == null && astro['other_details'] is Map) {
      foundBio = tryMap(astro['other_details'] as Map);
    }

    // 3. Nested personal_details map
    if (foundBio == null && astro['personal_details'] is Map) {
      foundBio = tryMap(astro['personal_details'] as Map);
    }

    // 4. Nested partner map
    if (foundBio == null && astro['partner'] is Map) {
      final partner = astro['partner'] as Map;
      foundBio = tryMap(partner);
      if (foundBio == null && partner['other_details'] is Map) {
        foundBio = tryMap(partner['other_details'] as Map);
      }
    }

    // 5. Nested astrologer_id map
    if (foundBio == null && astro['astrologer_id'] is Map) {
      final astroIdMap = astro['astrologer_id'] as Map;
      foundBio = tryMap(astroIdMap);
      if (foundBio == null && astroIdMap['other_details'] is Map) {
        foundBio = tryMap(astroIdMap['other_details'] as Map);
      }
    }

    if (foundBio != null && foundBio.trim().isNotEmpty) {
      return foundBio;
    }

    return 'no_description'.tr;
  }

  /// Safely extracts the astrologer's profile image from any nested API JSON structure.
  static String getAstrologerImage(dynamic rawData) {
    if (rawData is! Map) return '';
    final astro = Map<String, dynamic>.from(rawData);

    final candidateKeys = [
      'profile_pic',
      'profile_image',
      'profilePic',
      'profileImage',
      'image',
      'avatar',
      'photo',
    ];

    String? tryMap(Map map) {
      for (final key in candidateKeys) {
        final val = map[key]?.toString().trim();
        if (val != null && val.isNotEmpty && val != 'null' && val != 'undefined') {
          return val;
        }
      }
      return null;
    }

    // 1. Nested personal_details
    if (astro['personal_details'] is Map) {
      final img = tryMap(astro['personal_details'] as Map);
      if (img != null) return img;
    }

    // 2. Nested astrologer_id map
    if (astro['astrologer_id'] is Map) {
      final aMap = astro['astrologer_id'] as Map;
      if (aMap['personal_details'] is Map) {
        final img = tryMap(aMap['personal_details'] as Map);
        if (img != null) return img;
      }
      final img = tryMap(aMap);
      if (img != null) return img;
    }

    // 3. Nested partner map
    if (astro['partner'] is Map) {
      final pMap = astro['partner'] as Map;
      if (pMap['personal_details'] is Map) {
        final img = tryMap(pMap['personal_details'] as Map);
        if (img != null) return img;
      }
      final img = tryMap(pMap);
      if (img != null) return img;
    }

    // 4. Root
    final img = tryMap(astro);
    return img ?? '';
  }
}
