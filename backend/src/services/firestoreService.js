const { db } = require('../config/firebase');
const geohash = require('ngeohash');

/**
 * Utility to find a surprise experience matching constraints.
 * Uses ngeohash to find experiences near the given lat/lng.
 */
const getSurpriseExperience = async ({ location, maxBudget, datePreference, userId }) => {
  // 1. Calculate a geohash of length 5 (approx 4.9km x 4.9km bounding box)
  const targetGeohash = geohash.encode(location.lat, location.lng, 5);

  // 2. Query Firestore based on geohash prefix using startAt and endAt
  const experiencesRef = db.collection('experiences');
  
  // Note: To successfully query by prefix in Firestore, we use \uf8ff character
  const snapshot = await experiencesRef
    .orderBy('geohash')
    .startAt(targetGeohash)
    .endAt(targetGeohash + '\uf8ff')
    .get();

  if (snapshot.empty) {
    return null;
  }

  // 3. Filter candidates based on rules
  const candidates = [];
  snapshot.forEach(doc => {
    const data = doc.data();

    // Constraint matching logic:
    // - Must be eligible for surprise
    // - Price must be within budget
    // - Host must exist and be verified
    // - To prevent re-booking, we ideally check the user's booking history, 
    //   but we will skip the explicit DB call for past bookings in this logic placeholder per plan.
    if (
      data.isSurpriseEligible === true &&
      data.price <= maxBudget &&
      data.host && data.host.isVerified === true
    ) {
      candidates.push({ id: doc.id, ...data });
    }
  });

  if (candidates.length === 0) {
    return null;
  }

  // 4. Randomly pick one candidate
  const randomIndex = Math.floor(Math.random() * candidates.length);
  return candidates[randomIndex];
};

module.exports = {
  getSurpriseExperience,
};
