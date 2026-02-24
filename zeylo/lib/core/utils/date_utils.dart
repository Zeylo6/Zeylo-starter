import 'package:intl/intl.dart';

/// Utility functions for date and time formatting throughout the Zeylo app
class DateUtils {
  /// Formats a DateTime to a readable date string (e.g., "Jan 15, 2024")
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  /// Formats a DateTime to a time string (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Formats a DateTime to a full datetime string (e.g., "Jan 15, 2024 2:30 PM")
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
  }

  /// Returns relative time format (e.g., "2 days ago", "50 mins left")
  /// Pass [isFuture] as true to format as countdown, false for past time
  static String getRelativeTime(DateTime dateTime, {bool isFuture = false}) {
    final now = DateTime.now();
    final difference = isFuture
        ? dateTime.difference(now)
        : now.difference(dateTime);

    final isNegative = difference.isNegative;
    final absDifference = difference.abs();

    if (absDifference.inSeconds < 60) {
      final seconds = absDifference.inSeconds;
      return isFuture ? '$seconds secs left' : '$seconds secs ago';
    } else if (absDifference.inMinutes < 60) {
      final minutes = absDifference.inMinutes;
      return isFuture ? '$minutes mins left' : '$minutes mins ago';
    } else if (absDifference.inHours < 24) {
      final hours = absDifference.inHours;
      return isFuture ? '$hours hrs left' : '$hours hrs ago';
    } else if (absDifference.inDays < 7) {
      final days = absDifference.inDays;
      return isFuture ? '$days days left' : '$days days ago';
    } else if (absDifference.inDays < 30) {
      final weeks = (absDifference.inDays / 7).ceil();
      return isFuture ? '$weeks weeks left' : '$weeks weeks ago';
    } else {
      final months = (absDifference.inDays / 30).ceil();
      return isFuture ? '$months months left' : '$months months ago';
    }
  }

  /// Formats a duration to countdown format (HH:MM:SS)
  /// Used for mystery countdown timers
  static String formatCountdown(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }

  /// Returns the time of day label based on hour
  static String getTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;

    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  /// Checks if a datetime is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Checks if a datetime is tomorrow
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  /// Checks if a datetime is in the past
  static bool isPast(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }

  /// Checks if a datetime is in the future
  static bool isFuture(DateTime dateTime) {
    return dateTime.isAfter(DateTime.now());
  }

  /// Checks if an experience is currently ongoing
  static bool isOngoing(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Checks if an experience is upcoming (hasn't started yet)
  static bool isUpcoming(DateTime startTime) {
    return startTime.isAfter(DateTime.now());
  }

  /// Returns a friendly date label (Today, Tomorrow, or formatted date)
  static String getFriendlyDate(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Today';
    } else if (isTomorrow(dateTime)) {
      return 'Tomorrow';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Formats duration to human-readable format (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Gets the number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Parses a date string in 'yyyy-MM-dd' format
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
