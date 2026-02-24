# Zeylo - Local Experiences Platform

Zeylo is a community-driven platform for discovering, sharing, and booking local experiences. Connect with local hosts, explore authentic activities, and create unforgettable memories in destinations around the world.

## Overview

Built with Flutter and Firebase, Zeylo enables users to:
- Discover authentic local experiences from verified hosts
- Browse by category, mood, or location using advanced search and mapping
- Book experiences seamlessly with integrated payments
- Connect with hosts and other travelers
- Share experiences through community features
- Manage bookings and favorite experiences

## Prerequisites

Before getting started, ensure you have the following installed:

- **Flutter 3.19+** (stable channel) - [Download](https://flutter.dev/docs/get-started/install)
- **Dart 3.3+** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extension
- **Firebase CLI** - Install via `npm install -g firebase-tools`
- **FlutterFire CLI** - Install via `dart pub global activate flutterfire_cli`
- **Xcode 15+** (for iOS development)
- **Android SDK 24+** (for Android development)

Verify installation:
```bash
flutter --version
dart --version
firebase --version
```

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/zeylo.git
cd zeylo
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

The project uses code generation for models and serialization. Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a new project"
3. Name it "Zeylo"
4. Enable Google Analytics (optional)
5. Create the project

### 2. Enable Required Services

In your Firebase project, enable these services:

#### Authentication
- Go to **Build > Authentication**
- Click "Get started"
- Enable sign-in methods:
  - **Email/Password** - Enable
  - **Google** - Enable (provide OAuth credentials)
  - **Apple** - Enable (iOS only)

#### Firestore Database
- Go to **Build > Firestore Database**
- Click "Create database"
- Start in **test mode** (for development)
- Choose region (us-central1 recommended)

#### Firebase Storage
- Go to **Build > Storage**
- Click "Get started"
- Use default bucket settings

#### Cloud Messaging
- Go to **Engage > Messaging**
- No setup needed at this stage, will be configured during app setup

#### Firestore Security Rules

Once Firestore is created, replace the default rules with these security rules:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read all public data
    match /categories/{document=**} {
      allow read: if request.auth != null;
    }

    match /experiences/{document=**} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.hostId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.hostId;
    }

    match /users/{userId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }

    match /bookings/{bookingId} {
      allow read, create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow read: if request.auth != null && request.auth.uid == resource.data.hostId;
      allow update: if request.auth != null && (request.auth.uid == resource.data.userId || request.auth.uid == resource.data.hostId);
    }

    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }

    match /conversations/{conversationId} {
      allow read: if request.auth != null && (request.auth.uid in resource.data.participants);
      allow create: if request.auth != null;
      allow update: if request.auth != null && (request.auth.uid in resource.data.participants);
    }

    match /messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.senderId;
      allow delete: if request.auth != null && request.auth.uid == resource.data.senderId;
    }

    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 3. Download Service Configuration Files

#### Android
1. In Firebase Console, go to **Project settings**
2. Click "Add app" and select Android
3. Enter package name: `com.example.zeylo`
4. Download `google-services.json`
5. Place in `android/app/`

#### iOS
1. In Firebase Console, go to **Project settings**
2. Click "Add app" and select iOS
3. Enter bundle ID: `com.example.zeylo`
4. Download `GoogleService-Info.plist`
5. Place in `ios/Runner/`

### 4. Configure FlutterFire

Run the FlutterFire CLI to automatically configure both platforms:

```bash
flutterfire configure
```

This will:
- Detect your Firebase project
- Generate `lib/firebase_options.dart`
- Configure Android and iOS settings

## Google Maps Setup

### 1. Enable Google Maps API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create or select a project
3. Enable these APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**

### 2. Create API Keys

1. Go to **Credentials**
2. Click "Create Credentials" > "API Key"
3. Restrict to **Android** apps, add package name fingerprint
4. Copy the Android API key
5. Repeat for **iOS** apps with bundle ID

### 3. Add API Keys to App

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_API_KEY_HERE" />
```

#### iOS (ios/Runner/AppDelegate.swift)
```swift
import GoogleMaps

override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
  GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
  GeneratedPluginRegistrant.register(with: self)
  return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

## Environment Setup

Create a `.env` file in the project root:

```env
GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
FIREBASE_PROJECT_ID=zeylo
```

Add to `.gitignore`:
```
.env
.env.local
```

## Running the App

### Run on Android Emulator

```bash
flutter run
```

Or specify device:
```bash
flutter run -d emulator-5554
```

### Run on iOS Simulator

```bash
flutter run -d iphone
```

Or on physical device:
```bash
flutter run -d <device_id>
```

## Seeding Demo Data

The app includes demo data that can be seeded to Firestore for testing and development.

### Method 1: Using Debug Button

Add this code to a debug menu in your app:

```dart
import 'package:zeylo/core/seed/seed_data.dart';

// In your settings or debug screen
ElevatedButton(
  onPressed: () async {
    try {
      await SeedData.seedAll(FirebaseFirestore.instance);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo data seeded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error seeding data: $e')),
      );
    }
  },
  child: const Text('Seed Demo Data'),
)
```

### Method 2: One-time Script

Create a Dart script to seed data:

```dart
// bin/seed_data.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zeylo/core/seed/seed_data.dart';
import 'package:zeylo/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SeedData.seedAll(FirebaseFirestore.instance);
  print('Done!');
}
```

Run with:
```bash
dart bin/seed_data.dart
```

### Demo Account

After seeding, use this account to test:

**Email:** demo@zeylo.com
**Password:** Demo@123

This account includes:
- Profile with 234 followers and 189 following
- 5 favorite experiences
- 2 upcoming bookings
- 3 completed bookings
- 2 community posts

## Project Architecture

Zeylo follows **Clean Architecture** with separation of concerns:

```
lib/
├── core/                      # Core functionality
│   ├── constants/             # App constants
│   ├── errors/                # Custom exceptions and failures
│   ├── extensions/            # Dart extensions
│   ├── network/               # Network info
│   ├── seed/                  # Demo data seeding
│   ├── theme/                 # UI theme and styling
│   ├── utils/                 # Utilities (validators, formatters)
│   └── widgets/               # Global widgets
│
├── features/                  # Feature modules
│   ├── activity/              # User activity tracking
│   ├── auth/                  # Authentication
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── booking/               # Booking management
│   ├── chain/                 # Experience chains/bundles
│   ├── community/             # Social posts and interactions
│   ├── experience/            # Experience browsing and details
│   ├── favorites/             # Favorite experiences
│   ├── home/                  # Home screen and categories
│   ├── host/                  # Host management
│   ├── map_discovery/         # Map-based discovery
│   ├── messaging/             # Chat and messaging
│   ├── mood/                  # Mood-based recommendations
│   ├── mystery/               # Mystery experiences
│   ├── onboarding/            # App onboarding
│   ├── payments/              # Payment processing
│   ├── profile/               # User profiles
│   ├── promotion/             # Promotions and deals
│   ├── reviews/               # Ratings and reviews
│   └── search/                # Search functionality
│
├── main.dart                  # App entry point
└── firebase_options.dart      # Auto-generated Firebase config
```

Each feature module follows:
- **Data layer** - Repositories, data sources, models
- **Domain layer** - Entities, use cases, repository contracts
- **Presentation layer** - Screens, widgets, providers (Riverpod)

## Build for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-app.apk`

### Android App Bundle

```bash
flutter build appbundle --release
```

For internal testing:
```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

Then:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Release build configuration
3. Archive and upload to App Store Connect

## Technology Stack

### Frontend
- **Flutter 3.19+** - Cross-platform mobile framework
- **Dart 3.3+** - Programming language
- **Riverpod 2.4+** - State management
- **GoRouter 12.0+** - Navigation and routing

### Backend & Services
- **Firebase Authentication** - User authentication
- **Firestore** - Real-time database
- **Firebase Storage** - File storage for images
- **Firebase Cloud Messaging** - Push notifications

### UI & UX
- **Google Maps SDK** - Location-based features
- **Cached Network Image** - Image caching
- **Flutter Rating Bar** - Rating components
- **Shimmer** - Loading animations

### Utilities
- **Intl** - Internationalization
- **Geolocator** - Location services
- **Image Picker** - Photo selection
- **URL Launcher** - Deep linking

## Features Implemented

### Authentication & Onboarding
- Splash screen with authentication check
- Email/Password sign up and login
- Google and Apple OAuth integration
- Email verification
- Password reset
- Onboarding flow

### Home & Discovery
- Home screen with featured experiences
- Category browsing (6 categories)
- Search with filters and sorting
- Mood-based experience recommendations
- Map-based discovery
- Live experience tracking

### Experiences
- Browse all experiences
- Detailed experience pages
- Image gallery with zoom
- Ratings and reviews
- Host profiles and reviews
- Availability checking
- Experience chaining/bundles

### Booking & Payments
- Select dates and guests
- Calculate pricing
- Payment processing
- Booking confirmation
- Booking management (upcoming/past)
- Booking cancellation

### Reviews & Ratings
- Leave reviews and ratings
- View experience reviews
- Rate hosts after experiences
- User review history

### Community
- User posts and feed
- Comments and interactions
- User profiles and following
- Followers/following management
- User activity

### Messaging
- Real-time chat with hosts
- Conversation list
- Message notifications
- Typing indicators

### User Management
- Profile editing
- Photo upload
- Bio and location
- Settings management
- Privacy controls
- Notification preferences
- Account security

### Host Features
- Host dashboard
- Experience management
- Earnings tracking
- Booking management
- Host statistics
- Reviews and ratings

### Additional Features
- Favorites/Wishlist
- Activity feed
- Mystery experiences
- Promotions and offers
- Social sharing
- Offline support (cached data)

## Screens (40+)

### Authentication (5)
1. Splash Screen
2. Login Screen
3. Sign Up Screen
4. Email Verification
5. Verification Success

### Home & Discovery (5)
6. Home Screen
7. Search Screen
8. Search Results
9. Map Discovery
10. Category Browse

### Experiences (4)
11. Experience Detail
12. Experience Gallery
13. Reviews List
14. Rate Host

### Booking & Payments (4)
15. Booking Screen
16. Booking Confirmation
17. Add Payment Method
18. Payment Success

### Community (4)
19. Community Feed
20. Create Post
21. User Posts
22. Comments

### Messaging (2)
23. Message List
24. Chat Screen

### Profile & Settings (7)
25. Profile Screen
26. Edit Profile
27. Profile - Followers
28. Profile - Following
29. Settings Screen
30. Account Settings
31. Notification Settings

### Host Features (4)
32. Host Dashboard
33. Host Experiences
34. Earnings Screen
35. Booking Management

### Favorites & Activity (2)
36. Favorites Screen
37. Activity Screen

### Onboarding (1)
38. Onboarding Screen

### Special Features (3)
39. Mystery Experiences
40. Mood Selector
41. Live Experience Screen

## Code Generation

This project uses code generation for models and serialization. Generated files include:
- `*.freezed.dart` - Freezed immutable classes
- `*.g.dart` - JSON serialization

Generated files are auto-updated when you run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Troubleshooting

### Build Issues

**Gradle error on Android**
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

**iOS pod issues**
```bash
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter pub get
flutter run
```

**Firebase configuration error**
```bash
flutterfire configure --project=zeylo
```

### Common Errors

**Google Maps API key not working**
- Verify API key is enabled in Google Cloud Console
- Check package name and fingerprint match
- Ensure API key has no restrictions or correct restrictions

**Firestore rules blocking access**
- Check Firestore security rules are properly set
- Verify user is authenticated
- Check user UID in rules matches actual UID

**Push notifications not working**
- Ensure Firebase Cloud Messaging is enabled
- Check FCM token is properly saved
- Verify app has notification permissions

## Development Workflow

### Adding a New Feature

1. **Create feature directory** under `lib/features/`
2. **Structure layers**: `data/`, `domain/`, `presentation/`
3. **Define entities** in domain layer
4. **Create models** in data layer
5. **Build repositories** for data access
6. **Create use cases** for business logic
7. **Build UI screens** in presentation layer
8. **Use Riverpod** for state management
9. **Add routes** to GoRouter configuration

### Testing

```bash
flutter test
```

Run specific test:
```bash
flutter test test/features/auth/login_test.dart
```

### Code Quality

Format code:
```bash
dart format lib/
```

Analyze code:
```bash
flutter analyze
```

## Contributing

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Commit changes (`git commit -m 'Add amazing feature'`)
3. Push to branch (`git push origin feature/amazing-feature`)
4. Open Pull Request

## License

This project is licensed under the MIT License - see LICENSE.md for details.

## Support

For issues and questions:
- Check existing issues on GitHub
- Create a new issue with detailed information
- Include device info and error logs
- Describe steps to reproduce

## Team

- **Project Lead** - Flutter & Firebase architecture
- **UI/UX Design** - Mobile app design
- **Backend** - Firebase setup and rules

## Changelog

### v1.0.0 - Initial Release
- All core features implemented
- 40+ screens
- Firebase integration
- Firestore database
- Payment processing
- Real-time messaging
- Community features
- Host management

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)

---

**Happy coding! Enjoy building amazing experiences with Zeylo.**
