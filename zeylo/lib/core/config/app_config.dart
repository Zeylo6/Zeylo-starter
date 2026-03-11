class AppConfig {
  /// The base URL for the backend server.
  /// 
  /// Using the provided ngrok URL for universal access from any device (Phone, Emulator, Web).
  static const String baseUrl = 'https://unreviling-hypermetropic-allen.ngrok-free.dev';

  /// Helper to get the full API base path
  static String get apiBase => '$baseUrl/api';
}
