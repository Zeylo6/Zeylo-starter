const geminiService = require('../services/geminiService');
const openRouterService = require('../services/openRouterService');
const { db } = require('../config/firebase');
const notificationService = require('../services/notificationService');

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

    let enhancedText;
    try {
      // Try OpenRouter first as requested
      enhancedText = await openRouterService.enhanceText(text, context || 'general');
    } catch (orError) {
      console.error('OpenRouter Enhancement Failed, falling back to Gemini:', orError.message);
      // Fallback to Gemini
      enhancedText = await geminiService.enhanceText(text, context || 'general');
    }

    return res.status(200).json({
      success: true,
      data: { enhancedText },
    });
  } catch (error) {
    console.error('Enhance Text Controller Error:', error);
    return res.status(500).json({ error: 'AI Enhancement Failed', details: error.message });
  }
};

/**
 * POST /api/ai/chain/generate
 * Body: { prompt, location, date, totalTime, interests }
 *
 * New logic:
 * - Query real Firestore experiences
 * - Send compact candidate list to Gemini
 * - Gemini returns only selected IDs + times
 * - Re-fetch real docs and return real chain data
 */
const generateChain = async (req, res) => {
  try {
    const { prompt, location, date, totalTime, interests } = req.body;

    if (!prompt || !location || !totalTime) {
      return res.status(400).json({
        error: 'Missing required fields (prompt, location, totalTime).',
      });
    }

    const normalizedLocation = String(location).trim();
    const safeInterests = Array.isArray(interests)
      ? interests
        .map((item) => String(item).trim())
        .filter((item) => item.isNotEmpty !== false && item.length > 0)
      : [];

    const snapshot = await db
      .collection('experiences')
      .where('city', '==', normalizedLocation)
      .where('status', '==', 'active')
      .limit(30)
      .get();

    if (snapshot.empty) {
      return res.status(400).json({
        error: 'No experiences available in this location yet',
      });
    }

    const allCandidates = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        title: data.title || 'Untitled Experience',
        category: data.category || 'General',
        duration: typeof data.duration === 'number' ? data.duration : Number(data.duration || 0),
        price: typeof data.price === 'number' ? data.price : Number(data.price || 0),
        startTime: data.startTime || null,
        endTime: data.endTime || null,
        description: data.description || '',
      };
    });

    let candidates = allCandidates;

    if (safeInterests.length > 0) {
      const loweredInterests = safeInterests.map((item) => item.toLowerCase());
      const filtered = allCandidates.filter((item) =>
        loweredInterests.includes(String(item.category || '').toLowerCase())
      );

      if (filtered.length > 0) {
        candidates = filtered;
      }
    }

    let validSelected = [];
    try {
      const selected = await geminiService.generateChainFromCandidates({
        prompt,
        location: normalizedLocation,
        date,
        totalTime,
        interests: safeInterests,
        candidates,
      });

      const candidateMap = new Map(candidates.map((item) => [item.id, item]));
      validSelected = Array.isArray(selected)
        ? selected.filter(
          (item) =>
            item &&
            typeof item.id === 'string' &&
            candidateMap.has(item.id) &&
            typeof item.startTime === 'string' &&
            typeof item.endTime === 'string'
        )
        : [];
      
      if (validSelected.length < 2) {
        throw new Error('AI returned too few valid experiences');
      }
    } catch (aiError) {
      console.error('Gemini failed or quota exceeded:', aiError.message);
      const manualCount = totalTime === 'halfDay' ? 2 : (totalTime === 'weekend' ? 4 : 3);
      const shuffled = candidates.sort(() => 0.5 - Math.random());
      const selectedCandidates = shuffled.slice(0, Math.min(manualCount, candidates.length));
      
      let currentHour = 9; 
      validSelected = selectedCandidates.map(c => {
        const start = `${String(currentHour).padStart(2, '0')}:00`;
        const endHour = currentHour + Math.ceil(c.duration || 2);
        const end = `${String(endHour).padStart(2, '0')}:00`;
        currentHour = endHour + 1; 
        return {
          id: c.id,
          startTime: start,
          endTime: end
        };
      });
    }

    if (validSelected.length < 2) {
      return res.status(400).json({
        error: 'No options available to you in this area.',
      });
    }

    const fullExperiences = [];

    for (const item of validSelected) {
      const doc = await db.collection('experiences').doc(item.id).get();
      if (!doc.exists) continue;

      const data = doc.data();

      fullExperiences.push({
        experienceId: item.id,
        title: data.title || 'Untitled Experience',
        startTime: item.startTime,
        endTime: item.endTime,
        duration: typeof data.duration === 'number' ? data.duration : Number(data.duration || 0),
        price: typeof data.price === 'number' ? data.price : Number(data.price || 0),
        isOvernight: data.isOvernight ?? false,
        imageUrl: data.imageUrl || data.coverImage || '',
        category: data.category || 'General',
        hostId: data.hostId || '',
      });
    }

    if (fullExperiences.length < 2) {
      return res.status(500).json({
        error: 'Not enough valid experiences found after re-fetch. Try again or broaden interests.',
      });
    }

    return res.status(200).json({
      success: true,
      data: { chain: fullExperiences },
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

    let query = db.collection('experiences').where('isActive', '==', true);
    const snapshot = await query.get();

    if (snapshot.empty) {
      return res.status(404).json({ error: 'No active experiences found in the system.' });
    }

    const budgetMin = parseFloat(preferences.budgetMin || 0);
    const budgetMax = parseFloat(preferences.budgetMax || 999999);
    const preferredLocation = (preferences.location || '').toLowerCase().trim();

    const candidates = [];
    snapshot.forEach((doc) => {
      const data = doc.data();
      const price = data.price || 0;
      const expLocation = (data.location?.city || data.location?.address || '').toLowerCase();

      const matchesBudget = price >= budgetMin && price <= budgetMax;
      const matchesLocation =
        preferredLocation === '' ||
        expLocation.includes(preferredLocation) ||
        preferredLocation.includes(expLocation);

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
      return res.status(404).json({
        error: 'No specific experiences match your criteria (try relaxing your budget or city).',
      });
    }

    const matchResult = await geminiService.matchAndGenerateMystery(preferences, candidates);

    return res.status(200).json({
      success: true,
      data: { mystery: matchResult },
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
    const { mysteryId, location, date, time, budgetMin, budgetMax, experienceType } = req.body;

    const auth = req.user;
    if (!auth || !auth.uid) {
      return res.status(401).json({ error: 'User must be authenticated.' });
    }
    const userId = auth.uid;

    if (!mysteryId || !location) {
      return res.status(400).json({ error: 'Missing required payload parameters.' });
    }

    const experiencesSnapshot = await db.collection('experiences').where('isActive', '==', true).get();

    if (experiencesSnapshot.empty) {
      return res.status(200).json({
        data: { matched: false, reason: 'no_active', message: 'No active experiences found.' },
      });
    }

    const candidates = [];
    experiencesSnapshot.forEach((doc) => {
      const data = doc.data();
      const price = data.price || 0;
      const expLoc = data.location?.city || data.location?.address || '';

      if (
        price >= budgetMin &&
        price <= budgetMax &&
        expLoc.toLowerCase().includes(location.toLowerCase())
      ) {
        candidates.push({
          id: doc.id,
          title: data.title,
          description: data.description,
          price: price,
          category: data.category,
          hostId: data.hostId,
          coverImage: data.coverImage,
        });
      }
    });

    if (candidates.length === 0) {
      return res.status(200).json({
        data: {
          matched: false,
          reason: 'no_match',
          message: 'No experiences found in your city within your budget.',
        },
      });
    }

    const selected = candidates[Math.floor(Math.random() * candidates.length)];

    let aiTeaser = null;
    try {
      const preferences = { mood: experienceType, time: time };
      const matchResult = await geminiService.matchAndGenerateMystery(preferences, [selected]);
      aiTeaser = {
        teaserDescription: matchResult.teaserDescription,
        vibe: matchResult.vibe,
        preparationNotes: matchResult.preparationNotes,
      };
    } catch (err) {
      console.error('Gemini Teaser Error:', err.message);
      aiTeaser = {
        teaserDescription: `A thrilling ${experienceType} adventure awaits in ${location}!`,
        vibe: 'Surprising & Fun',
        preparationNotes: 'Bring your best energy!',
      };
    }

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

    const startTimeObjStr =
      time === 'afternoon' ? '12:00 PM' : time === 'evening' ? '05:00 PM' : '09:00 AM';

    const admin = require('firebase-admin');
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

    await db.collection('activities').add({
      userId: selected.hostId,
      title: 'New Mystery Booking 🎁',
      message: `A mystery seeker has been matched to your experience "${selected.title}".`,
      type: 'mystery_booking',
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      bookingId: bookingRef.id,
    });

    // Notify host of new mystery booking
    await notificationService.notifyHostOfBooking(selected.hostId, {
      title: 'New Mystery Match! 🎁',
      body: `You've been matched for a mystery experience!`,
      bookingId: bookingRef.id,
      type: 'mystery_booking',
    });

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
        preparationNotes: aiTeaser.preparationNotes,
      },
    });
  } catch (error) {
    console.error('Match error:', error);
    return res.status(500).json({ error: 'Internal error matching mystery', details: error.message });
  }
};

module.exports = {
  enhanceText,
  generateChain,
  generateSurprise,
  matchAndBookMystery,
};