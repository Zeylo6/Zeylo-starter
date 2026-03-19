const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const stripeService = require('../services/stripeService');
const { db } = require('../config/firebase');

const createIntent = async (req, res) => {
  try {
    const { amount, bookingId, email } = req.body;
    const paymentIntent = await stripeService.createPaymentIntent(amount, 'usd', { bookingId }, email);
    
    res.status(200).json({
      clientSecret: paymentIntent.client_secret,
      publishableKey: process.env.STRIPE_PUBLISHABLE_KEY,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const handleWebhook = async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === 'payment_intent.succeeded') {
    const paymentIntent = event.data.object;
    const bookingId = paymentIntent.metadata.bookingId;
    
    // Update booking status in Firestore
    await db.collection('bookings').doc(bookingId).update({
      status: 'confirmed',
      paymentId: paymentIntent.id,
      paidAt: new Date().toISOString(),
    });
  }

  res.json({ received: true });
};

module.exports = { createIntent, handleWebhook };
