const geminiService = require('../services/geminiService');

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
 */
const generateSurprise = async (req, res) => {
    try {
      const { preferences } = req.body;
  
      if (!preferences) {
        return res.status(400).json({ error: 'Missing preferences criteria.' });
      }
  
      const mysteryData = await geminiService.generateSurprise(preferences);
      
      return res.status(200).json({
        success: true,
        data: { mystery: mysteryData }
      });
    } catch (error) {
      console.error('Generate Mystery Controller Error:', error);
      return res.status(500).json({ error: 'AI Mystery Generation Failed', details: error.message });
    }
  };

module.exports = {
  enhanceText,
  generateChain,
  generateSurprise
};
