const geminiService = require('../services/geminiService');
const { db } = require('../config/firebase');

/**
 * POST /api/ai/enhance
 * Body: { text, context }
 */
const enhanceText = async (req, res) => {
  try {
    const { text, context } = req.body;

    if (!text) {
      return res.status(400).json({ error: 'Missing full text prompt to enhance.' });
    }

    const enhancedText = await geminiService.enhanceText(text, context || 'general');
    
    return res.status(200).json({
      success: true,
      data: { enhancedText }
    });
  } catch (error) {
    console.error('Enhance Text Controller Error:', error);
    return res.status(500).json({ error: 'AI Enhancement Failed', details: error.message });
  }
};

/**
 * POST /api/ai/chain/generate
 * Body: { prompt, location, date }
 */
const generateChain = async (req, res) => {
  try {
    const { prompt, location, date } = req.body;

    if (!prompt) {
      return res.status(400).json({ error: 'Missing prompt criteria.' });
    }

    const chainItinerary = await geminiService.generateChain(prompt, location, date);
    
    return res.status(200).json({
      success: true,
      data: { chain: chainItinerary }
    });
  } catch (error) {
    console.error('Generate Chain Controller Error:', error);
    return res.status(500).json({ error: 'AI Chain Generation Failed', details: error.message });
  }
};

/**
 * POST /api/ai/mystery/generate
 * Body: { preferences }
 * 
 * Matches seeker preferences to a real experience using AI scoring,
 * then generates a teaser, vibe, and prep notes for the mystery.
 */
const generateSurprise = async (req, res) => {
  try {
    const { preferences } = req.body;

    if (!preferences) {
      return res.status(400).json({ error: 'Missing preferences criteria.' });
    }

    // 1. Query candidate experiences from Firestore
    // We remove the strict 'isMysteryAvailable' requirement so it can match any real active experience.
    let query = db.collection('experiences').where('isActive', '==', true);

    const snapshot = await query.get();

    if (snapshot.empty) {
      return res.status(404).json({ error: 'No active experiences found in the system.' });
    }

    // 2. Filter candidates by budget and city (location)
    const budgetMin = parseFloat(preferences.budgetMin || 0);
    const budgetMax = parseFloat(preferences.budgetMax || 999999);
    const preferredLocation = (preferences.location || '').toLowerCase().trim();

    const candidates = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      const price = data.price || 0;
      const expLocation = (data.location?.city || data.location?.address || '').toLowerCase();

      // Basic filtering: within budget, and matches location if provided
      const matchesBudget = price >= budgetMin && price <= budgetMax;
      const matchesLocation = preferredLocation === '' || expLocation.includes(preferredLocation) || preferredLocation.includes(expLocation);

      if (matchesBudget && matchesLocation) {
        candidates.push({
          id: doc.id,
          title: data.title || 'Untitled Experience',
          category: data.category || 'General',
          price: price,
          city: expLocation,
          description: (data.description || '').substring(0, 300),
        });
      }
    });

    if (candidates.length === 0) {
      return res.status(404).json({ error: 'No specific experiences match your criteria (try relaxing your budget or city).' });
    }

    // 3. Use Gemini AI to rank and select the best match
    const matchResult = await geminiService.matchAndGenerateMystery(preferences, candidates);

    return res.status(200).json({
      success: true,
      data: { mystery: matchResult }
    });
  } catch (error) {
    console.error('Generate Mystery Controller Error:', error);
    return res.status(500).json({ error: 'AI Mystery Generation Failed', details: error.message });
  }
};

/**
 * POST /api/ai/mystery/match-and-book
 * Body: { mysteryId, location, date, time, budgetMin, budgetMax, experienceType }
 */
const matchAndBookMystery = async (req, res) => {
  try {
    const { 
      mysteryId, location, date, time, 
      budgetMin, budgetMax, experienceType 
    } = req.body;
    
    // Auth provided by verifyToken middleware
    const auth = req.user;
    if (!auth || !auth.uid) {
      return res.status(401).json({ error: 'User must be authenticated.' });
    }
    const userId = auth.uid;

    if (!mysteryId || !location) {
      return res.status(400).json({ error: 'Missing required payload parameters.' });
    }

    // 1. Find all active experiences
    const experiencesSnapshot = await db.collection('experiences').where('isActive', '==', true).get();
    
    if (experiencesSnapshot.empty) {
      return res.status(200).json({ data: { matched: false, reason: 'no_active', message: 'No active experiences found.' } });
    }

    // 2. Filter by location and budget in memory
    const candidates = [];
    experiencesSnapshot.forEach(doc => {
      const data = doc.data();
      const price = data.price || 0;
      const expLoc = data.location?.city || data.location?.address || '';

      if (price >= budgetMin && price <= budgetMax && 
          expLoc.toLowerCase().includes(location.toLowerCase())) {
        candidates.push({
          id: doc.id,
          title: data.title,
          description: data.description,
          price: price,
          category: data.category,
          hostId: data.hostId,
          coverImage: data.coverImage
        });
      }
    });

    if (candidates.length === 0) {
      return res.status(200).json({ data: { matched: false, reason: 'no_match', message: 'No experiences found in your city within your budget.' } });
    }

    // Shuffle or random pick
    const selected = candidates[Math.floor(Math.random() * candidates.length)];

    // 3. Call Gemini via GeminiService
    let aiTeaser = null;
    try {
      // Create a mock preferences object for the geminiService method
      const preferences = { mood: experienceType, time: time };
      const matchResult = await geminiService.matchAndGenerateMystery(preferences, [selected]);
      aiTeaser = {
        teaserDescription: matchResult.teaserDescription,
        vibe: matchResult.vibe,
        preparationNotes: matchResult.preparationNotes
      };
    } catch (err) {
      console.error("Gemini Teaser Error:", err.message);
      // Default fallback AI teaser if skipped
      aiTeaser = {
        teaserDescription: `A thrilling ${experienceType} adventure awaits in ${location}!`,
        vibe: "Surprising & Fun",
        preparationNotes: "Bring your best energy!"
      };
    }

    // 4. Parse Date
    let bookingDate = new Date();
    bookingDate.setDate(bookingDate.getDate() + 7);
    if (date) {
      const parts = date.split('/');
      if (parts.length === 2) {
        const day = parseInt(parts[0], 10);
        const month = parseInt(parts[1], 10) - 1;
        const year = new Date().getFullYear();
        bookingDate = new Date(year, month, day);
        if (bookingDate < new Date()) {
          bookingDate.setFullYear(year + 1);
        }
      }
    }
    
    let startTimeObjStr = time === 'afternoon' ? '12:00 PM' : (time === 'evening' ? '05:00 PM' : '09:00 AM');

    // 5. Create Booking Document in Firestore
    const admin = require("firebase-admin");
    const bookingData = {
      experienceId: selected.id,
      experienceTitle: selected.title,
      experienceCoverImage: selected.coverImage || '',
      userId: userId,
      hostId: selected.hostId,
      date: admin.firestore.Timestamp.fromDate(bookingDate),
      startTime: startTimeObjStr,
      guests: 1,
      totalPrice: selected.price,
      status: 'mystery_pending',
      paymentStatus: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      isRatedByHost: false,
      isRatedBySeeker: false,
      isEarningsCollected: false,
      isMystery: true,
      mysteryId: mysteryId,
    };

    const bookingRef = await db.collection('bookings').add(bookingData);

    // 6. Notify Host
    await db.collection('activities').add({
      userId: selected.hostId,
      title: 'New Mystery Booking 🎁',
      message: `A mystery seeker has been matched to your experience "${selected.title}".`,
      type: 'mystery_booking',
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      bookingId: bookingRef.id,
    });

    // 7. Notify Seeker
    await db.collection('activities').add({
      userId: userId,
      title: 'Mystery Booked Successfully! 🎁',
      message: 'Your surprise adventure is set!',
      type: 'mystery_booked',
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      bookingId: bookingRef.id,
    });

    return res.status(200).json({
      success: true,
      data: {
        matched: true,
        bookingId: bookingRef.id,
        teaserDescription: aiTeaser.teaserDescription,
        vibe: aiTeaser.vibe,
        preparationNotes: aiTeaser.preparationNotes
      }
    });
  } catch (error) {
    console.error("Match error:", error);
    return res.status(500).json({ error: 'Internal error matching mystery', details: error.message });
  }
};

module.exports = {
  enhanceText,
  generateChain,
  generateSurprise,
  matchAndBookMystery
};
