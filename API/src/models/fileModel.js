const mongoose = require('mongoose');

const fileSchema = new mongoose.Schema(
  {
    code: { type: String, required: true, index: true }, // user's 6-digit code
    mail: { type: String, required: true },
    mailSubject: { type: String },
    mailBody: { type: String },
    fileLinks: { type: [String], default: [] }
  },
  { timestamps: true }
);

fileSchema.index({ code: 1, createdAt: -1 });

module.exports = mongoose.model('File', fileSchema);