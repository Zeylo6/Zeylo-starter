const admin = require('firebase-admin');

// In development, you usually use a service account key JSON file
// but we leave this setup to use Application Default Credentials or standard init.
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const auth = admin.auth();

module.exports = { admin, db, auth };
