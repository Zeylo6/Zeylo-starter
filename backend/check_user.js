const admin = require('firebase-admin');
const serviceAccount = require('./path-to-service-account.json');

// Initialize Firebase Admin (modify if using different auth method locally)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

async function checkUser() {
  const snapshot = await db.collection('users').where('email', '==', 'wethminkavinuwittahachchi123@gmail.com').get();
  if (snapshot.empty) {
    console.log("No user found");
    return;
  }
  snapshot.forEach(doc => {
    console.log(doc.id, '=>', doc.data());
  });
}

checkUser();
