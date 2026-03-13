# Pull Request Description

## 🚀 Features & Enhancements

### Admin Dashboard & Monitoring
* **Active Experience Management**: 
  - Added new `/admin/experiences` route accessible from the "Active Experiences" dashboard card.
  - Built a searchable global list view of all active experiences for Admin oversight.
* **Destructive Experience Deletion API**:
  - Implemented a secure Node.js backend route (`/api/admin/delete-experience`) utilizing Firebase Admin SDK to bypass client-side database rules.
  - Built a multi-stage Firestore batch script that simultaneously:
    1. Permanently shreds the targeted `experience` document.
    2. Overrides all connected `bookings` into a `cancelled` state with reason "Administrator Removal".
    3. Queues an in-app `activities` warning notification to the Host's dashboard.
    4. Queues "Experience Cancelled" push notifications to every individual Seeker who booked it.
* **Dynamic Settings Access**:
  - Injected an exclusive `Admin Dashboard` button into the User Profile's Settings menu, functionally hidden unless the authenticated user's `role` is set to `admin`.
* **Report Management Refinements**:
  - Remodeled the Admin Reports Tab into a two-stage triage pipeline ("Pending Review" and "Monitoring").
  - Fixed a critical UI overflow box constraint on the Report Action Dialog.
  - Added "Send Warning Email Again", "Mark as Resolved", and "Ban User" actions securely bound to the custom backend API.

### Host Verification System
* **Verified Host Badge Implementation**:
  - Updated the global `ExperienceCard` widget to actively display a blue verification badge if the `isHostVerified` property is true.
  - Updated `create_experience_screen.dart` to automatically query the Host's verified status and inject `isHostVerified` directly into all new listings upon creation.
* **Retroactive Verification Syncing**:
  - Updated `admin_host_verification_tab.dart` so that when an Admin approves or rejects a Host, a batch process automatically combs through every existing experience that Host has produced and retroactively updates their `isHostVerified` tags across the platform.

---

## 🛠️ Bug Fixes & Hotfixes

* **Firebase Backend Ghosting**: 
  - Fixed a critical server crash caused by the `google-auth-library` failing to resolve the environment context for `verifyIdToken`. 
  - Solution: Injected strict `FIREBASE_PROJECT_ID` and `GOOGLE_CLOUD_PROJECT` flags directly into the Node `.env` and hardcoded the `service-account.json` path into `firebase.js`.
* **Nodemailer SMTP Failure**: 
  - Resolved `EAUTH: Missing credentials for "PLAIN"` crash which was preventing the backend from dispatching Admin Warning emails.
  - Solution: Remigrated the user's hidden Email/App Password from `.env.example` directly into the actual `.env`.

---

## 🧪 Things to Note for Reviewers
- The `HomeScreen` utilizes a local Riverpod `FutureProvider` which intentionally caches experience cards on boot to save read-writes. **When an Admin permanently deletes an experience, that card will visually remain on the Home Screen until the user manually triggers a Pull-to-Refresh.** Trying to click the "ghost" card will harmlessly return an error.
