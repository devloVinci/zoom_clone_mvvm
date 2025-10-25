class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // At least 6 characters
    return password.length >= 6;
  }

  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.length >= 2;
  }

  static bool isValidMeetingId(String meetingId) {
    return meetingId.trim().isNotEmpty && meetingId.length >= 6;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(password)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (!isValidName(name)) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateMeetingId(String? meetingId) {
    if (meetingId == null || meetingId.isEmpty) {
      return 'Meeting ID is required';
    }
    if (!isValidMeetingId(meetingId)) {
      return 'Meeting ID must be at least 6 characters';
    }
    return null;
  }
}
