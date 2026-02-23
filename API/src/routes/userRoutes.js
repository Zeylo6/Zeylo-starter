const express = require('express');
const { verifyToken, requireAdmin } = require('../middleware/auth');
const {
  listUsers,
  getUser,
  createUser,
  updateUser,
  deleteUser
} = require('../controllers/userController');

const router = express.Router();

// Admin-only CRUD
router.get('/', verifyToken, requireAdmin, listUsers);
router.get('/:id', verifyToken, requireAdmin, getUser);
router.post('/', verifyToken, requireAdmin, createUser);
router.patch('/:id', verifyToken, requireAdmin, updateUser);
router.delete('/:id', verifyToken, requireAdmin, deleteUser);

module.exports = router;