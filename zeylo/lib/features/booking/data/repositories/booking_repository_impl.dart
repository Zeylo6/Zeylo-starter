import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_datasource.dart';
import '../models/booking_model.dart';

/// Implementation of BookingRepository using remote data source
class BookingRepositoryImpl implements BookingRepository {
  final BookingDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BookingEntity> createBooking(BookingEntity booking) async {
    try {
      final bookingModel = BookingModel(
        id: '',
        experienceId: booking.experienceId,
        experienceTitle: booking.experienceTitle,
        experienceCoverImage: booking.experienceCoverImage,
        userId: booking.userId,
        hostId: booking.hostId,
        date: booking.date,
        startTime: booking.startTime,
        guests: booking.guests,
        totalPrice: booking.totalPrice,
        status: booking.status,
        paymentStatus: booking.paymentStatus,
        createdAt: booking.createdAt,
        updatedAt: booking.updatedAt,
        seekerName: booking.seekerName,
        seekerPhotoUrl: booking.seekerPhotoUrl,
      );
      return await remoteDataSource.createBooking(bookingModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BookingEntity> getBookingById(String id) async {
    try {
      return await remoteDataSource.getBookingById(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookingEntity>> getUserBookings(String userId) async {
    try {
      return await remoteDataSource.getUserBookings(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookingEntity>> getHostBookings(String hostId) async {
    try {
      return await remoteDataSource.getHostBookings(hostId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateBookingStatus(String id, String status) async {
    try {
      await remoteDataSource.updateBookingStatus(id, status);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePaymentStatus(String id, String paymentStatus) async {
    try {
      await remoteDataSource.updatePaymentStatus(id, paymentStatus);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelBooking(String id) async {
    try {
      await remoteDataSource.cancelBooking(id);
    } catch (e) {
      rethrow;
    }
  }
}
