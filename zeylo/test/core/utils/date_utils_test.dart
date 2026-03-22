import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zeylo/core/utils/date_utils.dart' as zeylo_date;

void main() {
  group('DateUtils.toDateTime', () {
    test('should parse DateTime correctly', () {
      final now = DateTime.now();
      expect(zeylo_date.DateUtils.toDateTime(now), now);
    });

    test('should parse ISO 8601 String correctly', () {
      final dateStr = '2024-01-15T12:00:00.000Z';
      final expected = DateTime.parse(dateStr);
      expect(zeylo_date.DateUtils.toDateTime(dateStr), expected);
    });

    test('should parse invalid String as DateTime.now()', () {
      final invalidStr = 'not-a-date';
      final result = zeylo_date.DateUtils.toDateTime(invalidStr);
      // Allow 1 second difference
      expect(result.difference(DateTime.now()).inSeconds.abs() <= 1, true);
    });

    test('should return DateTime.now() for null', () {
      final result = zeylo_date.DateUtils.toDateTime(null);
      expect(result.difference(DateTime.now()).inSeconds.abs() <= 1, true);
    });

    // Mocking Timestamp since we can't easily create a real one in a pure test without firebase_core initialized,
    // but DateUtils.toDateTime uses a dynamic call to .toDate() which we can test.
    test('should parse object with .toDate() method (like Timestamp)', () {
      final now = DateTime.now();
      final mockTimestamp = _MockTimestamp(now);
      expect(zeylo_date.DateUtils.toDateTime(mockTimestamp), now);
    });

    test('should return DateTime.now() for unknown objects', () {
      final result = zeylo_date.DateUtils.toDateTime(12345);
      expect(result.difference(DateTime.now()).inSeconds.abs() <= 1, true);
    });
  });
}

class _MockTimestamp {
  final DateTime date;
  _MockTimestamp(this.date);
  DateTime toDate() => date;
}
