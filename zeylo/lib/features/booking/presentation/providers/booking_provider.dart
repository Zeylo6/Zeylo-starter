import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/booking_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/get_user_bookings_usecase.dart';

/// Booking form state model
class BookingFormState {
  final String fullName;
  final String email;
  final String phoneNumber;
  final int guests;
  final String date;
  final String time;
  final String cardNumber;
  final String expiry;
  final String cvc;
  final String cardholderName;
  final bool isLoading;
  final String? errorMessage;

  BookingFormState({
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.guests = 1,
    this.date = '',
    this.time = '09:00 AM',
    this.cardNumber = '',
    this.expiry = '',
    this.cvc = '',
    this.cardholderName = '',
    this.isLoading = false,
    this.errorMessage,
  });

  BookingFormState copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    int? guests,
    String? date,
    String? time,
    String? cardNumber,
    String? expiry,
    String? cvc,
    String? cardholderName,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BookingFormState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      guests: guests ?? this.guests,
      date: date ?? this.date,
      time: time ?? this.time,
      cardNumber: cardNumber ?? this.cardNumber,
      expiry: expiry ?? this.expiry,
      cvc: cvc ?? this.cvc,
      cardholderName: cardholderName ?? this.cardholderName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for booking form state
class BookingFormNotifier extends StateNotifier<BookingFormState> {
  BookingFormNotifier() : super(BookingFormState());

  void updateFullName(String value) {
    state = state.copyWith(fullName: value);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value);
  }

  void updateGuests(int value) {
    state = state.copyWith(guests: value);
  }

  void updateDate(String value) {
    state = state.copyWith(date: value);
  }

  void updateTime(String value) {
    state = state.copyWith(time: value);
  }

  void updateCardNumber(String value) {
    state = state.copyWith(cardNumber: value);
  }

  void updateExpiry(String value) {
    state = state.copyWith(expiry: value);
  }

  void updateCVC(String value) {
    state = state.copyWith(cvc: value);
  }

  void updateCardholderName(String value) {
    state = state.copyWith(cardholderName: value);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void reset() {
    state = BookingFormState();
  }
}

/// Booking repository provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(
    remoteDataSource: BookingRemoteDataSource(
      firebaseFirestore: FirebaseFirestore.instance,
    ),
  );
});

/// Create booking use case provider
final createBookingUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return CreateBookingUseCase(repository);
});

/// Get user bookings use case provider
final getUserBookingsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return GetUserBookingsUseCase(repository);
});

/// Booking form provider
final bookingFormProvider =
    StateNotifierProvider<BookingFormNotifier, BookingFormState>((ref) {
  return BookingFormNotifier();
});

/// User bookings provider
final userBookingsProvider = FutureProvider.family<List<BookingEntity>, String>(
  (ref, userId) async {
    final useCase = ref.watch(getUserBookingsUseCaseProvider);
    return useCase(userId);
  },
);

/// Create booking provider
final createBookingProvider =
    FutureProvider.family<BookingEntity, BookingEntity>((ref, booking) async {
  final useCase = ref.watch(createBookingUseCaseProvider);
  return useCase(booking);
});

/// Host bookings provider (requires repository access)
final hostBookingsProvider =
    FutureProvider.family<List<BookingEntity>, String>((ref, hostId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getHostBookings(hostId);
});
