const fs = require('fs');
const OpenAI = require('openai');
const { recognize } = require('tesseract.js');

// Read API key only from environment. Do NOT hard-code keys in source.
const OPENAI_KEY = process.env.OPENAI_KEY || process.env.OPENAI_API_KEY;
const OPENAI_MODEL = process.env.OPENAI_MODEL || 'gpt-3.5-turbo';
const client = new OpenAI({ apiKey: OPENAI_KEY });

async function runOcr(filePath) {
  // Use the high-level recognize API which is compatible across tesseract.js versions
  const res = await recognize(filePath, 'eng', { logger: () => {} });
  return (res && res.data && res.data.text) ? res.data.text : '';
}

async function extractCardFromImage(filePath) {
  if (!OPENAI_KEY) {
    throw new Error('OpenAI API key not configured. Set OPENAI_KEY or OPENAI_API_KEY in your environment.');
  }

  if (!fs.existsSync(filePath)) throw new Error('file not found: ' + filePath);

  // 1) Run OCR to get text from the image
  const ocrText = await runOcr(filePath);

  // 2) Build a prompt to extract structured fields from the OCR text
  const prompt = `You will be given the raw text extracted from a business card. Extract exactly the following JSON object and nothing else with keys: name, title, phones (array), emails (array), website. Use null for missing scalar fields and empty arrays for missing lists. Here is the text:\n\n${ocrText}`;

  try {
    const response = await client.responses.create({
      model: OPENAI_MODEL,
      input: prompt,
      max_output_tokens: 700,
    });

    // Try to retrieve text output
    let textOut = '';
    if (response.output && Array.isArray(response.output) && response.output.length) {
      const content = response.output[0].content || [];
      for (const c of content) {
        if (c.type === 'output_text' && c.text) {
          textOut += c.text + '\n';
        } else if (c.text) {
          textOut += c.text + '\n';
        }
      }
    } else if (response.output_text) {
      textOut = response.output_text;
    } else {
      textOut = JSON.stringify(response);
    }

    const trimmed = textOut.trim();
    try {
      return JSON.parse(trimmed);
    } catch (e) {
      const maybe = trimmed.match(/\{[\s\S]*\}/);
      if (maybe) return JSON.parse(maybe[0]);
      return { raw: trimmed, ocrText };
    }
  } catch (err) {
    console.error('OpenAI extract error:', err);
    throw err;
  }
}

module.exports = { extractCardFromImage };
