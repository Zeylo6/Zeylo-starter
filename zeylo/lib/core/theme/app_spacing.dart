/// Spacing constants for Zeylo application
///
/// Provides a consistent spacing scale used throughout the app for
/// padding, margins, gaps, and other layout dimensions.
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Base spacing values
  static const double xs = 4.0; // Extra small spacing
  static const double sm = 8.0; // Small spacing
  static const double md = 12.0; // Medium spacing
  static const double lg = 16.0; // Large spacing
  static const double xl = 20.0; // Extra large spacing
  static const double xxl = 24.0; // 2x large spacing
  static const double xxxl = 32.0; // 3x large spacing
  static const double huge = 40.0; // Huge spacing
  static const double massive = 48.0; // Massive spacing

  // Composite spacing combinations for common patterns
  static const double verticalPaddingSmall = sm;
  static const double verticalPaddingMedium = lg;
  static const double verticalPaddingLarge = xxl;

  static const double horizontalPaddingSmall = sm;
  static const double horizontalPaddingMedium = lg;
  static const double horizontalPaddingLarge = xxl;

  // Edge insets for common padding scenarios
  static const double edgeInsetsSmall = lg;
  static const double edgeInsetsMedium = xxl;
  static const double edgeInsetsLarge = xxxl;

  // Gap between items in lists and grids
  static const double gapSmall = sm;
  static const double gapMedium = md;
  static const double gapLarge = lg;
}
