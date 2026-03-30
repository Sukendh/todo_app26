import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String apiKey = dotenv.get('FIREBASE_API_KEY', fallback: 'YOUR_FIREBASE_API_KEY');
  static final String projectId = dotenv.get('FIREBASE_PROJECT_ID', fallback: 'YOUR_PROJECT_ID');

  static const String authBaseUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:';
  static final String dbBaseUrl = 'https://$projectId-default-rtdb.firebaseio.com/';

  static String signupUrl(String key) => '${authBaseUrl}signUp?key=$key';
  static String signinUrl(String key) => '${authBaseUrl}signInWithPassword?key=$key';
  static String tasksUrl(String userId, String token) => '$dbBaseUrl/tasks/$userId.json?auth=$token';
  static String taskDetailUrl(String userId, String taskId, String token) => '$dbBaseUrl/tasks/$userId/$taskId.json?auth=$token';
}
