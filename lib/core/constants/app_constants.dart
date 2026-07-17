class AppConstants {
  // App Info
  static const String appName = 'Vedikvani Wellness';
  static const String appVersion = '1.0.0';

  // API Configuration
  // static const String baseUrl = 'http://10.0.2.2:3050';
  //static String baseUrl = 'http://192.168.1.6:3050';
  static const String baseUrl = 'https://api.vedikvani.com/';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const String razorpayKeyId = 'rzp_test_SV2JFRNjdY0Avz';

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserData = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyProfileComplete = 'user_profile_complete';
  static const String keyUserEmail = 'user_email';
  static const String keyUserPhone = 'user_phone';
  static const String keyLanguage = 'app_language';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int otpLength = 6;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 2.0;

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
}
