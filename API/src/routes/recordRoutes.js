const express = require('express');
const { verifyToken } = require('../middleware/auth');
const { createRecord, listRecords, getRecord, updateRecord, deleteRecord } = require('../controllers/recordController');

const router = express.Router();

router.use(verifyToken);
router.post('/', createRecord);
router.get('/', listRecords);
router.get('/:id', getRecord);
router.patch('/:id', updateRecord);
router.delete('/:id', deleteRecord);

module.exports = router;