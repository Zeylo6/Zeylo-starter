/**
 * OpenRouter Service
 * Provides AI capabilities using OpenRouter.ai (OpenAI-compatible API)
 */

const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
const OPENROUTER_MODEL = process.env.OPENROUTER_MODEL || 'nvidia/nemotron-3-super-120b-a12b:free';

/**
 * Safely strips markdown fences if AI wraps JSON in ```json
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
 * Generic helper to call OpenRouter API
 */
const callOpenRouter = async (systemInstruction, userContent) => {
  if (!OPENROUTER_API_KEY) {
    throw new Error('OPENROUTER_API_KEY is missing from environment variables.');
  }

  const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${OPENROUTER_API_KEY}`,
      "Content-Type": "application/json",
      "HTTP-Referer": "http://localhost:3000",
      "X-Title": "Zeylo AI",
    },
    body: JSON.stringify({
      "model": OPENROUTER_MODEL,
      "messages": [
        { "role": "system", "content": systemInstruction },
        { "role": "user", "content": userContent }
      ],
    })
  });

  const data = await response.json();

  if (!response.ok) {
    console.error('OpenRouter API Error:', data);
    throw new Error(data.error?.message || `OpenRouter API failed with status ${response.status}`);
  }

  return data.choices[0].message.content.trim();
};

/**
 * Enhance text with context-aware prompting via OpenRouter.
 */
const enhanceText = async (prompt, context) => {
  let systemInstruction = '';

  switch (context) {
    case 'mood':
      systemInstruction = `You are an elite emotional-intelligence writing assistant and poet for a premium social/discovery app.
      The user will describe how they feel, often in a rough or short way.
      Your task is to rewrite their message into a highly expressive, vivid, and beautifully eloquent paragraph (2-3 sentences max).
      Capture the exact nuance of their emotion and translate it into a compelling desire for a specific kind of experience or connection.
      Use evocative language and sensory details. Do not add conversational commentary, just return the enhanced description directly. Keep it strictly in the first-person ("I").`;
      break;
    case 'host_experience':
      systemInstruction = `You are a world-class luxury travel copywriter and marketing expert.
      The host has provided a rough draft description of the experience they want to offer.
      Your job is to rewrite it into a highly engaging, irresistible, and beautifully descriptive marketing pitch.
      Format it into 3-4 flowing paragraphs. Start with a captivating hook. Emphasize sensory details (sights, sounds, tastes), the unique value of the experience, and the emotional takeaway.
      Make the reader feel like they absolutely must book this. Do not add any conversational filler or meta-talk; just return the perfect marketing copy.`;
      break;
    case 'chain_itinerary':
    case 'chain_description':
      systemInstruction = `You are a master travel curator and storyteller for an exclusive lifestyle booking platform.
      The user will provide a simple idea for a day-long itinerary or experience chain.
      Your job is to rewrite it into an inspiring, intricately detailed, and highly polished narrative of a complete travel experience. 
      Use rich, descriptive vocabulary to paint a picture of the vibe, the seamless flow of activities, and why this specific combination is an unforgettable journey.
      Make it about 2-3 paragraphs. Do not add extra conversational text, just return the enhanced, luxurious itinerary narrative.`;
      break;
    case 'business_review':
      systemInstruction = `You are a strict, highly analytical business compliance and quality assurance AI.
      The user has submitted text describing their business for platform verification.
      Summarize the key offerings with professional precision, explicitly identify any potential red flags, legal risks, or restricted services based on modern commerce standards, and provide a definitive 1-sentence recommendation on its legitimacy and safety.`;
      break;
    default:
      systemInstruction = `You are an elite writing assistant and copy editor. Please elevate the grammar, flow, vocabulary, and clarity of the following text, transforming it into highly polished and engaging prose while preserving its original meaning perfectly.`;
  }

  try {
    return await callOpenRouter(systemInstruction, prompt);
  } catch (error) {
    console.error('OpenRouter enhanceText Error:', error.message);
    throw new Error(`Failed to enhance text with OpenRouter: ${error.message}`);
  }
};

/**
 * Generate a real experience chain from a list of candidate experiences.
 */
const generateChainFromCandidates = async ({
  prompt,
  location,
  date,
  totalTime,
  interests = [],
  candidates = [],
}) => {
  if (!Array.isArray(candidates) || candidates.length === 0) {
    throw new Error('No candidate experiences were provided to AI.');
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

  const fullPrompt = `User prompt: ${prompt}\nLocation: ${location || 'Anywhere'}\nDate: ${date || 'Any day'}\nTotal time: ${totalTime}\nInterests: ${(interests || []).join(', ') || 'None specified'}\n\nAvailable experiences:\n${JSON.stringify(compactCandidates)}`;

  try {
    const rawText = await callOpenRouter(systemInstruction, fullPrompt);
    const cleaned = stripMarkdownFence(rawText);
    const parsed = JSON.parse(cleaned);

    if (!Array.isArray(parsed)) {
      throw new Error('AI did not return a JSON array.');
    }

    return parsed;
  } catch (error) {
    console.error('OpenRouter generateChainFromCandidates Error:', error.message);
    throw new Error(`Failed to generate itinerary chain from candidates: ${error.message}`);
  }
};

/**
 * Legacy chain generation kept for backward compatibility.
 */
const generateChain = async (prompt, location, date) => {
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

  const fullPrompt = `Criteria:\nPrompt: ${prompt}\nLocation: ${location || 'Anywhere'}\nDate: ${date || 'Any day'}`;

  try {
    const rawText = await callOpenRouter(systemInstruction, fullPrompt);
    const text = stripMarkdownFence(rawText);

    const parsedArray = JSON.parse(text);
    if (!Array.isArray(parsedArray) || parsedArray.length !== 3) {
      throw new Error('AI did not return exactly 3 array items.');
    }

    return parsedArray;
  } catch (error) {
    console.error('OpenRouter generateChain Error:', error.message);
    throw new Error(`Failed to generate itinerary chain: ${error.message}`);
  }
};

/**
 * Generates a mystery surprise itinerary based on preferences.
 */
const generateSurprise = async (preferences) => {
  const systemInstruction = `You are a boutique mystery experience curator.
    The user has provided a set of preferences. Generate a highly unique, slightly secretive "Mystery Surprise" experience for them.
    You MUST return ONLY a valid JSON object. NO markdown formatting, NO backticks, NO extra text.

    JSON Object Schema:
    {
      "title": "A highly creative, poetic, and alluring mystery title (e.g. 'The Midnight Symphony')",
      "teaserDescription": "A thrilling, vivid, and highly descriptive 3-4 sentence teaser that builds intense excitement, using strong evocative language without spoiling the exact activity",
      "category": "The matched category",
      "vibe": "1-3 words describing the atmospheric vibe (e.g., 'Dark & Moody', 'Pure Adrenaline')",
      "preparationNotes": "What should they wear or bring? Keep it vague but highly intriguing and helpful."
    }`;

  const fullPrompt = `User Preferences:\n${JSON.stringify(preferences)}`;

  try {
    const rawText = await callOpenRouter(systemInstruction, fullPrompt);
    const text = stripMarkdownFence(rawText);
    return JSON.parse(text);
  } catch (error) {
    console.error('OpenRouter generateSurprise Error:', error.message);
    throw new Error(`Failed to generate mystery surprise: ${error.message}`);
  }
};

/**
 * Matches user preferences to the best candidate experience using AI ranking,
 * then generates mystery teaser content.
 */
const matchAndGenerateMystery = async (preferences, candidates) => {
  const systemInstruction = `You are an intelligent experience matching and mystery curator AI.

Given a user's preferences and a list of candidate experiences, you must:
1. RANK the candidates by how well they match the user's preferences (location, budget, type, vibe)
2. SELECT the single best match
3. Generate a mystery teaser for the selected experience WITHOUT revealing its exact name or details

You MUST return ONLY a valid JSON object. NO markdown formatting, NO backticks, NO extra text.

JSON Object Schema:
{
  "matchedExperienceId": "The exact 'id' string of the best matching candidate",
  "title": "A highly creative, poetic, and alluring mystery title (DO NOT use the actual experience title)",
  "teaserDescription": "A thrilling, vivid, and highly descriptive 3-4 sentence teaser that builds intense excitement, using strong evocative language without spoiling the actual activity",
  "category": "The experience category",
  "vibe": "1-3 words describing the atmospheric vibe (e.g., 'Ethereal & Zen', 'Pulse-Pounding Energy')",
  "preparationNotes": "What should they wear or bring? Keep it vague but highly intriguing and helpful."
}`;

  const fullPrompt = `User Preferences:\n${JSON.stringify(preferences, null, 2)}\n\nCandidate Experiences:\n${JSON.stringify(candidates, null, 2)}`;

  try {
    const rawText = await callOpenRouter(systemInstruction, fullPrompt);
    const text = stripMarkdownFence(rawText);
    const parsedData = JSON.parse(text);

    const validIds = candidates.map((c) => c.id);
    if (!validIds.includes(parsedData.matchedExperienceId)) {
      parsedData.matchedExperienceId = candidates[0].id;
    }

    return parsedData;
  } catch (error) {
    console.error('OpenRouter matchAndGenerateMystery Error:', error.message);
    throw new Error(`Failed to match and generate mystery: ${error.message}`);
  }
};

module.exports = {
  enhanceText,
  generateChain,
  generateChainFromCandidates,
  generateSurprise,
  matchAndGenerateMystery,
  stripMarkdownFence,
};
