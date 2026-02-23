require('dotenv').config();
const OpenAI = require('openai');

const key = process.env.OPENAI_KEY || process.env.OPENAI_API_KEY;
if (!key) {
  console.error('No OPENAI_KEY or OPENAI_API_KEY found in environment or .env');
  process.exit(1);
}

const client = new OpenAI({ apiKey: key });

(async () => {
  try {
    console.log('Checking OpenAI key by listing available models (first 10)...');
    const res = await client.models.list();
    const models = (res?.data || []).slice(0, 10).map(m => m.id);
    console.log('Success — models visible (first 10):', models);
    process.exit(0);
  } catch (err) {
    console.error('OpenAI call failed:');
    console.error(err);
    process.exit(2);
  }
})();
