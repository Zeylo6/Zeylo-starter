import '../entities/booking_entity.dart';

/// Abstract repository for booking operations
/// Defines the contract for booking-related data operations
abstract class BookingRepository {
  /// Create a new booking
  /// Throws exception if creation fails
  Future<BookingEntity> createBooking(BookingEntity booking);

  /// Get a booking by ID
  /// Throws exception if booking not found
  Future<BookingEntity> getBookingById(String id);

  /// Get all bookings for a specific user
  /// Returns list of bookings made by the user
  Future<List<BookingEntity>> getUserBookings(String userId);

  /// Get all bookings for a specific host
  /// Returns list of bookings for experiences hosted by the user
  Future<List<BookingEntity>> getHostBookings(String hostId);

  /// Update booking status
  /// Status can be: pending, confirmed, completed, cancelled
  Future<void> updateBookingStatus(String id, String status);

  /// Update payment status
  /// Payment status can be: pending, paid, refunded
  Future<void> updatePaymentStatus(String id, String paymentStatus);

  /// Cancel a booking
  Future<void> cancelBooking(String id);
}
