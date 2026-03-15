const { GoogleGenerativeAI } = require('@google/generative-ai');

// Wait to initialize until needed in case API key is loaded late in env
let genAI = null;

const getModel = () => {
  if (!genAI) {
    if (!process.env.GEMINI_API_KEY) {
      throw new Error("GEMINI_API_KEY is missing from environment variables.");
    }
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  }
  // We use gemini-2.0-flash as it's confirmed available for this key and very fast
  return genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
};

/**
 * Enhances a given text string based on a specific context format.
 * @param {string} prompt - The raw user input
 * @param {string} context - The context type (e.g. 'mood', 'host_experience', 'business_review')
 * @returns {Promise<string>} The AI enhanced text
 */
const enhanceText = async (prompt, context) => {
  const model = getModel();

  let systemInstruction = "";
  switch (context) {
    case 'mood':
      systemInstruction = `You are an empathetic AI assistant on a social platform. 
      The user has provided a short description of their current mood. 
      Your job is to enhance it into a single, beautifully written paragraph (2-3 sentences max) that clearly articulates their feelings and what kind of experience or interaction they might be looking for today.
      Do not add commentary, just return the enhanced description directly. Keep it first-person.`;
      break;
    case 'host_experience':
      systemInstruction = `You are an expert marketing copywriter for an experience booking platform (like Airbnb Experiences).
      The host has provided a rough draft description of the experience they want to offer.
      Your job is to rewrite it into a highly engaging, professional, and alluring marketing pitch. 
      Make it 3-4 short paragraphs. Highlight the unique value. Do not add any conversational filler, just return the marketing copy.`;
      break;
    case 'business_review':
      systemInstruction = `You are a strict business compliance and quality assurance AI.
      The user has submitted text describing their business for platform verification.
      Summarize the key offerings, identify any potential red flags or restricted services, and provide a 1-sentence recommendation on whether it sounds like a legitimate, safe business.`;
      break;
    default:
      systemInstruction = `You are a helpful writing assistant. Please improve the grammar, flow, and clarity of the following text while keeping its original meaning.`;
  }

  const fullPrompt = `${systemInstruction}\n\nUser Text to Enhance:\n"${prompt}"`;

  try {
    const result = await model.generateContent(fullPrompt);
    return result.response.text().trim();
  } catch (error) {
    console.error("Gemini enhanceText Error:", error.message);
    if (error.stack) console.error(error.stack);
    throw new Error(`Failed to enhance text with AI: ${error.message}`);
  }
};

/**
 * Generates an itinerary of 3 sequence experiences based on user criteria.
 * Forces the AI to return a strict JSON array.
 * @returns {Promise<Array>} Array of parsed JSON experience objects
 */
const generateChain = async (prompt, location, date) => {
  const model = getModel();

  const systemInstruction = `You are a master travel and experience curator.
  The user wants an itinerary of exactly 3 sequential activities (morning, afternoon, evening or continuous) based on their prompt.
  You MUST return ONLY a valid JSON array of exactly 3 objects. NO markdown formatting, NO backticks, NO extra text.
  
  JSON Object Schema:
  {
    "experienceId": "A unique dummy string like 'ai_exp_123'",
    "title": "Short catchy activity title",
    "startTime": "e.g., '10:00'",
    "endTime": "e.g., '12:00'",
    "duration": Numeric float representing hours (e.g., 2.0),
    "price": Numeric float representing USD cost (e.g., 25.50),
    "isOvernight": Boolean (true/false)
  }`;

  const fullPrompt = `${systemInstruction}\n\nCriteria:\nPrompt: ${prompt}\nLocation: ${location || 'Anywhere'}\nDate: ${date || 'Any day'}`;

  try {
    const result = await model.generateContent(fullPrompt);
    let text = result.response.text().trim();
    
    // Sometimes Gemini wraps in markdown json blocks despite instructions, so we clean it
    if (text.startsWith('```json')) {
      text = text.substring(7, text.length - 3).trim();
    } else if (text.startsWith('```')) {
      text = text.substring(3, text.length - 3).trim();
    }

    const parsedArray = JSON.parse(text);
    if (!Array.isArray(parsedArray) || parsedArray.length !== 3) {
      throw new Error("AI did not return exactly 3 array items.");
    }
    
    return parsedArray;
  } catch (error) {
    console.error("Gemini generateChain Error:", error.message);
    throw new Error(`Failed to generate itinerary chain: ${error.message}`);
  }
};

/**
 * Generates a mystery surprise itinerary based on preferences.
 * Forces the AI to return a strict JSON object.
 * @returns {Promise<Object>} Parsed JSON surprise object
 */
const generateSurprise = async (preferences) => {
    const model = getModel();
  
    const systemInstruction = `You are a boutique mystery experience curator.
    The user has provided a set of preferences. Generate a highly unique, slightly secretive "Mystery Surprise" experience for them.
    You MUST return ONLY a valid JSON object. NO markdown formatting, NO backticks, NO extra text.
    
    JSON Object Schema:
    {
      "title": "A cryptic but alluring title (e.g. 'The Midnight Sonata')",
      "teaserDescription": "A 2-3 sentence teaser that builds hype without spoiling the exact activity",
      "category": "The matched category",
      "vibe": "1-2 words describing the vibe (e.g., 'Dark & Moody', 'High Energy')",
      "preparationNotes": "What should they wear or bring? Keep it vague but helpful."
    }`;
  
    const fullPrompt = `${systemInstruction}\n\nUser Preferences:\n${JSON.stringify(preferences)}`;
  
    try {
      const result = await model.generateContent(fullPrompt);
      let text = result.response.text().trim();
      
      if (text.startsWith('```json')) {
        text = text.substring(7, text.length - 3).trim();
      } else if (text.startsWith('```')) {
        text = text.substring(3, text.length - 3).trim();
      }
  
      const parsedData = JSON.parse(text);
      return parsedData;
    } catch (error) {
      console.error("Gemini generateSurprise Error:", error.message);
      throw new Error(`Failed to generate mystery surprise: ${error.message}`);
    }
  };

module.exports = {
  enhanceText,
  generateChain,
  generateSurprise
};
