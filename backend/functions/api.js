const serverless = require('serverless-http');
const app = require('../src/index.js');

// Wrap the Express app in a serverless handler for Netlify Functions
module.exports.handler = app.handler || serverless(app);
