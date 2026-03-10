const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

if (!admin.apps.length) {
  const serviceAccountPath = path.join(__dirname, '../../service-account.json');

  if (fs.existsSync(serviceAccountPath)) {
    // Use service account file (required for local development)
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    console.log('Firebase Admin initialized with service account.');
  } else if (process.env.FIREBASE_PROJECT_ID) {
    // Fallback: use Application Default Credentials with explicit project ID
    admin.initializeApp({ projectId: process.env.FIREBASE_PROJECT_ID });
    console.log('Firebase Admin initialized with project ID (no service account found).');
  } else {
    admin.initializeApp();
    console.log('Firebase Admin initialized with Application Default Credentials.');
  }
}

const db = admin.firestore();
const auth = admin.auth();

module.exports = { admin, db, auth };
