import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth provider
import '../features/auth/presentation/providers/auth_provider.dart';

// Auth screens
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/verify_email_screen.dart';
import '../features/auth/presentation/screens/verify_success_screen.dart';
import '../features/auth/presentation/screens/banned_screen.dart';

// Onboarding
import '../features/onboarding/presentation/screens/onboarding_screen.dart';

// Home
import '../features/home/presentation/screens/home_screen.dart';

// Experience
import '../features/experience/presentation/screens/experience_detail_screen.dart';

// Booking
import '../features/booking/presentation/screens/booking_screen.dart';

// Host
import '../features/host/presentation/screens/host_dashboard_screen.dart';
import '../features/host/presentation/screens/earnings_screen.dart';
import '../features/host/presentation/screens/create_experience_screen.dart';
import '../features/host/presentation/screens/host_calendar_screen.dart';

// Seeker
import '../features/booking/presentation/screens/seeker_dashboard_screen.dart';

// Mystery
import '../features/mystery/presentation/screens/create_mystery_screen.dart';
import '../features/mystery/presentation/screens/mystery_reveal_screen.dart';

// Chain
import '../features/chain/presentation/screens/create_chain_screen.dart';
import '../features/chain/presentation/screens/edit_chain_screen.dart';
import '../features/chain/domain/entities/chain_entity.dart';

// Mood
import '../features/mood/presentation/screens/mood_selector_screen.dart';
import '../features/mood/presentation/screens/mood_describe_screen.dart';
import '../features/mood/presentation/screens/mood_results_screen.dart';

// Community
import '../features/community/presentation/screens/community_screen.dart';
import '../features/community/presentation/screens/create_moment_screen.dart';
import '../features/community/presentation/screens/create_post_screen.dart';
import '../features/community/presentation/screens/comments_screen.dart';
import '../features/community/presentation/screens/moment_viewer_screen.dart';
import '../features/community/domain/entities/moment_entity.dart';

// Messaging
import '../features/messaging/presentation/screens/message_list_screen.dart';
import '../features/messaging/presentation/screens/chat_screen.dart';

// Activity
import '../features/activity/presentation/screens/activity_screen.dart';

// Profile
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/followers_screen.dart';
import '../features/profile/presentation/screens/following_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/profile/presentation/screens/legal_content_screen.dart';

// Notifications
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/notifications/presentation/providers/notifications_provider.dart';

// Map Discovery
import '../features/map_discovery/presentation/screens/join_experience_screen.dart';
import '../features/map_discovery/presentation/screens/live_experience_screen.dart';
import '../features/map_discovery/presentation/screens/map_screen.dart';

// Reviews
import '../features/reviews/presentation/screens/rate_host_screen.dart';

// Promotion
import '../features/promotion/presentation/screens/promotion_screen.dart';

// Payments
import '../features/payments/presentation/screens/payment_success_screen.dart';
import '../features/payments/presentation/screens/add_payment_screen.dart';

// Search
import '../features/search/presentation/screens/search_screen.dart';

// Favorites
import '../features/favorites/presentation/screens/favorites_screen.dart';

// Admin & Business
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/admin_experiences_screen.dart';
import '../features/business/presentation/screens/business_registration_screen.dart';

// Host Verification
import '../features/host_verification/presentation/screens/host_verification_screen.dart';
import '../features/host_verification/presentation/screens/steps/pending_step.dart';

/// A Listenable that notifies when any auth-related state changes
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    // Listen to Firebase auth state
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    // Listen to real-time user document (includes role/ban status)
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
}

/// Global navigator key used by NotificationService for deep-link
/// navigation when the user taps a push notification while the app
/// is in the background or terminated state.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Provider for GoRouter configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final refreshListenable = RouterRefreshListenable(ref);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isLoggedIn =
          authState.whenData((user) => user != null).value ?? false;
      final location = state.matchedLocation;

      // Routes accessible without being logged in
      final isPublicAuthRoute = location == '/' ||
          location == '/onboarding' ||
          location == '/welcome' ||
          location == '/login' ||
          location == '/signup';

      // Routes for logged-in but unverified users
      final isVerificationRoute =
          location == '/verify-email' || location == '/verify-success';

      // Redirect unauthenticated users to onboarding
      if (!isLoggedIn && !isPublicAuthRoute) {
        return '/onboarding';
      }

      // For logged-in users: check email verification
      if (isLoggedIn) {
        final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
        final isEmailVerified = fbUser?.emailVerified ?? false;

        // If on splash/welcome/onboarding, redirect based on verification
        if (location == '/' ||
            location == '/welcome' ||
            location == '/onboarding') {
          return isEmailVerified ? '/home' : '/verify-email';
        }

        // If verified but on verification routes, go to home
        if (isEmailVerified && isVerificationRoute) {
          return '/home';
        }

        // If NOT verified and trying to access app routes, go to verify
        if (!isEmailVerified && !isVerificationRoute && !isPublicAuthRoute) {
          return '/verify-email';
        }

        // Check for ban status
        final userEntity = ref.watch(currentUserProvider).value;
        if (userEntity != null && userEntity.isBanned) {
          if (location != '/banned') {
            return '/banned';
          }
        } else if (location == '/banned') {
          // If not banned but on banned screen, go home
          return '/home';
        }
      }

      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/verify-success',
        builder: (context, state) => const VerifySuccessScreen(),
      ),
      GoRoute(
        path: '/banned',
        builder: (context, state) {
          final user = ref.read(currentUserProvider).value;
          return BannedScreen(reason: user?.banReason);
        },
      ),

      // Main app with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // Home route (Default)
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Discover route
          GoRoute(
            path: '/discover',
            builder: (context, state) => const MapScreen(),
          ),

          // Community route (navbar tab)
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityScreen(),
          ),

          // Profile route
          GoRoute(
            path: '/profile',
            builder: (context, state) {
              final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
              return ProfileScreen(
                userId: currentUser?.uid ?? '',
                isCurrentUser: true,
                onEditPressed: () => context.push('/edit-profile'),
              );
            },
          ),

          // Notifications route
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          // Admin Dashboard route
          GoRoute(
            path: '/admin-dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          
          // Admin Experiences route
          GoRoute(
            path: '/admin/experiences',
            builder: (context, state) => const AdminExperiencesScreen(),
          ),

          // Business Registration route
          GoRoute(
            path: '/business-registration',
            builder: (context, state) => const BusinessRegistrationScreen(),
          ),
          // Host Dashboard route
          GoRoute(
            path: '/host-dashboard',
            builder: (context, state) {
              // HostDashboardScreen requires host details passed via extra.
              final extra = state.extra as Map<String, dynamic>?;
              return HostDashboardScreen(
                hostId: extra?['hostId'] ?? '',
                hostName: extra?['hostName'] ?? '',
                hostPhotoUrl: extra?['hostPhotoUrl'],
                isSuperhost: extra?['isSuperhost'] ?? false,
              );
            },
          ),
          // Create Experience route
          GoRoute(
            path: '/create-experience',
            builder: (context, state) => const CreateExperienceScreen(),
          ),
          // Host Verification routes
          GoRoute(
            path: '/host-verification',
            builder: (context, state) => const HostVerificationScreen(),
          ),
          GoRoute(
            path: '/host-verification-pending',
            builder: (context, state) => const HostVerificationPendingScreen(),
          ),
          // Host Calendar route
          GoRoute(
            path: '/host-calendar',
            builder: (context, state) => const HostCalendarScreen(),
          ),
          // Seeker Dashboard route
          GoRoute(
            path: '/seeker-dashboard',
            builder: (context, state) => const SeekerDashboardScreen(),
          ),
        ],
      ),

      // Legal routes
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const LegalContentScreen(
          type: LegalContentType.privacyPolicy,
        ),
      ),
      GoRoute(
        path: '/terms-of-service',
        builder: (context, state) => const LegalContentScreen(
          type: LegalContentType.termsOfService,
        ),
      ),

      // Edit Profile route (Full screen)
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
          return EditProfileScreen(
            userId: currentUser?.uid ?? '',
          );
        },
      ),

      // Experience routes
      GoRoute(
        path: '/experience/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExperienceDetailScreen(experienceId: id);
        },
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          // BookingScreen requires additional params beyond experienceId.
          // These should be passed via GoRouter extra or query parameters.
          final extra = state.extra as Map<String, dynamic>?;
          return BookingScreen(
            experienceId: id,
            experienceTitle: extra?['experienceTitle'] ?? '',
            experienceCoverImage: extra?['experienceCoverImage'] ?? '',
            hostId: extra?['hostId'] ?? '',
            totalPrice: (extra?['totalPrice'] as num?)?.toDouble() ?? 0.0,
          );
        },
      ),

      // Payment routes
      GoRoute(
        path: '/payment-success',
        builder: (context, state) {
          // PaymentSuccessScreen requires card details passed via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentSuccessScreen(
            cardholderName: extra?['cardholderName'] ?? '',
            cardLastFour: extra?['cardLastFour'] ?? '',
            expiryDate: extra?['expiryDate'] ?? '',
            cardType: extra?['cardType'] ?? '',
            hostName: extra?['hostName'] ?? '',
            onContinue: extra?['onContinue'] as VoidCallback?,
          );
        },
      ),
      GoRoute(
        path: '/add-payment',
        builder: (context, state) => const AddPaymentScreen(),
      ),

      // Host routes
      GoRoute(
        path: '/host-dashboard',
        builder: (context, state) {
          // HostDashboardScreen requires host details passed via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return HostDashboardScreen(
            hostId: extra?['hostId'] ?? '',
            hostName: extra?['hostName'] ?? '',
            hostPhotoUrl: extra?['hostPhotoUrl'],
            isSuperhost: extra?['isSuperhost'] ?? false,
          );
        },
      ),
      GoRoute(
        path: '/earnings',
        builder: (context, state) {
          // EarningsScreen requires hostId passed via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return EarningsScreen(
            hostId: extra?['hostId'] ?? '',
          );
        },
      ),

      // Mystery routes
      GoRoute(
        path: '/mystery/create',
        builder: (context, state) {
          // Always get userId from FirebaseAuth — never rely on extra
          // to avoid mystery bookings being written with empty userId.
          final extra = state.extra as Map<String, dynamic>?;
          final authUserId = fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
          final userId = (extra?['userId'] as String?)?.isNotEmpty == true
              ? extra!['userId'] as String
              : authUserId;
          return CreateMysteryScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/mystery/reveal',
        builder: (context, state) {
          // MysteryRevealScreen requires multiple params via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return MysteryRevealScreen(
            mysteryId: extra?['mysteryId'] ?? '',
            price: (extra?['price'] as num?)?.toDouble() ?? 0.0,
            experienceTitle: extra?['experienceTitle'] ?? '',
            experienceImage: extra?['experienceImage'] ?? '',
            experienceDescription: extra?['experienceDescription'] ?? '',
            dateTime: extra?['dateTime'] ?? '',
            duration: extra?['duration'] ?? '',
            location: extra?['location'] ?? '',
          );
        },
      ),

      // Chain routes
      GoRoute(
        path: '/chain/create',
        builder: (context, state) {
          // CreateChainScreen requires userId passed via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return CreateChainScreen(
            userId: extra?['userId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/chain/edit/:id',
        builder: (context, state) {
          // EditChainScreen requires a ChainEntity passed via extra.
          final chain = state.extra as ChainEntity;
          return EditChainScreen(chain: chain);
        },
      ),

      // Mood routes
      GoRoute(
        path: '/mood',
        builder: (context, state) => const MoodSelectorScreen(),
      ),
      GoRoute(
        path: '/mood/describe',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MoodDescribeScreen(
            initialMood: extra?['initialMood'],
          );
        },
      ),
      GoRoute(
        path: '/mood/results',
        builder: (context, state) => const MoodResultsScreen(),
      ),

      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post-comments/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CommentsScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/create-moment',
        builder: (context, state) => const CreateMomentScreen(),
      ),
      GoRoute(
        path: '/moment-viewer',
        builder: (context, state) {
          final moment = state.extra as Moment;
          return MomentViewerScreen(moment: moment);
        },
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) {
          // MessageListScreen requires userId and userName via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return MessageListScreen(
            userId: extra?['userId'] ?? '',
            userName: extra?['userName'] ?? 'Messages',
          );
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          // ChatScreen requires additional params via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            conversationId: id,
            otherUserName: extra?['otherUserName'] ?? '',
            currentUserId: extra?['currentUserId'] ?? '',
          );
        },
      ),

      // Activity routes
      GoRoute(
        path: '/activity',
        builder: (context, state) => const ActivityScreen(),
      ),

      // User & social routes
      GoRoute(
        path: '/followers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return FollowersScreen(
            userId: id,
            userName: extra?['userName'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/following/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return FollowingScreen(
            userId: id,
            userName: extra?['userName'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProfileScreen(userId: id);
        },
      ),

      // Experience participation routes
      GoRoute(
        path: '/join/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return JoinExperienceScreen(
            experienceId: id,
            title: extra?['title'],
          );
        },
      ),
      GoRoute(
        path: '/live/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return LiveExperienceScreen(
            experienceId: id,
            title: extra?['title'],
            participants: (extra?['participants'] as List<String>?),
          );
        },
      ),

      // Rating route
      GoRoute(
        path: '/rate/:id',
        builder: (context, state) {
          // RateHostScreen requires multiple params via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return RateHostScreen(
            hostPhotoUrl: extra?['hostPhotoUrl'] ?? '',
            hostName: extra?['hostName'] ?? '',
            experienceTitle: extra?['experienceTitle'] ?? '',
            experienceId: extra?['experienceId'] ?? state.pathParameters['id']!,
            userId: extra?['userId'] ?? '',
            userName: extra?['userName'] ?? '',
          );
        },
      ),

      // Promotion route
      GoRoute(
        path: '/promotion',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PromotionScreen(
            eventId: extra?['eventId'],
          );
        },
      ),

      // Settings route
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Search route
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),

      // Favorites route
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
    ],
  );
});

/// Main scaffold widget with bottom navigation
class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final unreadCountAsync = ref.watch(unreadNotificationsCountProvider);

    // Phase 7: Keep FCM token in sync with auth state changes
    ref.watch(fcmTokenSyncProvider);

    int getSelectedIndex() {
      if (location.startsWith('/home')) return 0;
      if (location.startsWith('/discover')) return 1;
      if (location.startsWith('/community')) return 2;
      if (location.startsWith('/profile')) return 3;
      if (location.startsWith('/notifications')) return 4;
      return 0;
    }

    void onNavTap(int index) {
      switch (index) {
        case 0:
          context.go('/home');
          break;
        case 1:
          context.go('/discover');
          break;
        case 2:
          context.go('/community');
          break;
        case 3:
          context.go('/profile');
          break;
        case 4:
          context.go('/notifications');
          break;
      }
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getSelectedIndex(),
        onTap: onNavTap,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Discover',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Community',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: unreadCountAsync.when(
                data: (count) => count > 0 ? Text(count.toString()) : null,
                loading: () => null,
                error: (_, __) => null,
              ),
              isLabelVisible: unreadCountAsync.when(
                data: (count) => count > 0,
                loading: () => false,
                error: (_, __) => false,
              ),
              child: const Icon(Icons.notifications_none_outlined),
            ),
            activeIcon: Badge(
              label: unreadCountAsync.when(
                data: (count) => count > 0 ? Text(count.toString()) : null,
                loading: () => null,
                error: (_, __) => null,
              ),
              isLabelVisible: unreadCountAsync.when(
                data: (count) => count > 0,
                loading: () => false,
                error: (_, __) => false,
              ),
              child: const Icon(Icons.notifications),
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Placeholder stub classes for screens that don't have implementations yet
// =============================================================================

/// WelcomeScreen - No implementation file found yet
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Welcome')));
}