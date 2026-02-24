/// Asset paths for images, icons, and illustrations used in Zeylo
///
/// Centralizes all asset path constants to ensure consistency and
/// make refactoring easier when asset locations change.
class AssetPaths {
  AssetPaths._(); // Private constructor to prevent instantiation

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _illustrationsPath = 'assets/illustrations';
  static const String _logoPath = 'assets/logo';
  static const String _animationsPath = 'assets/animations';

  // ============================================
  // Logo & Branding
  // ============================================
  static const String logoFull = '$_logoPath/logo_full.png';
  static const String logoMark = '$_logoPath/logo_mark.png';
  static const String logoPurple = '$_logoPath/logo_purple.png';
  static const String logoWhite = '$_logoPath/logo_white.png';
  static const String logoGradient = '$_logoPath/logo_gradient.png';
  static const String appIcon = '$_logoPath/app_icon.png';
  static const String splashIcon = '$_logoPath/splash_icon.png';

  // ============================================
  // Onboarding Illustrations
  // ============================================
  static const String onboardingWelcome =
      '$_illustrationsPath/onboarding_welcome.png';
  static const String onboardingExplore =
      '$_illustrationsPath/onboarding_explore.png';
  static const String onboardingBook =
      '$_illustrationsPath/onboarding_book.png';
  static const String onboardingConnect =
      '$_illustrationsPath/onboarding_connect.png';
  static const String onboardingReview =
      '$_illustrationsPath/onboarding_review.png';

  // ============================================
  // Empty State Illustrations
  // ============================================
  static const String emptySearchResults =
      '$_illustrationsPath/empty_search_results.png';
  static const String emptyBookings =
      '$_illustrationsPath/empty_bookings.png';
  static const String emptyFavorites =
      '$_illustrationsPath/empty_favorites.png';
  static const String emptyMessages =
      '$_illustrationsPath/empty_messages.png';
  static const String emptyNotifications =
      '$_illustrationsPath/empty_notifications.png';
  static const String noInternet =
      '$_illustrationsPath/no_internet.png';
  static const String errorOccurred =
      '$_illustrationsPath/error_occurred.png';

  // ============================================
  // Category Icons
  // ============================================
  static const String categoryAdventure =
      '$_iconsPath/categories/adventure.svg';
  static const String categoryFood = '$_iconsPath/categories/food.svg';
  static const String categoryArts = '$_iconsPath/categories/arts.svg';
  static const String categoryWellness =
      '$_iconsPath/categories/wellness.svg';
  static const String categoryNature = '$_iconsPath/categories/nature.svg';
  static const String categoryCulture = '$_iconsPath/categories/culture.svg';
  static const String categoryMysteries =
      '$_iconsPath/categories/mysteries.svg';
  static const String categoryChains = '$_iconsPath/categories/chains.svg';
  static const String categoryAll = '$_iconsPath/categories/all.svg';
  static const String categoryNightlife =
      '$_iconsPath/categories/nightlife.svg';
  static const String categoryEducation =
      '$_iconsPath/categories/education.svg';
  static const String categoryPhotography =
      '$_iconsPath/categories/photography.svg';
  static const String categoryMusic = '$_iconsPath/categories/music.svg';
  static const String categoryWater = '$_iconsPath/categories/water.svg';
  static const String categoryMountain = '$_iconsPath/categories/mountain.svg';

  // ============================================
  // Navigation Icons
  // ============================================
  static const String navHome = '$_iconsPath/nav/home.svg';
  static const String navHomeActive = '$_iconsPath/nav/home_active.svg';
  static const String navExplore = '$_iconsPath/nav/explore.svg';
  static const String navExploreActive = '$_iconsPath/nav/explore_active.svg';
  static const String navBookings = '$_iconsPath/nav/bookings.svg';
  static const String navBookingsActive = '$_iconsPath/nav/bookings_active.svg';
  static const String navMessages = '$_iconsPath/nav/messages.svg';
  static const String navMessagesActive = '$_iconsPath/nav/messages_active.svg';
  static const String navProfile = '$_iconsPath/nav/profile.svg';
  static const String navProfileActive = '$_iconsPath/nav/profile_active.svg';

  // ============================================
  // Action Icons
  // ============================================
  static const String iconSearch = '$_iconsPath/search.svg';
  static const String iconFilter = '$_iconsPath/filter.svg';
  static const String iconMap = '$_iconsPath/map.svg';
  static const String iconLocation = '$_iconsPath/location.svg';
  static const String iconLocationOutline =
      '$_iconsPath/location_outline.svg';
  static const String iconHeart = '$_iconsPath/heart.svg';
  static const String iconHeartFilled = '$_iconsPath/heart_filled.svg';
  static const String iconStar = '$_iconsPath/star.svg';
  static const String iconStarFilled = '$_iconsPath/star_filled.svg';
  static const String iconShare = '$_iconsPath/share.svg';
  static const String iconChat = '$_iconsPath/chat.svg';
  static const String iconBell = '$_iconsPath/bell.svg';
  static const String iconBellFilled = '$_iconsPath/bell_filled.svg';
  static const String iconBack = '$_iconsPath/back.svg';
  static const String iconClose = '$_iconsPath/close.svg';
  static const String iconMenu = '$_iconsPath/menu.svg';
  static const String iconSettings = '$_iconsPath/settings.svg';
  static const String iconEdit = '$_iconsPath/edit.svg';
  static const String iconDelete = '$_iconsPath/delete.svg';
  static const String iconMore = '$_iconsPath/more.svg';
  static const String iconDownload = '$_iconsPath/download.svg';
  static const String iconUpload = '$_iconsPath/upload.svg';
  static const String iconCalendar = '$_iconsPath/calendar.svg';
  static const String iconClock = '$_iconsPath/clock.svg';
  static const String iconUsers = '$_iconsPath/users.svg';
  static const String iconPhone = '$_iconsPath/phone.svg';
  static const String iconEmail = '$_iconsPath/email.svg';
  static const String iconWeb = '$_iconsPath/web.svg';

  // ============================================
  // Status Icons
  // ============================================
  static const String iconCheck = '$_iconsPath/check.svg';
  static const String iconCheckCircle = '$_iconsPath/check_circle.svg';
  static const String iconWarning = '$_iconsPath/warning.svg';
  static const String iconError = '$_iconsPath/error.svg';
  static const String iconInfo = '$_iconsPath/info.svg';
  static const String iconLoading = '$_iconsPath/loading.svg';
  static const String iconSuccess = '$_iconsPath/success.svg';

  // ============================================
  // Social & Auth Icons
  // ============================================
  static const String iconGoogle = '$_iconsPath/social/google.svg';
  static const String iconApple = '$_iconsPath/social/apple.svg';
  static const String iconFacebook = '$_iconsPath/social/facebook.svg';
  static const String iconInstagram = '$_iconsPath/social/instagram.svg';
  static const String iconTwitter = '$_iconsPath/social/twitter.svg';
  static const String iconLinkedin = '$_iconsPath/social/linkedin.svg';

  // ============================================
  // Payment Icons
  // ============================================
  static const String paymentCard = '$_iconsPath/payment/card.svg';
  static const String paymentWallet = '$_iconsPath/payment/wallet.svg';
  static const String paymentPaypal = '$_iconsPath/payment/paypal.svg';
  static const String paymentStripe = '$_iconsPath/payment/stripe.svg';
  static const String paymentCrypto = '$_iconsPath/payment/crypto.svg';
  static const String paymentBankTransfer =
      '$_iconsPath/payment/bank_transfer.svg';

  // ============================================
  // Placeholder Images
  // ============================================
  static const String placeholderUser =
      '$_imagesPath/placeholders/user_placeholder.png';
  static const String placeholderExperience =
      '$_imagesPath/placeholders/experience_placeholder.png';
  static const String placeholderImage =
      '$_imagesPath/placeholders/image_placeholder.png';
  static const String placeholderAvatar =
      '$_imagesPath/placeholders/avatar_placeholder.png';

  // ============================================
  // Feature Illustrations
  // ============================================
  static const String featureChainsIllustration =
      '$_illustrationsPath/feature_chains.png';
  static const String featureMysteriesIllustration =
      '$_illustrationsPath/feature_mysteries.png';
  static const String featureCollaborationIllustration =
      '$_illustrationsPath/feature_collaboration.png';
  static const String featureReviewsIllustration =
      '$_illustrationsPath/feature_reviews.png';

  // ============================================
  // Badge Icons
  // ============================================
  static const String badgeTopHost = '$_iconsPath/badges/top_host.svg';
  static const String badgeVerified = '$_iconsPath/badges/verified.svg';
  static const String badgeSuperhost = '$_iconsPath/badges/superhost.svg';
  static const String badgeNewbie = '$_iconsPath/badges/newbie.svg';
  static const String badgeLocal = '$_iconsPath/badges/local.svg';
  static const String badgeExplorer = '$_iconsPath/badges/explorer.svg';

  // ============================================
  // Animations (Lottie files)
  // ============================================
  static const String animationLoading =
      '$_animationsPath/loading.json';
  static const String animationSuccess =
      '$_animationsPath/success.json';
  static const String animationError = '$_animationsPath/error.json';
  static const String animationEmpty = '$_animationsPath/empty.json';
  static const String animationCelebrate =
      '$_animationsPath/celebrate.json';

  // ============================================
  // Helper method to validate asset paths
  // ============================================
  /// Get all icon paths for easy reference and validation
  static List<String> getAllAssetPaths() => [
        logoFull,
        logoMark,
        logoPurple,
        logoWhite,
        logoGradient,
        appIcon,
        splashIcon,
        onboardingWelcome,
        onboardingExplore,
        onboardingBook,
        onboardingConnect,
        onboardingReview,
        emptySearchResults,
        emptyBookings,
        emptyFavorites,
        emptyMessages,
        emptyNotifications,
        noInternet,
        errorOccurred,
        categoryAdventure,
        categoryFood,
        categoryArts,
        categoryWellness,
        categoryNature,
        categoryCulture,
        categoryMysteries,
        categoryChains,
        categoryAll,
        categoryNightlife,
        categoryEducation,
        categoryPhotography,
        categoryMusic,
        categoryWater,
        categoryMountain,
        navHome,
        navHomeActive,
        navExplore,
        navExploreActive,
        navBookings,
        navBookingsActive,
        navMessages,
        navMessagesActive,
        navProfile,
        navProfileActive,
        iconSearch,
        iconFilter,
        iconMap,
        iconLocation,
        iconLocationOutline,
        iconHeart,
        iconHeartFilled,
        iconStar,
        iconStarFilled,
        iconShare,
        iconChat,
        iconBell,
        iconBellFilled,
        iconBack,
        iconClose,
        iconMenu,
        iconSettings,
        iconEdit,
        iconDelete,
        iconMore,
        iconDownload,
        iconUpload,
        iconCalendar,
        iconClock,
        iconUsers,
        iconPhone,
        iconEmail,
        iconWeb,
        iconCheck,
        iconCheckCircle,
        iconWarning,
        iconError,
        iconInfo,
        iconLoading,
        iconSuccess,
        iconGoogle,
        iconApple,
        iconFacebook,
        iconInstagram,
        iconTwitter,
        iconLinkedin,
        paymentCard,
        paymentWallet,
        paymentPaypal,
        paymentStripe,
        paymentCrypto,
        paymentBankTransfer,
        placeholderUser,
        placeholderExperience,
        placeholderImage,
        placeholderAvatar,
        featureChainsIllustration,
        featureMysteriesIllustration,
        featureCollaborationIllustration,
        featureReviewsIllustration,
        badgeTopHost,
        badgeVerified,
        badgeSuperhost,
        badgeNewbie,
        badgeLocal,
        badgeExplorer,
        animationLoading,
        animationSuccess,
        animationError,
        animationEmpty,
        animationCelebrate,
      ];
}
