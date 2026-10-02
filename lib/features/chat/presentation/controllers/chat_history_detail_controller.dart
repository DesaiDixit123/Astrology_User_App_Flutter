import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/astrologer_utils.dart';

class ChatHistoryDetailController extends GetxController {
  final _api = ApiService.instance;
  final RxList messages = [].obs;
  final RxBool isLoading = false.obs;
  final RxMap partner = {}.obs;
  final RxString sessionId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    if (args != null) {
      partner.value = Map<String, dynamic>.from(args['partner'] ?? {});
      sessionId.value = args['sessionId']?.toString() ?? '';
      if (sessionId.value.isNotEmpty) {
        fetchMessages();
      }
    }
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    final res = await _api.get('/customer/chat/messages/${sessionId.value}');
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      if (data is Map) {
        messages.value = List.from(data['messages'] ?? []);
        
        // Enrich partner details from session response
        if (data['session'] is Map) {
          final session = data['session'] as Map;
          final astro = session['astrologer_id'];
          if (astro is Map) {
            final details = astro['personal_details'] as Map? ?? {};
            final astroName = AstrologerUtils.getLocalizedAstrologerName(astro);
            final rawPic = details['profile_image'] as String? ?? 
                           astro['profile_pic'] as String? ?? 
                           astro['profile_image'] as String? ?? '';
            final pic = ApiConstants.resolveImage(rawPic);

            final currentName = partner['name']?.toString() ?? '';
            if (currentName.isEmpty || 
                currentName == 'Astrologers' || 
                currentName == 'Astrologer' || 
                currentName == 'જ્યોતિષીઓ') {
              if (astroName.isNotEmpty) {
                partner['name'] = astroName;
              }
            }
            if ((partner['profile_pic'] == null || partner['profile_pic'].toString().isEmpty) && pic.isNotEmpty) {
              partner['profile_pic'] = pic;
            }
          }
        }
      } else if (data is List) {
        messages.value = List.from(data);
      }
    }
  }
}
