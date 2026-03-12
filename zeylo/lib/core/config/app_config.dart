class AppConfig {
  /// The base URL for the backend server.
  /// 
  /// Using the provided ngrok URL for universal access from any device (Phone, Emulator, Web).
  static const String baseUrl = 'http://localhost:3000';

  /// Helper to get the full API base path
  static String get apiBase => '$baseUrl/api';
}
