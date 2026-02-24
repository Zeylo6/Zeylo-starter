/// Border radius constants for Zeylo application
///
/// Provides a consistent border radius scale for buttons, cards,
/// inputs, and other UI elements throughout the app.
class AppRadius {
  AppRadius._(); // Private constructor to prevent instantiation

  // Base radius values
  static const double xs = 4.0; // Extra small radius
  static const double sm = 8.0; // Small radius
  static const double md = 12.0; // Medium radius
  static const double lg = 16.0; // Large radius
  static const double xl = 20.0; // Extra large radius
  static const double xxl = 24.0; // 2x large radius
  static const double xxxl = 32.0; // 3x large radius
  static const double full = 999.0; // Pill shape (fully rounded)

  // Common border radius values
  static const double buttonRadius = lg;
  static const double cardRadius = lg;
  static const double inputRadius = lg;
  static const double chipRadius = sm;
  static const double avatarRadius = full;
  static const double imageRadius = md;
}
