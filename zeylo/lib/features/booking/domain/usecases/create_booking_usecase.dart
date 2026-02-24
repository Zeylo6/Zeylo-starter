import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

/// UseCase for creating a new booking
class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  /// Execute the use case to create a booking
  /// Takes a [BookingEntity] and returns the created booking with ID
  /// Throws exception if creation fails
  Future<BookingEntity> call(BookingEntity booking) {
    return repository.createBooking(booking);
  }
}
