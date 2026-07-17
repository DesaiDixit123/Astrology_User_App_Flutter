class ApiConstants {
  // ── Base URL (Dynamically Resolvable) ─────
  //static String baseUrl = 'http://10.0.2.2:3050';

  //static String baseUrl = 'http://192.168.1.6:3050';
  static String baseUrl = 'https://api.vedikvani.com/';

  static void updateBaseUrl(String url) {
    if (url.startsWith('http')) {
      baseUrl = url;
    } else {
      baseUrl = 'http://$url:3050';
    }
  }

  static const String imageBaseUrl =
      'https://hrms-khushi.s3.ap-south-1.amazonaws.com';

  static String resolveImage(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$imageBaseUrl/$path'
        .replaceAll('//', '/')
        .replaceFirst('https:/', 'https://');
  }

  // ── Customer Auth ─────────────────────────────────────────
  static const String sendOtp = '/customer/send-otp';
  static const String verifyOtp = '/customer/verify-otp';
  static const String register = '/customer/register';

  // ── Home ──────────────────────────────────────────────────
  static const String home = '/customer/home';
  static const String banners = '/customer/banners';
  static const String feedbacks = '/customer/feedbacks';
  static const String videos = '/customer/videos';

  // ── Astrologers ───────────────────────────────────────────
  static const String astrologers = '/customer/astrologers';
  static const String topAstrologers = '/customer/astrologers/top';
  static const String liveAstrologers = '/customer/astrologers/live';
  static const String follow = '/customer/follow';
  static const String following = '/customer/following';
  static const String report = '/customer/report';

  // ── Blogs ─────────────────────────────────────────────────
  static const String blogs = '/customer/blogs/list';
  static const String blogLike = '/customer/blog/like';
  static const String blogReport = '/customer/blog/report';

  // ── Calls ─────────────────────────────────────────────────
  static const String initiateCall = '/customer/call/initiate';
  static const String callQueue = '/customer/call/queue';
  static const String endCall = '/customer/call/end';

  // ── Live Streaming ────────────────────────────────────────
  static const String liveStreams = '/customer/live';
  static const String liveGifts = '/customer/live/gifts';
  static const String joinLive = '/customer/live/join';
  static const String sendGift = '/customer/live/gift';
  static const String liveCallRequest = '/customer/live/call-request';

  // ── Services ─────────────────────────────────────────────
  static const String serviceCategories = '/customer/service-categories';
  static const String bookService = '/customer/service/book';
  static const String myServiceOrders = '/customer/service-orders';

  // ── Profile ───────────────────────────────────────────────
  static const String profile = '/customer/profile';
  static const String orders = '/customer/orders';
  static const String submitReview = '/customer/review';
  static const String freeChatSettings = '/customer/free-chat/settings';

  // ── Wallet ────────────────────────────────────────────────
  static const String walletBalance = '/customer/wallet/balance';
  static const String walletTransactions = '/customer/wallet/transactions';
  static const String rechargeOptions = '/customer/wallet/settings';
  static const String createRechargeOrder = '/customer/wallet/recharge';
  static const String verifyRecharge = '/customer/wallet/recharge/verify';

  // ── Predictions ───────────────────────────────────────────
  static const String horoscope = '/customer/horoscope';
  static const String horoscopeSigns = '/customer/horoscope-signs';
  static const String panchang = '/customer/panchang';
  static const String panchangToday = '/customer/panchang/today';
  static const String panchangTomorrow = '/customer/panchang/tomorrow';
  static const String panchangByDate = '/customer/panchang/by-date';
  static const String panchangBrief = '/customer/panchang/brief';
  static const String kundli = '/customer/kundli/generate';
  static const String savedKundlis = '/customer/kundli/saved';
  static const String kundliPdf = '/customer/kundli/pdf';
  static const String kundliMatch = '/customer/matching/basic-details';
  static const String matchingHistory = '/customer/matching/history';
  static const String numerology = '/customer/numerology';

  // ── Astroshop ──────────────────────────────────────────────
  static const String shopCategories = '/customer/astroshop/categories';
  static const String shopProducts = '/customer/astroshop/products';
  static const String shopProductDetail =
      '/customer/astroshop/product'; // + /:id
  static const String placeOrder = '/customer/astroshop/order';
  static const String myOrders = '/customer/astroshop/my-orders';
  static const String shopRecommendations =
      '/customer/astroshop/recommendations';

  // ── Puja ─────────────────────────────────────────────────
  static const String pujaCategories = '/customer/puja/categories';
  static const String pujaSubcategories =
      '/customer/puja/subcategories'; // + /:categoryId
  static const String pujaList = '/customer/puja/list'; // + /:categoryId
  static const String pujaSublist =
      '/customer/puja/sublist'; // + /:subCategoryId
  static const String pujaDetails = '/customer/puja/details'; // + /:pujaId
  static const String pujaSearch = '/customer/puja/search';
  static const String pujaFaqs = '/customer/puja/faqs';
  static const String pujaPackages = '/customer/puja/packages'; // + /:pujaId
  static const String bookPuja = '/customer/puja/book';
  static const String verifyPujaOrder = '/customer/puja/verify-order';
  static const String createPujaPayment = '/customer/puja/create-payment';
  static const String myPujaOrders = '/customer/puja/my-orders';
  static const String cancelPujaOrder = '/customer/puja/cancel-order';
  static const String pujaOrderDetail = '/customer/puja/order-detail'; // + /:id

  // ── Common ────────────────────────────────────────────────
  static const String faqs = '/api/common/faqs';
  static const String terms = '/api/common/terms';
  static const String privacy = '/api/common/privacy';
  static const String upload = '/api/common/upload';
}
