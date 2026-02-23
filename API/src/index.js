require('dotenv').config();
const express = require('express');
const cors = require('cors');
const dbConnect = require('./config/dbConnect');
const authroutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const recordRoutes = require('./routes/recordRoutes');
const fileRoutes = require('./routes/fileRoutes');
const meRoutes = require('./routes/meRoutes');

dbConnect();

const app = express();
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

// Serve uploaded files
// Serve dashboard file uploads (pdfs, ppts)
app.use('/file-upload', express.static('file-upload'));

// Note: Scan/OCR/OpenAI features removed from this build.

// Health check
app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.use('/api/auth', authroutes);
app.use('/api/users', userRoutes);
app.use('/api/records', recordRoutes);
app.use('/api/files', fileRoutes);
app.use('/api/me', meRoutes);

// 404
app.use((req, res) => res.status(404).json({ error: 'Not found' }));

// Error handler
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Server error' });
});

const PORT = process.env.PORT || 7001;
app.listen(PORT, () => console.log(`API running on port ${PORT}`));