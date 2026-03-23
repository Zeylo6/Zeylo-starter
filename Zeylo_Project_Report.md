# Zeylo Project Implementation Report

---

## Chapter 1: Implementation

### 1.1 Chapter Overview

This chapter provides a comprehensive overview of the implementation phase of the Zeylo platform — a peer-to-peer experience discovery mobile application. It covers the technology selections, backend and frontend architecture, AI/ML integration, deployment strategies, Git version control practices, and CRUD operations implemented across the system. The implementation follows modern software engineering best practices including clean architecture, state management patterns, serverless deployment, and secure payment processing.

---

### 1.2 Overview of the Implemented Prototype

Zeylo is a mobile application designed to help people discover and book authentic local experiences hosted by individuals. The platform creates a personal and community-driven space where hosts can share unique local experiences, users can discover activities based on mood, category, or location, and payments are handled securely through Stripe.

#### Key Implemented Features:

**User Management**
- User registration and login with Firebase Authentication
- Support for both hosts and seekers with role-based access control
- Profile management with avatar upload via Cloudinary
- Email verification and password reset functionality
- Google Sign-In integration
- Admin user management with ban/warning capabilities

**Experience Discovery**
- Search and filter by category, date, price, and location
- Interactive map view using Google Maps and Flutter Map
- Mood-based filtering with AI-enhanced descriptions
- AI-assisted search suggestions via Gemini/OpenRouter
- Category chip-based filtering system
- Experience detail pages with host info, reviews, and booking

**Booking System**
- Date and time selection with calendar integration
- Real-time availability checking
- Guest count selection
- QR code for booking confirmation
- Booking status tracking (pending, confirmed, rejected)
- Host and seeker dashboards

**Payment System**
- Secure Stripe payment gateway integration
- Payment processed after booking confirmation
- Refund processing capability
- Webhook handling for payment events
- No card details stored in the system

**Ratings and Reviews**
- Hosts and seekers can rate each other
- Review helpfulness voting system
- Review reporting functionality
- Average rating calculations
- Review count badges

**Community Features**
- Community posts feed with likes and comments
- Moments (stories) feature
- Suggested explorers
- Share functionality via share_plus
- In-app messaging system with real-time chat

**AI-Powered Features**
- Text enhancement for mood descriptions and experience descriptions
- Mystery experience matching using AI ranking
- Chain (itinerary) generation from real Firestore candidates
- OpenRouter as primary AI with Gemini fallback

**Mystery & Chain Experiences**
- Mystery surprise experience generation
- Chain itinerary creation (half-day, full-day, weekend)
- AI-powered experience matching and curation

**Admin Dashboard**
- Overview statistics
- Business approval management
- Host verification management
- User reports handling
- User management with ban/warning capabilities

**Notifications**
- Firebase Cloud Messaging (FCM) push notifications
- In-app notification feed
- Booking notifications for hosts and seekers
- Community interaction notifications

---

### 1.3 Technology Selections

#### Technology Stack Overview

| Layer | Technology | Justification |
|-------|------------|---------------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile development for iOS and Android from a single codebase. Rich widget ecosystem and excellent performance. |
| **State Management** | Flutter Riverpod | Reactive state management with compile-time safety, dependency injection, and excellent testing support. |
| **Routing** | GoRouter | Declarative routing with deep linking support, auth guards, and shell routes for bottom navigation. |
| **Backend Runtime** | Node.js | Lightweight, event-driven runtime perfect for API servers and serverless functions. |
| **Backend Framework** | Express.js v5 | Minimal, flexible web framework with extensive middleware ecosystem. |
| **Database** | Firebase Firestore | NoSQL document database with real-time sync, offline support, and automatic scaling. |
| **Authentication** | Firebase Auth | Secure authentication with email/password, Google Sign-In, and email verification. |
| **File Storage** | Firebase Storage + Cloudinary | Firebase for app assets, Cloudinary for optimized image delivery and transformations. |
| **Payments** | Stripe | Industry-leading payment processing with PCI compliance, webhooks, and refund support. |
| **AI Services** | Google Gemini AI + OpenRouter | Gemini for structured AI tasks, OpenRouter for enhanced text processing with fallback support. |
| **Push Notifications** | Firebase Cloud Messaging (FCM) | Cross-platform push notification delivery for iOS and Android. |
| **Maps** | Google Maps Flutter + Flutter Map | Dual map support for enhanced location features and fallback options. |
| **Email** | Nodemailer (Gmail SMTP) | Automated email sending for admin warnings and notifications. |
| **Deployment** | Netlify Functions (Serverless) | Zero-config serverless deployment with automatic scaling and CDN distribution. |
| **Version Control** | Git + GitHub | Distributed version control with collaborative workflows and CI/CD integration. |

#### Justifications:

**Flutter for Frontend**
- Single codebase for iOS and Android reduces development time by ~50%
- Hot reload enables rapid UI iteration during development
- Rich widget library provides Material Design components out of the box
- Strong typing with Dart catches errors at compile time
- Excellent performance with native compilation

**Firebase Ecosystem**
- Firestore provides real-time data synchronization essential for chat and notifications
- Firebase Auth handles secure authentication with minimal boilerplate
- Firebase Storage integrates seamlessly with the Firebase ecosystem
- Offline support improves user experience in low-connectivity areas
- Automatic scaling handles traffic spikes without manual intervention

**Stripe for Payments**
- PCI DSS Level 1 compliance ensures payment security
- Webhook system enables real-time payment event processing
- Comprehensive API supports payment intents, refunds, and subscriptions
- Strong documentation and developer tools

**Node.js + Express.js for Backend**
- JavaScript/TypeScript consistency across frontend and backend
- Lightweight and fast for API workloads
- Extensive npm ecosystem for middleware and utilities
- Easy serverless deployment with serverless-http wrapper

**Riverpod for State Management**
- Compile-time safety prevents runtime state errors
- Dependency injection simplifies testing and modularity
- StreamProvider enables reactive Firebase integration
- Provider scoping prevents unnecessary rebuilds

---

### 1.4 Implementation of the Backend Component

#### Backend Architecture

The backend follows a modular Express.js architecture deployed as Netlify Functions for serverless operation.

**Project Structure:**
```
backend/
├── src/
│   ├── index.js              # Main Express app entry point
│   ├── config/
│   │   └── firebase.js       # Firebase Admin SDK initialization
│   ├── controllers/
│   │   ├── adminController.js    # Admin actions (ban, warn, delete)
│   │   ├── aiController.js       # AI enhancement and generation
│   │   ├── communityController.js # Community notifications
│   │   ├── paymentController.js  # Stripe payment processing
│   │   ├── surprises.js          # Mystery experience generation
│   │   └── userController.js     # User FCM token management
│   ├── middleware/
│   │   └── auth.js               # JWT token verification
│   ├── routes/
│   │   └── api.js                # API route definitions
│   └── services/
│       ├── communityService.js   # Community data operations
│       ├── emailService.js       # Email sending via Nodemailer
│       ├── firestoreService.js   # Firestore queries with geohash
│       ├── geminiService.js      # Google Gemini AI integration
│       ├── notificationService.js # FCM push notifications
│       ├── openRouterService.js  # OpenRouter AI integration
│       └── stripeService.js      # Stripe payment operations
├── functions/
│   └── api.js                    # Netlify Functions wrapper
├── netlify.toml                  # Netlify deployment configuration
└── package.json                  # Dependencies and scripts
```

#### Key Backend Components:

**1. Firebase Configuration (`config/firebase.js`)**
- Initializes Firebase Admin SDK with service account credentials
- Supports multiple initialization methods: environment variable, service account file, or Application Default Credentials
- Exports Firestore database and Auth instances for use across services

**2. Authentication Middleware (`middleware/auth.js`)**
- Verifies Firebase ID tokens from Authorization headers
- Extracts decoded user information and attaches to request object
- Returns 401 Unauthorized for missing or invalid tokens

**3. API Routes (`routes/api.js`)**
- Health check endpoint: `GET /api/health`
- Surprises: `POST /api/surprises/generate` (protected)
- Admin: `POST /api/admin/send-warning-email`, `/ban-user`, `/delete-experience` (protected)
- AI: `POST /api/ai/enhance`, `/chain/generate`, `/mystery/generate`, `/mystery/match-and-book` (protected)
- Users: `POST /api/users/fcm-token` (protected)
- Payments: `POST /api/payments/create-intent`, `/refund`, `/webhook`
- Community: `POST /api/community/notify-like`, `/notify-comment` (protected)

**4. Payment Controller (`controllers/paymentController.js`)**
- Creates Stripe Payment Intents with metadata (bookingId, type)
- Handles Stripe webhooks for payment_intent.succeeded events
- Updates Firestore booking status on successful payment
- Processes refunds and updates booking/payment status
- Sends push notifications to hosts on booking confirmation

**5. AI Controller (`controllers/aiController.js`)**
- Text enhancement with OpenRouter primary and Gemini fallback
- Chain generation: queries Firestore for real experiences, sends candidates to AI, returns curated itinerary
- Mystery generation: matches user preferences to experiences using AI ranking
- Mystery booking: creates Firestore bookings and sends notifications

**6. Notification Service (`services/notificationService.js`)**
- Centralized FCM push notification delivery
- Creates in-app activity records in Firestore
- Supports host booking notifications and seeker booking updates

**7. Stripe Service (`services/stripeService.js`)**
- Creates Payment Intents with amount conversion to cents
- Processes refunds via Stripe API
- Handles currency and metadata configuration

**8. Firestore Service (`services/firestoreService.js`)**
- Geohash-based location queries using ngeohash library
- Surprise experience matching with budget and location constraints
- Random candidate selection for mystery experiences

**9. Email Service (`services/emailService.js`)**
- Gmail SMTP configuration with Nodemailer
- Styled HTML email templates for community guideline warnings
- Supports custom warning reasons and details

#### Serverless Deployment

The backend is deployed as Netlify Functions using the serverless-http wrapper:
- `netlify.toml` configures build command and function directory
- All routes redirect to `/.netlify/functions/api/:splat`
- Express app is wrapped with `serverless-http` for Lambda compatibility

---

### 1.5 Implementation of the Frontend Component

#### Frontend Architecture

The Flutter frontend follows a feature-based clean architecture with clear separation of concerns.

**Project Structure:**
```
zeylo/lib/
├── main.dart                    # App entry point with Firebase/Stripe init
├── app.dart                     # MaterialApp configuration
├── firebase_options.dart        # Firebase platform configuration
├── core/
│   ├── config/app_config.dart       # App-level configuration
│   ├── constants/                   # App, asset, and Firebase constants
│   ├── discovery/                   # Discovery utilities
│   ├── errors/                      # Custom exceptions and failures
│   ├── network/                     # Network connectivity checking
│   ├── services/                    # Core services (AI, API, Cloudinary, Location, Notifications, Stripe)
│   ├── theme/                       # App colors, typography, spacing, shadows, radius
│   ├── usecases/                    # Base use case abstraction
│   └── widgets/                     # Reusable UI components
├── features/
│   ├── auth/                        # Authentication (login, signup, verification)
│   ├── home/                        # Home screen with experiences feed
│   ├── experience/                  # Experience detail and info sections
│   ├── booking/                     # Booking flow and seeker dashboard
│   ├── host/                        # Host dashboard, earnings, calendar, create experience
│   ├── mystery/                     # Mystery surprise experience creation and reveal
│   ├── chain/                       # Chain itinerary creation and editing
│   ├── mood/                        # Mood-based experience discovery
│   ├── community/                   # Posts, moments, comments, suggested users
│   ├── messaging/                   # Chat and message list
│   ├── activity/                    # Activity feed
│   ├── profile/                     # User profile, edit, followers, settings
│   ├── notifications/               # Notification screen and providers
│   ├── map_discovery/               # Map-based experience discovery
│   ├── reviews/                     # Rating and review system
│   ├── payments/                    # Payment success and add payment screens
│   ├── search/                      # Search functionality
│   ├── favorites/                   # Favorites management
│   ├── admin/                       # Admin dashboard with tabs
│   ├── business/                    # Business registration
│   ├── host_verification/           # Host verification flow
│   ├── onboarding/                  # Onboarding screens
│   └── promotion/                   # Promotion features
└── routes/
    └── app_router.dart              # GoRouter configuration with auth guards
```

#### Key Frontend Components:

**1. Main Entry Point (`main.dart`)**
- Initializes Firebase, Stripe, and NotificationService
- Sets preferred orientations and system UI overlay styles
- Configures Stripe publishable key
- Wraps app in ProviderScope for Riverpod state management
- Sets up deep-link navigation for push notifications

**2. Routing (`routes/app_router.dart`)**
- GoRouter with auth state-based redirects
- Shell routes for bottom navigation (Home, Discover, Community, Profile, Notifications)
- Route guards for email verification and ban status
- Global navigator key for notification deep-linking
- Comprehensive route definitions for all app screens

**3. Authentication (`features/auth/`)**
- Login screen with email/password and Google Sign-In
- Signup with role selection (host/seeker)
- Email verification flow with resend capability
- Password reset via Firebase Auth
- Riverpod providers for auth state management
- User entity with role, ban status, and profile data

**4. Home Screen (`features/home/`)**
- Category chip filtering system
- Experience cards with favorite toggle
- Speed dial FAB for Create Experience, Create Chain, and Surprise Me
- Pull-to-refresh support
- Role capsule indicator
- Message host integration

**5. Experience Detail (`features/experience/`)**
- Cover image with favorite and back buttons
- Host info card with rating
- What's Included and Requirements sections
- Reviews section with helpful voting and reporting
- Book Now button with navigation to booking screen

**6. Booking Flow (`features/booking/`)**
- Guest information form with validation
- Date and time picker widgets
- Guest count selector
- Booking summary card
- Stripe payment integration via StripePaymentService
- Form state management with Riverpod

**7. Host Dashboard (`features/host/`)**
- Experience management
- Earnings tracking
- Calendar management
- Create experience with form validation

**8. Mystery Experience (`features/mystery/`)**
- Mystery creation with preferences (budget, location, vibe)
- AI-powered mystery reveal with teaser content
- Mystery booking flow

**9. Chain Experience (`features/chain/`)**
- Chain creation with AI itinerary generation
- Chain editing with drag-and-drop reordering
- Time slot management

**10. Mood Discovery (`features/mood/`)**
- Mood selector with visual chips
- AI-enhanced mood description
- Mood-based experience results

**11. Community (`features/community/`)**
- Posts feed with likes and comments
- Moments (stories) bar
- Suggested explorers
- Create post and moment screens
- Share functionality

**12. Messaging (`features/messaging/`)**
- Real-time chat with Firestore streams
- Message list with unread indicators
- Conversation creation and management

**13. Admin Dashboard (`features/admin/`)**
- Overview statistics tab
- Business approvals tab
- Host verification tab
- User reports tab
- User management tab
- Responsive sidebar for desktop/mobile

**14. Theme System (`core/theme/`)**
- AppColors: Primary purple (#8B5CF6), semantic colors, gradients
- AppTypography: Inter font family with display, headline, title, body, and label styles
- AppSpacing: Consistent spacing scale (xs=4, sm=8, md=12, lg=16, xl=24, xxl=32, xxxl=48, huge=64)
- AppRadius: Border radius scale (sm=4, md=8, lg=12, xl=16, xxl=24, full=999)
- AppShadows: Elevation shadow definitions

**15. Core Services (`core/services/`)**
- AIService: Abstract interface for AI operations
- ApiAIService: HTTP client for backend AI endpoints
- CloudinaryService: Image upload and URL transformation
- LocationService: Geolocation and geocoding
- NotificationService: FCM token management and notification handling
- StripePaymentService: Stripe payment sheet presentation
- MockAIServiceImpl: Mock implementation for testing

---

### 1.6 Implementation of the Data Science / AI Component

#### AI Integration Architecture

The Zeylo platform integrates AI services for three primary use cases:

**1. Text Enhancement**
- **Purpose**: Improve user-written descriptions for moods, experiences, and chain itineraries
- **Primary Service**: OpenRouter (enhanced text processing)
- **Fallback Service**: Google Gemini AI
- **Contexts Supported**:
  - `mood`: Emotional intelligence writing assistant for mood descriptions
  - `host_experience`: Marketing copywriter for experience descriptions
  - `chain_itinerary`/`chain_description`: Travel planner for itinerary descriptions
  - `business_review`: Business compliance AI for verification text
  - `general`: Generic grammar and clarity improvement

**2. Chain (Itinerary) Generation**
- **Purpose**: Generate curated day-long experience chains from real Firestore data
- **Process**:
  1. Query Firestore for active experiences matching location and interests
  2. Send compact candidate list to AI with user preferences
  3. AI selects 2-4 experiences and assigns time slots
  4. Return structured chain with start/end times
- **Fallback**: Manual random selection with time slot assignment if AI fails

**3. Mystery Experience Matching**
- **Purpose**: Match seeker preferences to the best experience using AI ranking
- **Process**:
  1. Query active experiences matching budget and location
  2. Send candidates and user preferences to AI
  3. AI ranks candidates by match quality
  4. Generate mystery teaser (title, description, vibe, preparation notes)
  5. Return matched experience ID with teaser content

#### AI Service Implementation

**Gemini Service (`geminiService.js`)**
- Uses `@google/generative-ai` package with `gemini-2.0-flash` model
- Markdown fence stripping for clean JSON parsing
- Context-aware system instructions for different use cases
- Structured JSON output with schema validation

**OpenRouter Service (`openRouterService.js`)**
- HTTP-based API integration for enhanced text processing
- Primary AI provider with Gemini as fallback
- Same context-aware prompting as Gemini

---

### 1.7 GIT Repository

#### Repository Information
- **Repository URL**: https://github.com/Zeylo6/Zeylo-starter.git
- **Version Control System**: Git
- **Hosting Platform**: GitHub

#### Git Practices
- `.gitignore` configured to exclude:
  - `node_modules/` (backend dependencies)
  - `build/` (Flutter build artifacts)
  - `.dart_tool/` (Dart tooling cache)
  - `service-account.json` (Firebase credentials)
  - Environment files (`.env`)
  - IDE-specific files
  - Platform-specific build directories

#### Repository Structure
The repository is organized as a monorepo containing both the Flutter frontend (`zeylo/`) and Node.js backend (`backend/`), along with documentation files at the root level:
- `README.md` — Project overview and feature documentation
- `Backend running guide.md` — Backend setup instructions
- `FEATURE_FILES_CREATED.md` — Feature implementation tracking
- `FILE_INDEX.md` — Complete file listing
- `PULL_REQUEST_NOTES.md` — PR guidelines and notes
- `RBAC Implementation draft convo.md` — Role-based access control design
- `ZeyLo Backend Development Plan.md` — Backend development roadmap

---

### 1.8 Deployments / CI-CD Pipeline

#### Backend Deployment (Netlify)

The backend is deployed as **Netlify Functions** using serverless architecture:

**Configuration (`netlify.toml`)**:
```toml
[build]
  command = "npm install"
  functions = "functions"
  publish = "."

[[redirects]]
  from   = "/*"
  to     = "/.netlify/functions/api/:splat"
  status = 200
  force  = true
```

**Deployment Process**:
1. Netlify automatically detects the `netlify.toml` configuration
2. Runs `npm install` to install backend dependencies
3. Packages the Express app as a serverless function using `serverless-http`
4. All API routes are served through `/.netlify/functions/api/`
5. Automatic SSL/TLS certificate provisioning
6. Global CDN distribution for low-latency API responses

**Environment Variables** (configured in Netlify dashboard):
- `FIREBASE_SERVICE_ACCOUNT` — Base64-encoded Firebase service account JSON
- `GEMINI_API_KEY` — Google Gemini AI API key
- `STRIPE_SECRET_KEY` — Stripe secret key for payment processing
- `STRIPE_WEBHOOK_SECRET` — Stripe webhook signature verification
- `STRIPE_PUBLISHABLE_KEY` — Stripe publishable key
- `EMAIL_USER` — Gmail address for sending emails
- `EMAIL_APP_PASSWORD` — Gmail app password for SMTP

#### Frontend Deployment

**Web Deployment**:
- Firebase Hosting serves the Flutter web build
- Web assets configured in `zeylo/web/` directory
- `firebase.json` defines hosting configuration

**Mobile Deployment**:
- Android: Standard Flutter build with `zeylo/android/` configuration
- iOS: Standard Flutter build with `zeylo/ios/` configuration
- Firebase configuration via `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

---

### 1.9 CRUD Operations

This section details the CRUD (Create, Read, Update, Delete) operations implemented across the Zeylo platform, organized by feature area.

#### User Management CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | User registration with email/password or Google Sign-In | `auth_provider.dart` — `signUpWithEmail()`, `signInWithGoogle()` |
| **Read** | Fetch current user profile and auth state | `auth_provider.dart` — `currentUserProvider` (StreamProvider from Firestore) |
| **Update** | Update profile (name, photo, bio, phone) | `edit_profile_screen.dart` — Profile update form |
| **Delete** | Account deletion (admin-initiated ban) | `adminController.js` — `banUser()` |

#### Experience CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | Host creates new experience | `create_experience_screen.dart` — Experience creation form |
| **Read** | Fetch experiences list and detail | `home_provider.dart` — `experiencesByFilterProvider`, `experienceDetailProvider` |
| **Update** | Host updates experience details | Host dashboard experience management |
| **Delete** | Admin deletes experience | `adminController.js` — `deleteExperience()` |

#### Booking CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | Seeker creates booking with payment | `booking_screen.dart` — `_submitBooking()` with Stripe integration |
| **Read** | Fetch user bookings (host/seeker) | `booking_provider.dart` — Booking list providers |
| **Update** | Update booking status (confirm/reject) | `paymentController.js` — Webhook updates booking status |
| **Delete** | Cancel booking with refund | `paymentController.js` — `refundBooking()` |

#### Review CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | Seeker submits review after experience | `rate_host_screen.dart` — Review submission |
| **Read** | Fetch experience reviews | `review_provider.dart` — `experienceReviewsProvider` |
| **Update** | Toggle helpful vote on review | `review_repository.dart` — `toggleHelpful()` |
| **Delete** | Report review to host | `experience_detail_screen.dart` — `reportReview()` |

#### Community Post CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | User creates community post | `create_post_screen.dart` — Post creation form |
| **Read** | Fetch community posts feed | `community_provider.dart` — `communityPostsProvider` |
| **Update** | Like/unlike post | `community_screen.dart` — `_toggleLike()` |
| **Delete** | Delete post (user-initiated) | Post deletion in community service |

#### Moment (Story) CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | User creates moment | `create_moment_screen.dart` — Moment creation |
| **Read** | Fetch moments bar | `moments_bar.dart` — Moments list |
| **Update** | View moment (mark as viewed) | `moment_viewer_screen.dart` — View tracking |
| **Delete** | Auto-expire after 24 hours | Firestore TTL or manual cleanup |

#### Message CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | Send message in conversation | `chat_screen.dart` — Message sending |
| **Read** | Fetch conversations and messages | `messaging_provider.dart` — Conversation and message streams |
| **Update** | Mark messages as read | Read receipt functionality |
| **Delete** | Delete conversation | Conversation deletion |

#### Notification CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | Generate activity/notification | `notificationService.js` — Creates Firestore activity records |
| **Read** | Fetch user notifications | `notifications_provider.dart` — Notification stream |
| **Update** | Mark notification as read | Notification read status update |
| **Delete** | Clear old notifications | Notification cleanup |

#### Admin Operations CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | Send warning email to user | `adminController.js` — `sendWarning()` |
| **Read** | Fetch users, reports, businesses | Admin dashboard tabs |
| **Update** | Ban user, approve business/host | `adminController.js` — `banUser()`, approval flows |
| **Delete** | Delete reported experience | `adminController.js` — `deleteExperience()` |

#### Mystery Experience CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | Generate mystery experience | `aiController.js` — `generateSurprise()` |
| **Read** | Fetch mystery details | `mystery_reveal_screen.dart` — Mystery reveal |
| **Update** | Accept/reject mystery booking | Mystery booking status update |
| **Delete** | Cancel mystery booking | Booking cancellation with refund |

#### Chain Experience CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | Generate chain itinerary | `aiController.js` — `generateChain()` |
| **Read** | Fetch chain details | Chain detail screen |
| **Update** | Edit chain experiences | `edit_chain_screen.dart` — Chain editing |
| **Delete** | Delete chain | Chain deletion |

#### Favorites CRUD

| Operation | Description | Implementation |
|-----------|-------------|----------------|
| **Create** | Add experience to favorites | `favorites_provider.dart` — `toggleFavorite()` |
| **Read** | Fetch user favorites | `favorites_provider.dart` — Favorites list |
| **Update** | Toggle favorite status | Favorite toggle with snackbar feedback |
| **Delete** | Remove from favorites | `toggleFavorite()` with unfavorite action |

---

## Summary

The Zeylo platform has been successfully implemented as a full-stack mobile application with:

- **Flutter frontend** featuring 15+ feature modules with clean architecture
- **Node.js backend** deployed as serverless Netlify Functions
- **Firebase ecosystem** for database, authentication, storage, and notifications
- **Stripe integration** for secure payment processing
- **AI-powered features** using Gemini and OpenRouter for enhanced user experience
- **Comprehensive CRUD operations** across all major feature areas
- **Role-based access control** supporting hosts, seekers, and admins
- **Real-time features** including chat, notifications, and live data sync

The implementation follows modern software engineering practices including dependency injection, state management with Riverpod, declarative routing, and serverless deployment patterns.

---

*Report Generated: March 2026*
*Project: Zeylo — Peer-to-Peer Experience Discovery App*
*Module: Software Development Group Project (SDGP)*
*Institution: Informatics Institute of Technology (IIT)*
*Partner: University of Westminster*