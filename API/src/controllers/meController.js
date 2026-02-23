const User = require('../models/userModel');
const Record = require('../models/recordModel');
const FileItem = require('../models/fileModel');

const getMe = async (req, res) => {
  try {
    const userId = req.user?.sub;
    const code = req.user?.code;
    if (!userId || !code) return res.status(401).json({ error: 'Unauthorized' });

    const [user, records, files] = await Promise.all([
      User.findById(userId).select('username role code createdAt updatedAt').lean(),
      Record.find({ code }).sort({ createdAt: -1 }).lean(),
      FileItem.find({ code }).sort({ createdAt: -1 }).lean()
    ]);

    if (!user) return res.status(404).json({ error: 'User not found' });

    return res.json({ user, records, files });
  } catch (e) {
    console.error('getMe error:', e);
    return res.status(500).json({ error: 'Failed to load profile' });
  }
};

module.exports = { getMe };