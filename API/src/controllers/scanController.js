const fs = require('fs');
const path = require('path');
const openaiService = require('../services/openaiService');
const FileItem = require('../models/fileModel');

// Controller to handle uploaded card image, call OpenAI to extract fields
async function processScan(req, res) {
  try {
    if (!req.file) return res.status(400).json({ error: 'No image uploaded' });

    const filePath = req.file.path;

    // call service that sends image to OpenAI and parses response
    const extracted = await openaiService.extractCardFromImage(filePath);

    // respond with parsed fields and image URL
    const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${path.basename(filePath)}`;

    // Persist file metadata mapped to the authenticated user when available
    try {
      const code = req.user?.code || (req.user && req.user.role === 'admin' ? req.body.code : undefined);
      const mail = (extracted && Array.isArray(extracted.emails) && extracted.emails.length) ? extracted.emails[0] : '';

      if (code) {
        const fileDoc = await FileItem.create({
          code,
          mail: mail || 'unknown@local',
          fileLinks: [imageUrl]
        });
        return res.status(201).json({ success: true, data: extracted, imageUrl, file: fileDoc });
      }
    } catch (e) {
      console.error('Failed to persist uploaded file record:', e);
      // continue and return success response even if persisting failed
    }

    res.json({ success: true, data: extracted, imageUrl });
  } catch (err) {
    console.error('processScan error:', err);
    res.status(500).json({ error: 'Failed to process image' });
  }
}

// Process a local file already present on the server. Body: { filename: "uploads/abc.jpg" }
async function processLocalScan(req, res) {
  try {
    const { filename } = req.body || {};
    if (!filename) return res.status(400).json({ error: 'filename is required in body' });

    // Prevent path traversal - only allow files inside uploads
    const uploadsDir = path.join(process.cwd(), 'uploads');
    const resolved = path.resolve(process.cwd(), filename);
    if (!resolved.startsWith(uploadsDir)) return res.status(400).json({ error: 'invalid filename' });

    if (!fs.existsSync(resolved)) return res.status(404).json({ error: 'file not found' });

    const extracted = await openaiService.extractCardFromImage(resolved);
    const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${path.basename(resolved)}`;
    res.json({ success: true, data: extracted, imageUrl });
  } catch (err) {
    console.error('processLocalScan error:', err);
    res.status(500).json({ error: 'Failed to process local image' });
  }
}

module.exports = { processScan, processLocalScan };
