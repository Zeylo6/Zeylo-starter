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

// Messaging
import '../features/messaging/presentation/screens/message_list_screen.dart';
import '../features/messaging/presentation/screens/chat_screen.dart';

// Activity
import '../features/activity/presentation/screens/activity_screen.dart';

// Profile
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/followers_screen.dart';
import '../features/profile/presentation/screens/following_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';

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
import '../features/explore/presentation/screens/explore_screen.dart';

/// Provider for GoRouter configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
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
        if (!isEmailVerified &&
            !isVerificationRoute &&
            !isPublicAuthRoute) {
          return '/verify-email';
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

      // Main app with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/discover',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) {
              final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
              return ProfileScreen(
                userId: currentUser?.uid ?? '',
                isCurrentUser: true,
              );
            },
          ),
        ],
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
          // CreateMysteryScreen requires userId passed via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return CreateMysteryScreen(
            userId: extra?['userId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/mystery/reveal',
        builder: (context, state) {
          // MysteryRevealScreen requires multiple params via extra.
          final extra = state.extra as Map<String, dynamic>?;
          return MysteryRevealScreen(
            mysteryId: extra?['mysteryId'] ?? '',
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

      // Community & social routes
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityScreen(),
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
class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int getSelectedIndex() {
      if (location.startsWith('/home')) return 0;
      if (location.startsWith('/discover')) return 1;
      if (location.startsWith('/explore')) return 2;
      if (location.startsWith('/profile')) return 3;
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
          context.go('/explore');
          break;
        case 3:
          context.go('/profile');
          break;
      }
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getSelectedIndex(),
        onTap: onNavTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.link),
            activeIcon: Icon(Icons.link),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
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

