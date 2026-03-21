class AppConfig {
  /// The base URL for the backend server.
  ///
  /// For Android Emulator, use 'http://10.0.2.2:3000'
  /// For iOS Simulator or Web, use 'http://localhost:3000'
  /// For physical devices, use your machine's local IP or a tunnel (e.g., ngrok)
  static const String baseUrl = 'http://localhost:3000';

  /// Helper to get the full API base path
  static String get apiBase => '$baseUrl/api';
}
