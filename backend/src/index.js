require('dotenv').config();
const express = require('express');
const cors = require('cors');

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (err, origin) => {
  console.error(`Caught exception: ${err}\nException origin: ${origin}`);
});

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
  const server = app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  
  server.on('error', (error) => {
    console.error('Server error:', error);
    if (error.code === 'EADDRINUSE') {
      console.error(`Port ${PORT} is already in use. Please kill the process using it.`);
    }
  });
}

// ── Serverless export (Netlify) ───────────────────────────────────────────────
module.exports = app;
module.exports.handler = serverless(app);