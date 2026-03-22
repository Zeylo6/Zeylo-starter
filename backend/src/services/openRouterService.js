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
 * Enhance text with context-aware prompting via OpenRouter.
 */
const enhanceText = async (prompt, context) => {
  if (!OPENROUTER_API_KEY) {
    throw new Error('OPENROUTER_API_KEY is missing from environment variables.');
  }

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

  try {
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENROUTER_API_KEY}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "http://localhost:3000", // Optional, for OpenRouter rankings
        "X-Title": "Zeylo AI", // Optional, for OpenRouter rankings
      },
      body: JSON.stringify({
        "model": OPENROUTER_MODEL,
        "messages": [
          { "role": "system", "content": systemInstruction },
          { "role": "user", "content": prompt }
        ],
      })
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('OpenRouter API Error:', data);
      throw new Error(data.error?.message || `OpenRouter API failed with status ${response.status}`);
    }

    return data.choices[0].message.content.trim();
  } catch (error) {
    console.error('OpenRouter enhanceText Error:', error.message);
    throw new Error(`Failed to enhance text with OpenRouter: ${error.message}`);
  }
};

module.exports = {
  enhanceText,
  stripMarkdownFence,
};
