const mongoose = require('mongoose');
const Record = require('../models/recordModel');

// Only allow fields we support
const pickRecord = (src) => {
  const out = {};
  if ('name' in src) out.name = src.name;
  if ('title' in src) out.title = src.title;
  if ('phoneNumbers' in src) out.phoneNumbers = Array.isArray(src.phoneNumbers) ? src.phoneNumbers : [];
  if ('mails' in src) out.mails = Array.isArray(src.mails) ? src.mails : [];
  if ('website' in src) out.website = src.website;
  if ('photo' in src) out.photo = src.photo; // add photo field
  return out;
};

const createRecord = async (req, res) => {
  try {
    const body = pickRecord(req.body);
    // Admin can create for any code (optional query/body); user uses own code always
    const code = req.user.role === 'admin'
      ? (req.body.code || req.user.code)
      : req.user.code;

    if (!code || !body.name) return res.status(400).json({ error: 'code (implicit) and name required' });

    const rec = await Record.create({ code, ...body });
    return res.status(201).json(rec);
  } catch (e) {
    console.error('createRecord error:', e);
    return res.status(500).json({ error: 'Failed to create record' });
  }
};

const listRecords = async (req, res) => {
  try {
    const filter = {};
    // Admin can filter by code; users are restricted to their own code
    if (req.user.role === 'admin') {
      if (req.query.code) filter.code = req.query.code;
    } else {
      filter.code = req.user.code;
    }
    const items = await Record.find(filter).sort({ createdAt: -1 });
    return res.json(items);
  } catch (e) {
    console.error('listRecords error:', e);
    return res.status(500).json({ error: 'Failed to fetch records' });
  }
};

const getRecord = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ error: 'Invalid id' });
    const rec = await Record.findById(id);
    if (!rec) return res.status(404).json({ error: 'Record not found' });
    if (req.user.role !== 'admin' && rec.code !== req.user.code) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    return res.json(rec);
  } catch (e) {
    console.error('getRecord error:', e);
    return res.status(500).json({ error: 'Failed to fetch record' });
  }
};

const updateRecord = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ error: 'Invalid id' });
    const rec = await Record.findById(id);
    if (!rec) return res.status(404).json({ error: 'Record not found' });

    if (req.user.role !== 'admin' && rec.code !== req.user.code) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const updates = pickRecord(req.body);
    // Never allow changing code via update
    const updated = await Record.findByIdAndUpdate(id, updates, { new: true, runValidators: true });
    return res.json(updated);
  } catch (e) {
    console.error('updateRecord error:', e);
    return res.status(500).json({ error: 'Failed to update record' });
  }
};

const deleteRecord = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) return res.status(400).json({ error: 'Invalid id' });
    const rec = await Record.findById(id);
    if (!rec) return res.status(404).json({ error: 'Record not found' });

    if (req.user.role !== 'admin' && rec.code !== req.user.code) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    await Record.findByIdAndDelete(id);
    return res.status(204).send();
  } catch (e) {
    console.error('deleteRecord error:', e);
    return res.status(500).json({ error: 'Failed to delete record' });
  }
};

module.exports = { createRecord, listRecords, getRecord, updateRecord, deleteRecord };