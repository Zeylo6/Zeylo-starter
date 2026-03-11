require('dotenv').config();
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0'; // Aggressive bypass for self-signed certs (e.g. corporate proxies)
const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes/api');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api', apiRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
