const mongoose = require('mongoose');
const FileItem = require('../models/fileModel');

const pickFile = (src) => {
  const out = {};
  if ('mail' in src) out.mail = src.mail;
  if ('mailSubject' in src) out.mailSubject = src.mailSubject;
  if ('mailBody' in src) out.mailBody = src.mailBody;
  if ('fileLinks' in src) out.fileLinks = Array.isArray(src.fileLinks) ? src.fileLinks : [];
  return out;
};

const createFile = async (req, res) => {
  try {
    const body = pickFile(req.body);
    const code = req.user.role === 'admin'
      ? (req.body.code || req.user.code)
      : req.user.code;

    if (!code || !body.mail) return res.status(400).json({ error: 'code (implicit) and mail required' });

    const doc = await FileItem.create({ code, ...body });
    return res.status(201).json(doc);
  } catch (e) {
    console.error('createFile error:', e);
    return res.status(500).json({ error: 'Failed to create file' });
  }
};

const listFiles = async (req, res) => {
  try {
    const filter = {};
    if (req.user.role === 'admin') {
      if (req.query.code) filter.code = req.query.code;
    } else {
      filter.code = req.user.code;
    }
    const items = await FileItem.find(filter).sort({ createdAt: -1 });
    return res.json(items);
  } catch (e) {
    console.error('listFiles error:', e);
    return res.status(500).json({ error: 'Failed to fetch files' });
  }
};

const getFile = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ error: 'Invalid id' });
    const doc = await FileItem.findById(id);
    if (!doc) return res.status(404).json({ error: 'File not found' });
    if (req.user.role !== 'admin' && doc.code !== req.user.code) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    return res.json(doc);
  } catch (e) {
    console.error('getFile error:', e);
    return res.status(500).json({ error: 'Failed to fetch file' });
  }
};

const updateFile = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ error: 'Invalid id' });
    const existing = await FileItem.findById(id);
    if (!existing) return res.status(404).json({ error: 'File not found' });

    if (req.user.role !== 'admin' && existing.code !== req.user.code) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const updates = pickFile(req.body);
    const updated = await FileItem.findByIdAndUpdate(id, updates, { new: true, runValidators: true });
    return res.json(updated);
  } catch (e) {
    console.error('updateFile error:', e);
    return res.status(500).json({ error: 'Failed to update file' });
  }
};

const deleteFile = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ error: 'Invalid id' });
    const existing = await FileItem.findById(id);
    if (!existing) return res.status(404).json({ error: 'File not found' });

    if (req.user.role !== 'admin' && existing.code !== req.user.code) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    await FileItem.findByIdAndDelete(id);
    return res.status(204).send();
  } catch (e) {
    console.error('deleteFile error:', e);
    return res.status(500).json({ error: 'Failed to delete file' });
  }
};

// Handle binary uploads from dashboard (pdfs, ppts, etc.)
// Expects form-data with field `files` (one or more files). Creates a FileItem linked to req.user.code
const uploadFiles = async (req, res) => {
  try {
    if (!req.files || !req.files.length) return res.status(400).json({ error: 'No files uploaded' });

    const code = req.user.role === 'admin' ? (req.body.code || req.user.code) : req.user.code;
    if (!code) return res.status(400).json({ error: 'Missing user code' });

    // Build accessible URLs for saved files (served at /file-upload)
    const base = `${req.protocol}://${req.get('host')}/file-upload`;
    const fileLinks = req.files.map(f => `${base}/${encodeURIComponent(f.filename)}`);

    // Optional mail field from body
    const mail = req.body.mail || '';

    const doc = await FileItem.create({ code, mail: mail || 'unknown@local', fileLinks });
    return res.status(201).json(doc);
  } catch (e) {
    console.error('uploadFiles error:', e);
    return res.status(500).json({ error: 'Failed to upload files' });
  }
};

module.exports = { createFile, listFiles, getFile, updateFile, deleteFile, uploadFiles };