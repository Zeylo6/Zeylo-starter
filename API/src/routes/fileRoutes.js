const express = require('express');
const path = require('path');
const multer = require('multer');
const { verifyToken } = require('../middleware/auth');
const { createFile, listFiles, getFile, updateFile, deleteFile, uploadFiles } = require('../controllers/fileController');

const router = express.Router();

router.use(verifyToken);
// POST metadata-only file (existing behavior)
router.post('/', createFile);
// POST binary uploads from dashboard: accepts form-data field `files` (multiple) and stores under file-upload/
const storage = multer.diskStorage({
	destination: (_req, _file, cb) => cb(null, path.join(process.cwd(), 'file-upload')),
	filename: (_req, file, cb) => {
		const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
		const ext = path.extname(file.originalname) || '';
		cb(null, `${unique}${ext}`);
	}
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } }); // 50MB limit
router.post('/upload', upload.array('files'), uploadFiles);
router.get('/', listFiles);
router.get('/:id', getFile);
router.patch('/:id', updateFile);
router.delete('/:id', deleteFile);

module.exports = router;