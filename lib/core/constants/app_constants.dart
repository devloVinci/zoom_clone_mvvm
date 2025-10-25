class AppConstants {
  // App
  static const String appName = 'MyZoom Clone';
  static const String appVersion = '1.0.0';

  // Collections
  static const String usersCollection = 'users';
  static const String meetingsCollection = 'meetings';

  // SharedPreferences Keys
  static const String isLoggedInKey = 'isLoggedIn';
  static const String userDataKey = 'userData';

  // Error Messages
  static const String networkErrorMessage =
      'Please check your internet connection';
  static const String serverErrorMessage =
      'Something went wrong. Please try again';
  static const String authErrorMessage = 'Authentication failed';

  // Meeting
  static const int maxMeetingDuration = 24; // hours
  static const int minMeetingDuration = 1; // hour
}
