require('dotenv').config();
const express = require('express');
const cors = require('cors');
const serverless = require('serverless-http');

const apiRoutes = require('./routes/api');
// import your other existing routes here, e.g.:
// const authRoutes = require('./routes/auth');
// const bookingRoutes = require('./routes/booking');

const app = express();

app.use(cors());
app.use(express.json());

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api', apiRoutes);
// app.use('/api/auth', authRoutes);
// app.use('/api/bookings', bookingRoutes);

app.get('/', (req, res) => res.json({ status: 'ok' }));

// ── Local dev server ──────────────────────────────────────────────────────────
if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
}

// ── Serverless export (Netlify) ───────────────────────────────────────────────
module.exports.handler = serverless(app);