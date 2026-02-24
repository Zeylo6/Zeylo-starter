import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'date_utils.dart' as app_date_utils;

// ===== String Extensions =====

/// Extension methods for String manipulation and validation
extension StringExtension on String {
  /// Capitalizes the first letter of the string
  /// Example: "hello".capitalize() → "Hello"
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Converts string to title case
  /// Example: "hello world".toTitleCase() → "Hello World"
  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Validates if string is a valid email format
  bool isValidEmail() {
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(emailRegex).hasMatch(this);
  }

  /// Gets initials from a name string
  /// Example: "John Doe".initials → "JD"
  String get initials {
    final parts = split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  /// Truncates string to a max length with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Checks if string contains only numbers
  bool isNumeric() {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Removes all whitespace from string
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }
}

// ===== Context Extensions =====

/// Extension methods for BuildContext to access common screen properties
extension ContextExtension on BuildContext {
  /// Gets the screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Gets the screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Gets the safe area top padding (status bar height)
  double get topPadding => MediaQuery.of(this).padding.top;

  /// Gets the safe area bottom padding (navigation bar height)
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  /// Gets the device padding
  EdgeInsets get devicePadding => MediaQuery.of(this).padding;

  /// Gets the device view insets (for keyboard, etc)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Checks if device is in landscape orientation
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  /// Checks if device is in portrait orientation
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  /// Checks if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Gets keyboard height
  double get keyboardHeight => viewInsets.bottom;

  /// Shows a snackbar with a message
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Shows an error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
    );
  }

  /// Shows a success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Navigates to a route using GoRouter
  void push(String location) => go(location);

  /// Pops the current route
  void pop<T extends Object?>([T? result]) => GoRouter.of(this).pop(result);

  /// Replaces the current route
  void replace(String location) => go(location);

  /// Hides the keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}

// ===== DateTime Extensions =====

/// Extension methods for DateTime formatting and comparison
extension DateTimeExtension on DateTime {
  /// Checks if this date is today
  bool get isToday => app_date_utils.DateUtils.isToday(this);

  /// Checks if this date is tomorrow
  bool get isTomorrow => app_date_utils.DateUtils.isTomorrow(this);

  /// Checks if this date is in the past
  bool get isPast => app_date_utils.DateUtils.isPast(this);

  /// Checks if this date is in the future
  bool get isFuture => app_date_utils.DateUtils.isFuture(this);

  /// Gets a formatted date string (e.g., "Jan 15, 2024")
  String get formatted => app_date_utils.DateUtils.formatDate(this);

  /// Gets a formatted datetime string (e.g., "Jan 15, 2024 2:30 PM")
  String get formattedDateTime => app_date_utils.DateUtils.formatDateTime(this);

  /// Gets a formatted time string (e.g., "2:30 PM")
  String get formattedTime => app_date_utils.DateUtils.formatTime(this);

  /// Gets friendly date label (Today, Tomorrow, or formatted)
  String get friendlyDate => app_date_utils.DateUtils.getFriendlyDate(this);

  /// Gets relative time (e.g., "2 days ago")
  String get relativeTime => app_date_utils.DateUtils.getRelativeTime(this);

  /// Gets time of day (Morning, Afternoon, Evening, Night)
  String get timeOfDay => app_date_utils.DateUtils.getTimeOfDay(this);

  /// Gets number of days between this date and now
  int get daysUntilNow => app_date_utils.DateUtils.daysBetween(this, DateTime.now());

  /// Formats as countdown (HH:MM:SS)
  String toCountdownFormat() => app_date_utils.DateUtils.formatCountdown(difference(DateTime.now()).abs());
}

// ===== Double Extensions =====

/// Extension methods for Double formatting
extension DoubleExtension on double {
  /// Converts double to currency string with dollar sign
  /// Example: 99.99.toCurrency() → "$99.99"
  String toCurrency({String symbol = '\$'}) {
    return '$symbol${toStringAsFixed(2)}';
  }

  /// Formats as percentage
  /// Example: 0.85.toPercentage() → "85%"
  String toPercentage({int decimals = 0}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  /// Rounds to a specific number of decimal places
  double roundTo(int places) {
    final mod = math.pow(10.0, places).toInt();
    return (this * mod).round() / mod;
  }
}

// ===== List Extensions =====

/// Extension methods for List operations
extension ListExtension<T> on List<T> {
  /// Returns the first element, or null if list is empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns the last element, or null if list is empty
  T? get lastOrNull => isEmpty ? null : last;

  /// Finds an element by a predicate, or returns null
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  /// Gets an element at index, or returns null if out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Partitions list into chunks of a specific size
  List<List<T>> chunked(int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(
        i,
        i + chunkSize > length ? length : i + chunkSize,
      ));
    }
    return chunks;
  }

  /// Returns a new list without duplicates (preserves order)
  List<T> get unique {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }

  /// Returns a new list where the element at [oldIndex] is moved to [newIndex]
  List<T> reorder(int oldIndex, int newIndex) {
    final list = [...this];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    return list;
  }
}

// ===== Map Extensions =====

/// Extension methods for Map operations
extension MapExtension<K, V> on Map<K, V> {
  /// Gets a value by key, or returns a default value
  V? getOrDefault(K key, V? defaultValue) {
    return containsKey(key) ? this[key] : defaultValue;
  }

  /// Converts map to query string (for URL parameters)
  String toQueryString() {
    return entries
        .map((e) => '${Uri.encodeComponent(e.key.toString())}='
            '${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }
}

// ===== Duration Extensions =====

/// Extension methods for Duration formatting
extension DurationExtension on Duration {
  /// Formats duration to human-readable format (e.g., "2h 30m")
  String get formatted => app_date_utils.DateUtils.formatDuration(this);

  /// Gets the countdown format (HH:MM:SS)
  String get countdownFormat => app_date_utils.DateUtils.formatCountdown(this);
}
