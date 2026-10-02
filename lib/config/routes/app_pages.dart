import 'package:get/get.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/splash/presentation/controllers/splash_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/astrologers/presentation/pages/astrologer_list_page.dart';
import '../../features/astrologers/presentation/pages/astrologer_detail_page.dart';
import '../../features/astrologers/presentation/controllers/astrologer_controller.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/wallet/presentation/pages/recharge_page.dart';
import '../../features/wallet/presentation/controllers/wallet_controller.dart';
import '../../features/profile/presentation/pages/order_history_page.dart';
import '../../features/profile/presentation/pages/transactions_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/help_support_page.dart';
import '../../features/profile/presentation/pages/terms_page.dart';
import '../../features/profile/presentation/pages/privacy_policy_page.dart';
import '../../features/services/presentation/pages/kundli_page.dart';
import '../../features/services/presentation/pages/horoscope_page.dart';
import '../../features/services/presentation/pages/horoscope_detail_page.dart';
import '../../features/services/presentation/pages/panchang_page.dart';
import '../../features/services/presentation/pages/calendar_page.dart';
import '../../features/services/presentation/pages/matchmaking_page.dart';
import '../../features/services/presentation/controllers/service_controller.dart';
import '../../features/services/presentation/controllers/kundli_controller.dart';
import '../../features/services/presentation/controllers/matchmaking_controller.dart';
import '../../features/shop/presentation/pages/shop_page.dart';
import '../../features/shop/presentation/pages/product_detail_page.dart';
import '../../features/shop/presentation/pages/cart_page.dart';
import '../../features/shop/presentation/pages/wishlist_page.dart';
import '../../features/epooja/presentation/pages/epooja_page.dart';
import '../../features/epooja/presentation/pages/puja_details_page.dart';
import '../../features/epooja/presentation/pages/select_astrologer_page.dart';
import '../../features/epooja/presentation/pages/puja_checkout_page.dart';
import '../../features/astrologers/presentation/pages/call_list_page.dart';
import '../../features/astrologers/presentation/pages/chat_list_page.dart';
import '../../features/astrologers/presentation/pages/live_list_page.dart';
import '../../features/astrologers/presentation/controllers/call_history_controller.dart';
import '../../features/blogs/presentation/pages/blogs_page.dart';
import '../../features/blogs/presentation/pages/blog_detail_page.dart';
import '../../features/blogs/presentation/controllers/blog_controller.dart';
import '../../features/shop/presentation/controllers/shop_controller.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/controllers/chat_controller.dart';
import '../../features/chat/presentation/controllers/chat_list_controller.dart';
import '../../features/shop/presentation/pages/shop_order_history_page.dart';
import '../../features/shop/presentation/pages/shop_order_detail_page.dart';
import '../../features/calls/presentation/pages/voice_call_page.dart';
import '../../features/calls/presentation/pages/video_call_page.dart';
import '../../features/calls/presentation/pages/ai_voice_assistant_page.dart';
import '../../features/calls/presentation/controllers/call_controller.dart';
import '../../features/chat/presentation/pages/chat_history_page.dart';
import '../../features/chat/presentation/controllers/chat_history_controller.dart';
import '../../features/chat/presentation/pages/chat_history_detail_page.dart';
import '../../features/chat/presentation/controllers/chat_history_detail_controller.dart';
import '../../features/services/presentation/controllers/puja_controller.dart';
import '../../features/epooja/presentation/pages/puja_history_page.dart';
import '../../features/live/presentation/controllers/live_controller.dart';
import '../../features/live/presentation/pages/live_viewer_page.dart';
import '../../features/notifications/presentation/pages/notification_list_page.dart';
import '../../features/notifications/presentation/controllers/notification_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        Get.put<SplashController>(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.put<AuthController>(AuthController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.put<AuthController>(AuthController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.put<AuthController>(AuthController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
        Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
        Get.lazyPut<AstrologerController>(() => AstrologerController(), fenix: true);
        Get.lazyPut<LiveController>(() => LiveController(), fenix: true);
        Get.lazyPut<ChatHistoryController>(() => ChatHistoryController(), fenix: true);
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.astrologerList,
      page: () => const AstrologerListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AstrologerController>(() => AstrologerController());
      }),
    ),
    GetPage(
      name: AppRoutes.astrologerDetail,
      page: () => const AstrologerDetailPage(),
      binding: BindingsBuilder(() {
        // Use Get.put (not lazyPut) so the controller is always freshly created
        // with the route arguments available in onInit()
        Get.put<AstrologerController>(AstrologerController());
      }),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
        Get.lazyPut<WalletController>(() => WalletController());
      }),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
        Get.lazyPut<WalletController>(() => WalletController());
      }),
    ),
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WalletController>(() => WalletController());
      }),
    ),
    GetPage(
      name: AppRoutes.recharge,
      page: () => const RechargePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WalletController>(() => WalletController());
      }),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderHistoryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(name: AppRoutes.transactions, page: () => const TransactionsPage()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsPage()),
    GetPage(name: AppRoutes.help, page: () => const HelpSupportPage()),
    // GetPage(
    //   name: AppRoutes.savedAstrologers,
    //   page: () => const SavedAstrologersPage(),
    // ),
    GetPage(
      name: AppRoutes.kundli,
      page: () => KundliPage(),
      binding: BindingsBuilder(() {
        Get.put<KundliController>(KundliController());
      }),
    ),
    GetPage(
      name: AppRoutes.horoscope,
      page: () => const HoroscopePage(),
      binding: BindingsBuilder(() {
        Get.put<ServiceController>(ServiceController());
      }),
    ),
    GetPage(
      name: AppRoutes.horoscopeDetail,
      page: () => const HoroscopeDetailPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ServiceController>()) {
          Get.put<ServiceController>(ServiceController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.panchang,
      page: () => const PanchangPage(),
      binding: BindingsBuilder(() {
        Get.put<ServiceController>(ServiceController());
      }),
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => const CalendarPage(),
    ),
    GetPage(
      name: AppRoutes.matchmaking,
      page: () => const MatchmakingPage(),
      binding: BindingsBuilder(() {
        Get.put<MatchmakingController>(MatchmakingController());
      }),
    ),
    GetPage(
      name: AppRoutes.shop,
      page: () => const ShopPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ShopController>(() => ShopController());
      }),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
    ),
    GetPage(name: AppRoutes.cart, page: () => const CartPage()),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ShopController>()) {
          Get.lazyPut<ShopController>(() => ShopController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.epooja,
      page: () => const EPoojaPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PujaController());
      }),
    ),
    GetPage(
      name: AppRoutes.pujaDetails,
      page: () => PujaDetailsPage(pujaId: Get.arguments ?? ''),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PujaController>()) {
          Get.lazyPut(() => PujaController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.selectPujaAstrologer,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return SelectAstrologerPage(
          puja: args['puja'],
          package: args['package'],
        );
      },
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AstrologerController>()) {
          Get.lazyPut(() => AstrologerController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.pujaCheckout,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return PujaCheckoutPage(
          puja: args['puja'],
          package: args['package'],
          astrologer: args['astrologer'],
          mode: args['mode'] ?? 'online',
        );
      },
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PujaController>()) {
          Get.lazyPut(() => PujaController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.callList,
      page: () => const CallListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CallHistoryController>(() => CallHistoryController());
      }),
    ),
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatListController>(() => ChatListController());
      }),
    ),
    GetPage(
      name: AppRoutes.chatHistory,
      page: () => const ChatHistoryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatHistoryController>(() => ChatHistoryController());
      }),
    ),
    GetPage(
      name: AppRoutes.chatHistoryDetail,
      page: () => const ChatHistoryDetailPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatHistoryDetailController>(
          () => ChatHistoryDetailController(),
        );
      }),
    ),
    GetPage(name: AppRoutes.liveList, page: () => const LiveListPage()),
    GetPage(
      name: AppRoutes.liveViewer,
      page: () => const LiveViewerPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LiveController>(() => LiveController());
      }),
    ),
    GetPage(
      name: AppRoutes.blogs,
      page: () => const BlogsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BlogController>(() => BlogController());
      }),
    ),
    GetPage(name: AppRoutes.blogDetail, page: () => const BlogDetailPage()),
    GetPage(
      name: AppRoutes.shopOrders,
      page: () => const ShopOrderHistoryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ShopController>(() => ShopController());
      }),
    ),
    GetPage(
      name: AppRoutes.shopOrderDetail,
      page: () => const ShopOrderDetailPage(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatController>(() => ChatController());
        Get.lazyPut<WalletController>(() => WalletController());
      }),
    ),
    GetPage(
      name: AppRoutes.voiceCall,
      page: () => const VoiceCallPage(),
      binding: BindingsBuilder(() {
        Get.put<CallController>(CallController());
      }),
    ),
    GetPage(
      name: AppRoutes.videoCall,
      page: () => const VideoCallPage(),
      binding: BindingsBuilder(() {
        Get.put<CallController>(CallController());
      }),
    ),
    GetPage(
      name: AppRoutes.aiVoiceAssistant,
      page: () => const AIVoiceAssistantPage(),
    ),
    GetPage(
      name: AppRoutes.pujaHistory,
      page: () => const PujaHistoryPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PujaController>()) {
          Get.lazyPut(() => PujaController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.pujaHistoryDetail,
      page: () => PujaHistoryDetailPage(order: Get.arguments),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PujaController>()) {
          Get.lazyPut(() => PujaController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationListPage(),
      binding: BindingsBuilder(() {
        Get.put<NotificationController>(NotificationController());
      }),
    ),
    GetPage(
      name: AppRoutes.terms,
      page: () => const TermsPage(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
    ),
  ];
}
