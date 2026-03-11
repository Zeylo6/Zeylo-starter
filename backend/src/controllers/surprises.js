const firestoreService = require('../services/firestoreService');

const generateSurprise = async (req, res) => {
  try {
    // Determine userId from decoded token (req.user) if available, fallback to body
    const userId = req.user ? req.user.uid : req.body.userId;
    const { location, maxBudget, datePreference } = req.body;

    if (!location || !location.lat || !location.lng || !maxBudget) {
      return res.status(400).json({ error: 'Missing required fields: location (lat, lng) or maxBudget' });
    }

    const experience = await firestoreService.getSurpriseExperience({
      location,
      maxBudget,
      datePreference,
      userId,
    });

    if (!experience) {
      return res.status(404).json({ error: 'No surprise experiences found matching your criteria.' });
    }

    return res.status(200).json({
      message: 'Surprise experience generated successfully!',
      experience,
    });
  } catch (error) {
    console.error('Error generating surprise experience:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  generateSurprise,
};
