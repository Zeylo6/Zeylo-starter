import 'package:flutter/material.dart';

/// Application-wide constants
///
/// Contains static constants used throughout the Zeylo application
/// including app name, defaults, pagination limits, and animation durations.
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // App Information
  static const String appName = 'Zeylo';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.zeylo.app';

  // Defaults
  static const String defaultCurrency = 'USD';
  static const String defaultCountryCode = '+94'; // Sri Lanka
  static const String defaultLanguage = 'en';
  static const String defaultLocale = 'en_US';
  static const String defaultTimeZone = 'Asia/Colombo';

  // Pagination & Lists
  static const int paginationLimit = 20;
  static const int initialPaginationPage = 1;
  static const int maxRetries = 3;
  static const int requestTimeoutSeconds = 30;

  // Image & Media
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1440;
  static const int imageCompressQuality = 85;
  static const int maxImagesPerExperience = 10;
  static const int maxVideoSizeMB = 500;
  static const int maxImageSizeMB = 10;

  // Rating & Review
  static const int minReviewLength = 10;
  static const int maxReviewLength = 500;
  static const double minRating = 1.0;
  static const double maxRating = 5.0;

  // Location & Maps
  static const double defaultMapZoom = 15.0;
  static const double mapAnimationDuration = 300;
  static const double searchRadiusKm = 25.0;
  static const double locationAccuracy = 50.0; // meters

  // Animations & Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration dialogAnimationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);
  static const Duration navigationAnimationDuration = Duration(milliseconds: 300);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 250);
  static const Duration slideAnimationDuration = Duration(milliseconds: 350);

  // Debounce & Throttle
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration throttleDelay = Duration(milliseconds: 300);
  static const Duration searchDebounceDelay = Duration(milliseconds: 400);

  // API Endpoints (example structure)
  static const String baseUrl = 'https://api.zeylo.app/v1';
  static const String wsBaseUrl = 'wss://ws.zeylo.app/v1';

  // Firebase
  static const String firebaseProjectId = 'zeylo-app';
  static const String firebaseApiKey = 'YOUR_API_KEY'; // Set in environment
  static const String firebaseAuthDomain = 'zeylo-app.firebaseapp.com';
  static const String firebaseStorageBucket = 'zeylo-app.appspot.com';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID'; // Set in environment

  // Regex Patterns
  static const String emailRegex =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";

  static const String phoneRegex = r'^[0-9]{10,15}$';

  static const String urlRegex =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minBioLength = 0;
  static const int maxBioLength = 500;
  static const int minExperienceTitle = 5;
  static const int maxExperienceTitle = 100;
  static const int minExperienceDescription = 20;
  static const int maxExperienceDescription = 5000;

  // Search
  static const int minSearchQueryLength = 1;
  static const int maxSearchQueryLength = 100;
  static const int searchResultsLimit = 50;

  // Pricing
  static const double zeyloCommissionPercentage = 0.10; // 10%
  static const double minimumPriceUSD = 1.0;
  static const double maximumPriceUSD = 100000.0;

  // Social Features
  static const int maxFollowers = 999999;
  static const int maxBio = 500;
  static const int maxHashtags = 10;
  static const int maxTagsPerExperience = 5;

  // Cache Duration
  static const Duration cacheExpiry = Duration(days: 7);
  static const Duration sessionCacheExpiry = Duration(hours: 12);
  static const Duration imageCacheExpiry = Duration(days: 30);

  // Empty States
  static const String emptySearchMessage = 'No experiences found';
  static const String noResultsMessage = 'No results available';
  static const String loadingMessage = 'Loading...';
  static const String errorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection';

  // Date & Time Formats
  static const String dateFormatPattern = 'dd MMM yyyy';
  static const String timeFormatPattern = 'hh:mm a';
  static const String dateTimeFormatPattern = 'dd MMM yyyy, hh:mm a';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableOfflineMode = true;
  static const bool enableSocialSharing = true;
  static const bool enablePaymentGateway = true;
  static const bool enableNotifications = true;

  // Links & URLs
  static const String privacyPolicyUrl = 'https://zeylo.app/privacy';
  static const String termsOfServiceUrl = 'https://zeylo.app/terms';
  static const String contactSupportUrl = 'https://zeylo.app/support';
  static const String feedbackFormUrl = 'https://zeylo.app/feedback';
  static const String websiteUrl = 'https://zeylo.app';

  // Social Media
  static const String instagramUrl = 'https://instagram.com/zeyloapp';
  static const String twitterUrl = 'https://twitter.com/zeyloapp';
  static const String facebookUrl = 'https://facebook.com/zeyloapp';
  static const String linkedinUrl = 'https://linkedin.com/company/zeyloapp';
}
