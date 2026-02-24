/// Firebase Firestore collection names and constants
///
/// Defines all collection names and document structure constants
/// used for Firestore database operations in the Zeylo application.
class FirebaseConstants {
  FirebaseConstants._(); // Private constructor to prevent instantiation

  // Collection Names
  static const String usersCollection = 'users';
  static const String experiencesCollection = 'experiences';
  static const String bookingsCollection = 'bookings';
  static const String categoriesCollection = 'categories';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';
  static const String reviewsCollection = 'reviews';
  static const String chainsCollection = 'chains'; // Mystery chains/quest-like features
  static const String mysteriesCollection = 'mysteries'; // Collaborative mystery experiences
  static const String promotionsCollection = 'promotions';
  static const String savedExperiencesCollection = 'saved_experiences';
  static const String notificationsCollection = 'notifications';
  static const String paymentsCollection = 'payments';
  static const String reportsCollection = 'reports'; // User/experience reports
  static const String feedbackCollection = 'feedback';
  static const String analyticsCollection = 'analytics';

  // Subcollections
  static const String imagesSubcollection = 'images';
  static const String commentsSubcollection = 'comments';
  static const String participantsSubcollection = 'participants';
  static const String mediaSubcollection = 'media';
  static const String receiptsSubcollection = 'receipts';
  static const String statusUpdatesSubcollection = 'status_updates';

  // User Fields
  static const String userId = 'userId';
  static const String userEmail = 'email';
  static const String userName = 'name';
  static const String userPhone = 'phone';
  static const String userPhotoUrl = 'photoUrl';
  static const String userBio = 'bio';
  static const String userLocation = 'location';
  static const String userCountry = 'country';
  static const String userRating = 'rating';
  static const String userReviewCount = 'reviewCount';
  static const String userFollowersCount = 'followersCount';
  static const String userFollowingCount = 'followingCount';
  static const String userCreatedAt = 'createdAt';
  static const String userVerified = 'verified';
  static const String userVerificationStatus = 'verificationStatus';
  static const String userBadges = 'badges';
  static const String userLanguages = 'languages';
  static const String userAboutMe = 'aboutMe';

  // Experience Fields
  static const String experienceId = 'experienceId';
  static const String experienceTitle = 'title';
  static const String experienceDescription = 'description';
  static const String experienceCategory = 'category';
  static const String experienceSubcategory = 'subcategory';
  static const String experienceTags = 'tags';
  static const String experienceLocation = 'location';
  static const String experienceGeopoint = 'geopoint';
  static const String experiencePrice = 'price';
  static const String experienceCurrency = 'currency';
  static const String experienceDuration = 'duration';
  static const String experienceDurationUnit = 'durationUnit';
  static const String experienceGroupSize = 'groupSize';
  static const String experienceMinGroupSize = 'minGroupSize';
  static const String experienceMaxGroupSize = 'maxGroupSize';
  static const String experienceRating = 'rating';
  static const String experienceReviewCount = 'reviewCount';
  static const String experienceImages = 'images';
  static const String experienceVideo = 'video';
  static const String experienceHost = 'host';
  static const String experienceHostId = 'hostId';
  static const String experienceDifficulty = 'difficulty';
  static const String experienceLevel = 'level';
  static const String experienceLanguages = 'languages';
  static const String experienceCreatedAt = 'createdAt';
  static const String experienceUpdatedAt = 'updatedAt';
  static const String experienceAvailable = 'available';
  static const String experiencePublished = 'published';
  static const String experienceHighlights = 'highlights';
  static const String experienceInclusions = 'inclusions';
  static const String experienceExclusions = 'exclusions';
  static const String experienceItinerary = 'itinerary';
  static const String experienceRequirements = 'requirements';
  static const String experienceViews = 'views';
  static const String experienceWishlistCount = 'wishlistCount';

  // Booking Fields
  static const String bookingId = 'bookingId';
  static const String bookingExperienceId = 'experienceId';
  static const String bookingUserId = 'userId';
  static const String bookingHostId = 'hostId';
  static const String bookingDate = 'date';
  static const String bookingStartTime = 'startTime';
  static const String bookingEndTime = 'endTime';
  static const String bookingParticipants = 'participants';
  static const String bookingStatus = 'status';
  static const String bookingPrice = 'price';
  static const String bookingTotalPrice = 'totalPrice';
  static const String bookingCurrency = 'currency';
  static const String bookingPaymentId = 'paymentId';
  static const String bookingNotes = 'notes';
  static const String bookingCancellationReason = 'cancellationReason';
  static const String bookingCreatedAt = 'createdAt';
  static const String bookingConfirmedAt = 'confirmedAt';
  static const String bookingCancelledAt = 'cancelledAt';
  static const String bookingCompletedAt = 'completedAt';

  // Review Fields
  static const String reviewId = 'reviewId';
  static const String reviewBookingId = 'bookingId';
  static const String reviewExperienceId = 'experienceId';
  static const String reviewAuthorId = 'authorId';
  static const String reviewAuthorName = 'authorName';
  static const String reviewAuthorPhotoUrl = 'authorPhotoUrl';
  static const String reviewRating = 'rating';
  static const String reviewTitle = 'title';
  static const String reviewContent = 'content';
  static const String reviewImages = 'images';
  static const String reviewCreatedAt = 'createdAt';
  static const String reviewUpdatedAt = 'updatedAt';
  static const String reviewHelpful = 'helpful';
  static const String reviewHelpfulCount = 'helpfulCount';

  // Message Fields
  static const String messageId = 'messageId';
  static const String messageConversationId = 'conversationId';
  static const String messageSenderId = 'senderId';
  static const String messageSenderName = 'senderName';
  static const String messageSenderPhotoUrl = 'senderPhotoUrl';
  static const String messageContent = 'content';
  static const String messageType = 'type'; // text, image, etc
  static const String messageMediaUrl = 'mediaUrl';
  static const String messageCreatedAt = 'createdAt';
  static const String messageReadAt = 'readAt';
  static const String messageStatus = 'status'; // sent, delivered, read

  // Conversation Fields
  static const String conversationId = 'conversationId';
  static const String conversationParticipants = 'participants';
  static const String conversationParticipantIds = 'participantIds';
  static const String conversationLastMessage = 'lastMessage';
  static const String conversationLastMessageTime = 'lastMessageTime';
  static const String conversationLastMessageSenderId = 'lastMessageSenderId';
  static const String conversationCreatedAt = 'createdAt';
  static const String conversationUpdatedAt = 'updatedAt';
  static const String conversationUnreadCount = 'unreadCount';
  static const String conversationMuted = 'muted';

  // Category Fields
  static const String categoryId = 'categoryId';
  static const String categoryName = 'name';
  static const String categoryDescription = 'description';
  static const String categoryIcon = 'icon';
  static const String categoryColor = 'color';
  static const String categorySubcategories = 'subcategories';
  static const String categoryOrder = 'order';
  static const String categoryActive = 'active';

  // Chain/Mystery Fields
  static const String chainId = 'chainId';
  static const String chainTitle = 'title';
  static const String chainDescription = 'description';
  static const String chainExperiences = 'experiences';
  static const String chainHost = 'host';
  static const String chainDifficulty = 'difficulty';
  static const String chainProgress = 'progress';
  static const String chainCreatedAt = 'createdAt';

  // Promotion Fields
  static const String promotionId = 'promotionId';
  static const String promotionCode = 'code';
  static const String promotionDescription = 'description';
  static const String promotionDiscount = 'discount';
  static const String promotionDiscountType = 'discountType'; // percentage, fixed
  static const String promotionStartDate = 'startDate';
  static const String promotionEndDate = 'endDate';
  static const String promotionExperienceIds = 'experienceIds';
  static const String promotionMaxUses = 'maxUses';
  static const String promotionCurrentUses = 'currentUses';
  static const String promotionActive = 'active';

  // Notification Fields
  static const String notificationId = 'notificationId';
  static const String notificationUserId = 'userId';
  static const String notificationTitle = 'title';
  static const String notificationBody = 'body';
  static const String notificationType = 'type';
  static const String notificationData = 'data';
  static const String notificationRead = 'read';
  static const String notificationCreatedAt = 'createdAt';

  // Payment Fields
  static const String paymentId = 'paymentId';
  static const String paymentBookingId = 'bookingId';
  static const String paymentUserId = 'userId';
  static const String paymentAmount = 'amount';
  static const String paymentCurrency = 'currency';
  static const String paymentMethod = 'method';
  static const String paymentStatus = 'status';
  static const String paymentTransactionId = 'transactionId';
  static const String paymentCreatedAt = 'createdAt';
  static const String paymentUpdatedAt = 'updatedAt';

  // Batch/Transaction status values
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusRejected = 'rejected';
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';

  // Message status values
  static const String messageSent = 'sent';
  static const String messageDelivered = 'delivered';
  static const String messageRead = 'read';

  // Verification status values
  static const String verificationPending = 'pending';
  static const String verificationApproved = 'approved';
  static const String verificationRejected = 'rejected';

  // Difficulty levels
  static const String difficultyEasy = 'easy';
  static const String difficultyMedium = 'medium';
  static const String difficultyHard = 'hard';
  static const String difficultyExtreme = 'extreme';

  // Timestamps
  static const String fieldTimestamp = 'timestamp';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldDeletedAt = 'deletedAt';
  static const String fieldLastModified = 'lastModified';
}
