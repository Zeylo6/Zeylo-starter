# ZeyLo Backend Development Plan

**Summary:** This document outlines the backend strategy for ZeyLo, a platform for renting human experiences. It explains how our Flutter frontend will communicate with a hybrid backend consisting of Firebase (for real-time features and authentication) and a custom custom server (Node.js) for advanced business logic, AI, and payments.

**Assumptions:**
1. The custom backend will be built with Node.js and Express.js (as it is beginner-friendly).
2. Stripe provides the payment gateway.
3. OpenAI serves as the AI provider.

```text
+----------------+       +-----------------------------------+
|                |       |  Firebase                         |
|  Flutter App   |<----->|  - Authentication (Logins)        |
|  (Frontend)    |       |  - Firestore (Database)           |
|                |       |  - Cloud Functions (Triggers)     |
+-------+--------+       +-----------------------------------+
        |                               ^
        v                               |
+-------+--------+       +--------------+--------------------+
|                |       |  Third-Party Services             |
| Custom Backend |<----->|  - Stripe (Payments)              |
| (Node.js API)  |       |  - OpenAI (AI Services)           |
|                |       |  - Google Maps (Geocoding)        |
+----------------+       +-----------------------------------+
```

## 1 Overview

### What is a backend?
A backend is like the kitchen of a restaurant. While the frontend (the menu and dining area) is what the user sees and interacts with on their phone (our Flutter app), the backend is where the data is stored, processed, and secured. It handles user accounts, stores experience details, processes payments, and runs complex logic that shouldn't happen directly on a user's phone for security or performance reasons.

### The Hybrid Approach
For ZeyLo, we use a hybrid approach to get the best of both worlds:
- **Firebase:** Acts as our fast, real-time database and handles user logins securely. It's fully managed, meaning we don't have to worry about servers for these basic tasks.
- **Custom Backend:** A separate server we build (using Node.js). We use this for "heavy lifting" like talking to AI to generate experience chains or securely processing payments with Stripe. We don't want to put our secret AI keys or payment keys in the Flutter app or directly in Firebase database rules.

## 2 Core Components and Responsibilities

- **Firebase**
  - **Authentication:** Handles signing up, logging in, and resetting passwords securely.
  - **Firestore:** Our primary database. It stores users, experiences, and bookings. It's a "NoSQL" database, meaning data is stored in documents (like folders) rather than rigid tables.
  - **Cloud Functions:** Small pieces of code that run automatically when something happens in Firebase (e.g., when a booking is created, send a welcome email).
  - **Firebase Storage:** Stores files like user profile pictures and experience photos.

- **Custom Backend (Node.js + Express)**
  - Handles AI curation endpoints (e.g., matching a user's mood to an experience).
  - Generates experience chains.
  - Orchestrates the payment gateway (talking to Stripe).
  - Manages complex database queries that Firestore isn't designed for easily (like advanced text search).

- **APIs (Application Programming Interfaces)**
  - An API is how different software programs talk to each other.
  - We will use **REST (Representational State Transfer)**. REST is a simple, standard way to build APIs using web URLs. A user app asks a URL for data, and the URL returns it.
  - *(Optional: GraphQL is another way to build APIs where the frontend asks for exactly the data it wants, but REST is simpler for beginners and fits our needs well).*

- **Third-Party Services**
  - **Stripe:** For handling credit cards and paying hosts.
  - **OpenAI:** For the "AI Mood Match" and "Surprise Experiences".
  - **Google Maps API:** For geocoding (turning an address into map coordinates).

## 3 Data Models and Example Firestore Schemas

In Firestore, data is organized into **collections** (like folders), which contain **documents** (like files with specific data).

- **users:** Stores information about people using the app.
- **hosts:** Stores extra details for users who are offering experiences.
- **experiences:** The actual events or activities users can book.
- **bookings:** Records of when a user pays to attend an experience.
- **reviews:** Feedback left by users after an experience.
- **memory_capsules:** Digital mementos or photos from an experience.
- **events:** Occurrences or gatherings beyond typical experiences.
- **business_promotions:** Special campaigns run by local businesses.
- **notifications:** Alerts sent to users regarding their account or bookings.

### Example Documents

**users**
```json
{
  "id": "user123",
  "name": "Jane Doe",
  "email": "jane@example.com",
  "role": "guest",
  "profilePhotoUrl": "https://...",
  "rating": 4.8,
  "verifiedBadge": true,
  "createdAt": "2023-10-27T10:00:00Z"
}
```

**experiences**
```json
{
  "id": "exp456",
  "hostId": "host789",
  "title": "Sunset Kayaking",
  "description": "A peaceful evening on the water.",
  "category": "outdoors",
  "price": 50.00,
  "location": {
    "lat": 34.0522,
    "lng": -118.2437,
    "address": "123 Marina Bay"
  },
  "tags": ["water", "sunset", "relaxing"],
  "images": ["https://..."],
  "capacity": 4,
  "schedule": ["2023-11-01T17:00:00Z"],
  "status": "active",
  "createdAt": "2023-10-25T08:00:00Z"
}
```

**bookings**
```json
{
  "id": "book101",
  "experienceId": "exp456",
  "userId": "user123",
  "hostId": "host789",
  "startTime": "2023-11-01T17:00:00Z",
  "endTime": "2023-11-01T19:00:00Z",
  "price": 50.00,
  "status": "confirmed",
  "paymentId": "pi_3M...",
  "createdAt": "2023-10-28T14:30:00Z"
}
```

**Denormalization:** In SQL databases, you try to avoid storing the same data twice. In NoSQL (like Firestore), it's often better to duplicate small pieces of data (like putting the `hostName` directly inside an `experience` document) so the app can load an experience with one fast read, instead of having to look up the experience and then separately look up the host's details.

## 4 Feature Implementation Mapping

### Authentication and Verification
- **Where logic lives:** Firebase Auth for basic login. Custom Backend for ID verification.
- **Flow:** User signs up via Firebase Auth in the Flutter app. To get a "verified badge", they upload an ID document to a Custom API endpoint, which verifies it and updates their Firestore profile.

### AI Mood Match
- **Where logic lives:** Custom Backend API.
- **Endpoint:** `POST /recommendations/mood`
- **Algorithm:** The Flutter app sends the user's mood and location. The Node.js server asks the AI service to translate the "mood" into experience filters. The server then queries Firestore for matching experiences near the location and returns them ranked.
- **Caching & Rate Limits:** We save (cache) recent AI responses so we don't pay the AI repeatedly for the exact same query. We limit users to a certain number of mood requests per hour to prevent abuse.

### Surprise Experiences
- **Where logic lives:** Firebase Cloud Function or Custom API.
- **Algorithm:** Triggers a function that selects random experiences within constraints (budget, location, time); includes safety checks to ensure only safe, verified hosts and host opt-in available experiences are booked automatically.

### Experience Chains
- **Where logic lives:** Custom Backend API.
- **Algorithm:** A custom AI service endpoint accepts a short prompt (e.g., "A chill weekend in NYC"). An enhancer step adds detail, then asks the AI to build an itinerary. The API matches the AI's ideas with specific experiences from Firestore and returns the "chain."

### Bookings and Payment Flow
- **Where logic lives:** Custom Backend + Stripe (or local gateway) + Cloud Functions.
- **Flow Diagram:**
  User books → Payment authorization → Booking created (status: pending) → Host marks experience ended → Cloud Function verifies end → Release payment to host.
- **Gateways & Safety:** Recommend Stripe Connect or a local gateway. Use "webhooks" (messages from Stripe to our server) to ensure payments succeed. Idempotency is used so if Stripe accidentally messages us twice, we don't double charge the user.

### Map Integration and Geolocation
- **Where logic lives:** Firestore & Flutter using geospatial libraries.
- **Pattern:** Store "geohashes" (a way of turning map coordinates into a short string). You use a library with Firestore to query and retrieve any experiences with a geohash matching the user's local area.

### Social Features
- **Where logic lives:** Firestore & Cloud Functions/Custom API.
- **Pattern:** Likes, follows, and posts are stored in Firestore as documents/subcollections. Feed generation is handled via Cloud Functions or a custom feed service for more complex ranking algorithms.

### Local Business Tie‑ins
- **Where logic lives:** Custom Backend (Admin APIs).
- **Pattern:** Admin APIs allow businesses to create promotions. This updates Firestore, adding paid promotion flags and map pins for their experiences securely.

## 5 Security and Rules

### Firestore Security Rules
Firestore securely controls who can see or edit data from the app directly.
- **Examples:**
  - *Public read:* Users can read public experiences.
  - *Owner write:* Hosts can create/edit their own experiences.
  - *Authenticated access:* Bookings can be created by authenticated users only.
  - *Admin bypass:* Admin role checks for high-level management.

### Validation
- **Client vs Server:** We check if data is correct in Flutter (Client Validation) for fast feedback. Yet, we MUST validate again on the Node.js Server (Server Validation) because hackers can bypass the app and send bad data directly to our database or AI points.
- **Protection:** We use input sanitization (cleaning up texts submitted by users) and rate limiting (preventing too many swift requests) to protect our expensive AI API endpoints from being abused.

## 6 Deployment, Monitoring, and Operations

- **Deployment Targets:**
  - Simple Triggers: **Firebase Cloud Functions**.
  - Custom Backend: **Cloud Run (Google Cloud)** or **AWS ECS** for the containerized Express/NestJS backend.
- **CI/CD (Continuous Integration/Continuous Deployment):** We'll rely on an automated pipeline (like GitHub Actions) to outline and run tests, lint checks, build the image, and deploy.
- **Monitoring & Logging:** Use Firebase Analytics for user metrics, Cloud Logging for server logs, Sentry for real-time error tracking, and Prometheus/Grafana for custom internal server metrics.
- **Safeguards:** Ensure regular backups and automated data exports for Firestore.

## 7 Step by Step Roadmap for a Beginner

1. **Create Firebase Project (1–2 days)**
   - **Goal:** Get the core cloud database and authentication system alive.
   - **Tasks:** Enable Auth, configure Firestore, prepare Firebase Storage.
   - **Deliverables:** Firebase config connected to Flutter app.
   - **Verification:** Manually create a user in the Firebase web console.

2. **Define Collections & Basic Security Rules (1–2 days)**
   - **Goal:** Structure where the data will live safely.
   - **Tasks:** Write basic `firestore.rules`.
   - **Deliverables:** Secured Firestore database active.
   - **Verification:** Ensure unauthenticated reads to secure collections are blocked.

3. **Scaffold Node.js Backend (1–2 days)**
   - **Goal:** Create the custom server that handles advanced logic.
   - **Tasks:** Setup Express or NestJS, add basic auth middleware, output a `/health` endpoint.
   - **Deliverables:** Server running locally.
   - **Verification:** `curl http://localhost:3000/health` works.

4. **Implement Registration Flows (2–3 days)**
   - **Goal:** Allow users to log in securely.
   - **Tasks:** Build Flutter login, connect to Firebase Auth, integrate profile data creation.
   - **Deliverables:** Functional user sign-in via the app.
   - **Verification:** User registers on phone, appears in Firebase console.

5. **Experience CRUD in Firestore (2–4 days)**
   - **Goal:** Hosts can manage their experience listings.
   - **Tasks:** Link host dashboard screens to Firestore create/read/update/delete operations.
   - **Deliverables:** Working host portal in the app.
   - **Verification:** Host creates listing, guest sees it on the map.

6. **Implement Booking Flow (3–5 days)**
   - **Goal:** Users can pretend to pay for an experience.
   - **Tasks:** Setup payment sandbox (like Stripe), build checkout endpoints.
   - **Deliverables:** End-to-end checkout utilizing test payments.
   - **Verification:** Booking created successfully with a payment receipt returned.

7. **Add Payment Release Cloud Function (1–2 days)**
   - **Goal:** Automatically pay the host when the job is done.
   - **Tasks:** Cloud Function listening for experience 'ended' status.
   - **Deliverables:** Deployed and actively listening function.
   - **Verification:** Change status manually, check logs mapping a successful fund transfer.

8. **Build AI Recommendation Prototype (3–5 days)**
   - **Goal:** Launch the core "mood match" offering.
   - **Tasks:** Integrate AI provider, build the `/recommendations/mood` endpoint.
   - **Deliverables:** Working AI API.
   - **Verification:** `curl` the endpoint with a mock mood and receive JSON of ranked experiences.

9. **Implement Map Queries & Geolocation (2–3 days)**
   - **Goal:** Guests can find nearby things to do.
   - **Tasks:** Add geohash logic, query Firestore based on user coordinates.
   - **Deliverables:** Fully functioning map plotting in the Flutter app.
   - **Verification:** Open map tab in app, instantly see nearby pins.

10. **Security Review, Load Testing, Staging Deploy (3–5 days)**
    - **Goal:** Ensure system doesn't crash or get hacked.
    - **Tasks:** Complete security checklist, script simple load tests, deploy node app to staging environment.
    - **Deliverables:** Healthy staging release.
    - **Verification:** Run a security scanning tool on the staging URL.

11. **Production Deploy and Monitoring (1–2 days)**
    - **Goal:** Go Live safely.
    - **Tasks:** Push to production, wire up Sentry/Analytics, set alerts.
    - **Deliverables:** Live application.
    - **Verification:** Download app from store (or beta testing platform) and run a full cycle gracefully.

## 8 Testing Checklist and Acceptance Criteria

- **Unit Tests:** Verify individual backend logic chunks isolated from actual databases.
- **Integration Tests:** Certify the booking and payment flows actually communicate correctly between Custom APIs and Stripe without failing.
- **End-to-End Tests:** Smoke tests where a complete user simulation journeys from the Flutter app interface all the way to backend state updates and back.
- **Security:** Ensure comprehensive checklist: proper Firestore rules are in place, auth tokens are actually validated on the backend, rate limits execute successfully on APIs, and strict input validation occurs on every request.

## 9 Appendix

### Sample Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Anyone can read experiences, only owners can edit
    match /experiences/{expId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == resource.data.hostId;
    }
  }
}
```

### Example REST Endpoints

| Method | Path | Purpose | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | Verify server heartbeat | No |
| `POST` | `/recommendations/mood` | Retrieve AI rankings | Yes |
| `POST` | `/checkout` | Initialize Stripe authorization | Yes |

### Example cURL command
```bash
curl -X POST http://localhost:3000/api/checkout \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <FIREBASE_AUTH_TOKEN>" \
-d '{"experienceId": "exp456", "userId": "user123"}'
```

### Glossary of Terms
- **Auth:** Short for Authentication, the process of verifying a user's identity.
- **Firestore:** Google's scalable NoSQL cloud database where we store JSON-like documents.
- **Cloud Function:** Serverless code that automatically executes in response to database or network events.
- **Webhook:** Automated messages sent from apps (like Stripe) as soon as an external event concludes.
- **Idempotency:** A concept guaranteeing that repeating an API request has the exact same effect as making it once (preventing duplicate charges).

---
## Quick Start Checklist (First 7 Days)
- [ ] Create a Google account and sign in to the Firebase Console.
- [ ] Initialize a new Firebase Project for "ZeyLo".
- [ ] Turn on Firebase Authentication (starting with Email/Password).
- [ ] Initialize Firestore Database in safe testing mode.
- [ ] Initialize Firebase Storage for photos.
- [ ] Connect the Flutter frontend to Firebase using downloaded configuration files.
- [ ] Setup a new folder on your laptop, initialize Node.js (`npm init -y`).
- [ ] Install Express framework and draft your very first backend code.
- [ ] Add the basic `GET /health` route and run the local server.
- [ ] Commit your progress to GitHub.
