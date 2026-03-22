const { GoogleGenerativeAI } = require('@google/generative-ai');

// Wait to initialize until needed in case API key is loaded late in env
let genAI = null;

const getModel = () => {
  if (!genAI) {
    if (!process.env.GEMINI_API_KEY) {
      throw new Error('GEMINI_API_KEY is missing from environment variables.');
    }
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  }

  return genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
};

/**
 * Safely strips markdown fences if Gemini wraps JSON in ```json
 */
const stripMarkdownFence = (text) => {
  if (!text) return '';
  let cleaned = text.trim();

  if (cleaned.startsWith('```json')) {
    cleaned = cleaned.substring(7);
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }

  if (cleaned.startsWith('```')) {
    cleaned = cleaned.substring(3);
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }

  return cleaned;
};

/**
 * Enhance text with context-aware prompting.
 */
const enhanceText = async (prompt, context) => {
  const model = getModel();

  let systemInstruction = '';

  switch (context) {
    case 'mood':
      systemInstruction = `You are a premium emotional-intelligence writing assistant for a social/discovery app.
      The user will describe how they feel, often in a rough or short way.
      Rewrite their message into a polished, emotionally clear, naturally written paragraph (2-3 sentences max) that clearly articulates their feelings and what kind of experience or interaction they might be looking for today.
      Do not add commentary, just return the enhanced description directly. Keep it first-person.`;
      break;
    case 'host_experience':
      systemInstruction = `You are an expert marketing copywriter for an experience booking platform (like Airbnb Experiences).
      The host has provided a rough draft description of the experience they want to offer.
      Your job is to rewrite it into a highly engaging, professional, and alluring marketing pitch.
      Make it 3-4 short paragraphs. Highlight the unique value. Do not add any conversational filler, just return the marketing copy.`;
      break;
    case 'chain_itinerary':
    case 'chain_description':
      systemInstruction = `You are an expert travel planner and copywriter for a premium experience booking platform.
      The user will provide a simple idea for a day-long itinerary or experience chain.
      Your job is to rewrite it into an inspiring, detailed, and polished description of a complete travel experience. 
      Keep it structured, engaging, and professional. Describe the vibe, the flow of activities, and why it's a great combination.
      Do not add extra conversational text, just return the enhanced itinerary description. Make it about 2-3 paragraphs.`;
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
    console.error('Gemini enhanceText Error:', error.message);
    if (error.stack) console.error(error.stack);
    throw new Error(`Failed to enhance text with AI: ${error.message}`);
  }
};

/**
 * Generate a real experience chain from a list of candidate experiences.
 * Gemini must ONLY select from the provided candidates.
 *
 * @param {Object} params
 * @param {string} params.prompt
 * @param {string} params.location
 * @param {string} params.date
 * @param {string} params.totalTime
 * @param {string[]} params.interests
 * @param {Array} params.candidates
 * @returns {Promise<Array<{id:string,startTime:string,endTime:string}>>}
 */
const generateChainFromCandidates = async ({
  prompt,
  location,
  date,
  totalTime,
  interests = [],
  candidates = [],
}) => {
  const model = getModel();

  if (!Array.isArray(candidates) || candidates.length === 0) {
    throw new Error('No candidate experiences were provided to Gemini.');
  }

  const compactCandidates = candidates.map((item) => ({
    id: item.id,
    title: item.title || '',
    category: item.category || '',
    duration: item.duration ?? 0,
    price: item.price ?? 0,
    startTime: item.startTime || null,
    endTime: item.endTime || null,
    description: item.description || '',
  }));

  const systemInstruction = `You are a travel curator. Given a user's preference and a list of real available experiences, select 2–4 that best match and arrange them in a logical time sequence for the day.

Rules:
- Only select from the provided list — never invent new ones
- Return ONLY a raw JSON array, no markdown, no backticks, no commentary
- Use this exact schema per item:
  { "id": "<exact id from the list>", "startTime": "HH:mm", "endTime": "HH:mm" }
- Assign realistic startTime/endTime (24-hour HH:mm) with 30min travel gaps
- First experience no earlier than 07:00
- Last experience must end by 23:00
- Match the user's mood, pace, and interests
- If totalTime is "halfDay" pick exactly 2 experiences
- If totalTime is "fullDay" pick 3 or 4 experiences
- If totalTime is "weekend" pick exactly 4 experiences
- Never repeat the same id twice
- Use only ids that exist in the provided list`;

  const fullPrompt = `${systemInstruction}

User prompt: ${prompt}
Location: ${location || 'Anywhere'}
Date: ${date || 'Any day'}
Total time: ${totalTime}
Interests: ${(interests || []).join(', ') || 'None specified'}

Available experiences:
${JSON.stringify(compactCandidates)}`;

  try {
    const result = await model.generateContent(fullPrompt);
    const rawText = result.response.text().trim();
    const cleaned = stripMarkdownFence(rawText);
    const parsed = JSON.parse(cleaned);

    if (!Array.isArray(parsed)) {
      throw new Error('AI did not return a JSON array.');
    }

    return parsed;
  } catch (error) {
    console.error('Gemini generateChainFromCandidates Error:', error.message);
    throw new Error(`Failed to generate itinerary chain from candidates: ${error.message}`);
  }
};

/**
 * Legacy chain generation kept for backward compatibility.
 * Existing callers that still use the old flow will continue to work.
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
    const text = stripMarkdownFence(result.response.text().trim());

    const parsedArray = JSON.parse(text);
    if (!Array.isArray(parsedArray) || parsedArray.length !== 3) {
      throw new Error('AI did not return exactly 3 array items.');
    }

    return parsedArray;
  } catch (error) {
    console.error('Gemini generateChain Error:', error.message);
    throw new Error(`Failed to generate itinerary chain: ${error.message}`);
  }
};

/**
 * Generates a mystery surprise itinerary based on preferences.
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
    const text = stripMarkdownFence(result.response.text().trim());
    return JSON.parse(text);
  } catch (error) {
    console.error('Gemini generateSurprise Error:', error.message);
    throw new Error(`Failed to generate mystery surprise: ${error.message}`);
  }
};

/**
 * Matches user preferences to the best candidate experience using AI ranking,
 * then generates mystery teaser content.
 */
const matchAndGenerateMystery = async (preferences, candidates) => {
  const model = getModel();

  const systemInstruction = `You are an intelligent experience matching and mystery curator AI.

Given a user's preferences and a list of candidate experiences, you must:
1. RANK the candidates by how well they match the user's preferences (location, budget, type, vibe)
2. SELECT the single best match
3. Generate a mystery teaser for the selected experience WITHOUT revealing its exact name or details

You MUST return ONLY a valid JSON object. NO markdown formatting, NO backticks, NO extra text.

JSON Object Schema:
{
  "matchedExperienceId": "The exact 'id' string of the best matching candidate",
  "title": "A cryptic but alluring mystery title (DO NOT use the actual experience title)",
  "teaserDescription": "A 2-3 sentence teaser that builds excitement without spoiling the actual activity",
  "category": "The experience category",
  "vibe": "1-2 words describing the vibe (e.g., 'Serene & Zen', 'High Energy')",
  "preparationNotes": "What should they wear or bring? Keep it vague but helpful based on the actual experience."
}`;

  const fullPrompt = `${systemInstruction}

User Preferences:
${JSON.stringify(preferences, null, 2)}

Candidate Experiences:
${JSON.stringify(candidates, null, 2)}`;

  try {
    const result = await model.generateContent(fullPrompt);
    const text = stripMarkdownFence(result.response.text().trim());
    const parsedData = JSON.parse(text);

    const validIds = candidates.map((c) => c.id);
    if (!validIds.includes(parsedData.matchedExperienceId)) {
      parsedData.matchedExperienceId = candidates[0].id;
    }

    return parsedData;
  } catch (error) {
    console.error('Gemini matchAndGenerateMystery Error:', error.message);
    throw new Error(`Failed to match and generate mystery: ${error.message}`);
  }
};

module.exports = {
  enhanceText,
  generateChain,
  generateChainFromCandidates,
  generateSurprise,
  matchAndGenerateMystery,
};