require('dotenv').config();
const path = require('path');
const { extractCardFromImage } = require(path.join(__dirname, 'services', 'openaiService'));

(async () => {
  try {
    // Update this filename to a file that exists in your uploads/ folder.
    const filename = 'uploads/1761715640827-582151433.jpg';
    const file = path.resolve(filename);
    console.log('Testing file:', file);
    const out = await extractCardFromImage(file);
    console.log('RESULT:', JSON.stringify(out, null, 2));
  } catch (err) {
    console.error('ERROR:', err);
    process.exit(1);
  }
})();
