import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

/// UseCase for retrieving all bookings for a specific user
class GetUserBookingsUseCase {
  final BookingRepository repository;

  GetUserBookingsUseCase(this.repository);

  /// Execute the use case to get user bookings
  /// Takes a [userId] and returns list of bookings made by the user
  /// Throws exception if retrieval fails
  Future<List<BookingEntity>> call(String userId) {
    return repository.getUserBookings(userId);
  }
}
