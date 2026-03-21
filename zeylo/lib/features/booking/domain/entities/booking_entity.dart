/// Booking entity representing a reservation in the Zeylo application
class BookingEntity {
  /// Unique identifier for the booking
  final String id;

  /// Experience ID being booked
  final String experienceId;

  /// Experience title
  final String experienceTitle;

  /// Experience cover image URL
  final String experienceCoverImage;

  /// User ID of the person making the booking
  final String userId;

  /// Host ID of the experience owner
  final String hostId;

  /// Booking date
  final DateTime date;

  /// Start time for the experience
  final String startTime;

  /// Number of guests
  final int guests;

  /// Total price of the booking
  final double totalPrice;

  /// Booking status (pending, confirmed, completed, cancelled)
  final String status;

  /// Payment status (pending, paid, refunded)
  final String paymentStatus;

  /// When the booking was created
  final DateTime createdAt;

  /// When the booking was last updated
  final DateTime updatedAt;

  /// Whether the host has rated this booking
  final bool isRatedByHost;

  /// Whether the seeker has rated this booking
  final bool isRatedBySeeker;

  /// Name of the seeker
  final String? seekerName;

  /// Photo URL of the seeker
  final String? seekerPhotoUrl;

  /// Whether the earnings for this booking have been collected by the host
  final bool isEarningsCollected;

  /// Whether this booking is a mystery experience
  final bool isMystery;

  /// Mystery document ID (links to mysteries collection)
  final String? mysteryId;

  /// Stripe Payment Intent ID
  final String? paymentId;

  const BookingEntity({
    required this.id,
    required this.experienceId,
    required this.experienceTitle,
    required this.experienceCoverImage,
    required this.userId,
    required this.hostId,
    required this.date,
    required this.startTime,
    required this.guests,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.isRatedByHost = false,
    this.isRatedBySeeker = false,
    this.seekerName,
    this.seekerPhotoUrl,
    this.isEarningsCollected = false,
    this.isMystery = false,
    this.mysteryId,
    this.paymentId,
  });

  /// Create a copy of this booking entity with some fields replaced
  BookingEntity copyWith({
    String? id,
    String? experienceId,
    String? experienceTitle,
    String? experienceCoverImage,
    String? userId,
    String? hostId,
    DateTime? date,
    String? startTime,
    int? guests,
    double? totalPrice,
    String? status,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRatedByHost,
    bool? isRatedBySeeker,
    String? seekerName,
    String? seekerPhotoUrl,
    bool? isEarningsCollected,
    bool? isMystery,
    String? mysteryId,
    String? paymentId,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      experienceId: experienceId ?? this.experienceId,
      experienceTitle: experienceTitle ?? this.experienceTitle,
      experienceCoverImage: experienceCoverImage ?? this.experienceCoverImage,
      userId: userId ?? this.userId,
      hostId: hostId ?? this.hostId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      guests: guests ?? this.guests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRatedByHost: isRatedByHost ?? this.isRatedByHost,
      isRatedBySeeker: isRatedBySeeker ?? this.isRatedBySeeker,
      seekerName: seekerName ?? this.seekerName,
      seekerPhotoUrl: seekerPhotoUrl ?? this.seekerPhotoUrl,
      isEarningsCollected: isEarningsCollected ?? this.isEarningsCollected,
      isMystery: isMystery ?? this.isMystery,
      mysteryId: mysteryId ?? this.mysteryId,
      paymentId: paymentId ?? this.paymentId,
    );
  }

  @override
  String toString() => 'BookingEntity('
      'id: $id, '
      'experienceId: $experienceId, '
      'userId: $userId, '
      'status: $status, '
      'paymentStatus: $paymentStatus, '
      'isRatedByHost: $isRatedByHost, '
      'isRatedBySeeker: $isRatedBySeeker, '
      'isMystery: $isMystery, '
      'mysteryId: $mysteryId, '
      'paymentId: $paymentId'
      ')';
}
