const express = require('express');
const multer = require('multer');
const path = require('path');
const { processScan, processLocalScan } = require('../controllers/scanController');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

// configure multer to save uploads to /uploads
const storage = multer.diskStorage({
  destination: function (_req, _file, cb) {
    cb(null, path.join(process.cwd(), 'uploads'));
  },
  filename: function (_req, file, cb) {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `${unique}${ext}`);
  }
});

// Accept images, PDFs and PPT(X). Enforce a reasonable file size limit (20MB).
const allowedTypes = [
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/pdf',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'application/vnd.ms-powerpoint'
];

const upload = multer({
  storage,
  limits: { fileSize: 20 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (allowedTypes.includes(file.mimetype)) cb(null, true);
    else cb(new Error('Invalid file type'));
  }
});

// POST /api/scan - accepts form-data with field `image`
// Require authenticated user for scanning/uploading so we can map files to users
router.post('/scan', verifyToken, upload.single('image'), processScan);

// POST /api/scan/local - accepts JSON { filename: 'uploads/xxxx.jpg' }
// This helper is temporary for testing server-side files already present in uploads/
router.post('/scan/local', express.json(), processLocalScan);

module.exports = router;
