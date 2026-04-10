class AuthErrorMapper {
  static String mapMessage(String error) {
    // Remove the "Exception: " prefix if it exists
    String message = error.replaceAll('Exception: ', '');
    
    // Map Firebase REST API error codes to friendly messages
    switch (message) {
      case 'EMAIL_EXISTS':
        return 'This email is already registered. Try logging in.';
      case 'INVALID_EMAIL':
        return 'The email address is not valid.';
      case 'MISSING_PASSWORD':
        return 'Please enter a password.';
      case 'WEAK_PASSWORD : Password should be at least 6 characters':
        return 'The password is too weak. It must be at least 6 characters.';
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'EMAIL_NOT_FOUND':
      case 'INVALID_PASSWORD':
        return 'Invalid email or password. Please try again.';
      case 'USER_DISABLED':
        return 'This account has been disabled. Please contact support.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Too many failed login attempts. Please try again later.';
      default:
        // Return a generic message if the error code is unknown or doesn't match
        if (message.contains('NETWORK_ERROR')) {
          return 'Network error. Please check your internet connection.';
        }
        return 'An unexpected error occurred: $message';
    }
  }
}
