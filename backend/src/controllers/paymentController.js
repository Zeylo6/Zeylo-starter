const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const stripeService = require('../services/stripeService');
const { db } = require('../config/firebase');

const createIntent = async (req, res) => {
  try {
    const { amount, bookingId, email, type = 'booking', mysteryId } = req.body;
    const metadata = { bookingId, type };
    if (mysteryId) metadata.mysteryId = mysteryId;
    const paymentIntent = await stripeService.createPaymentIntent(amount, 'usd', metadata, email);
    
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
    const type = paymentIntent.metadata.type || 'booking';
    
    if (type === 'mystery') {
      const mysteryId = paymentIntent.metadata.mysteryId;
      if (mysteryId) {
        // Update mystery status in Firestore
        await db.collection('mysteries').doc(mysteryId).update({
          status: 'accepted',
          paymentId: paymentIntent.id,
          paidAt: new Date().toISOString(),
        });
      }
      
      // Update booking status in Firestore to pending for the host to accept
      await db.collection('bookings').doc(bookingId).update({
        status: 'pending',
        paymentStatus: 'paid',
        paymentId: paymentIntent.id,
        paidAt: new Date().toISOString(),
      });
    } else {
      // Update booking status in Firestore
      await db.collection('bookings').doc(bookingId).update({
        status: 'confirmed',
        paymentId: paymentIntent.id,
        paidAt: new Date().toISOString(),
      });
    }
  }

  res.json({ received: true });
};

const refundBooking = async (req, res) => {
  try {
    const { bookingId } = req.body;
    
    // Get booking doc
    const bookingRef = db.collection('bookings').doc(bookingId);
    const bookingDoc = await bookingRef.get();
    
    if (!bookingDoc.exists) {
      return res.status(404).json({ error: 'Booking not found' });
    }
    
    const bookingData = bookingDoc.data();
    if (!bookingData.paymentId) {
      return res.status(400).json({ error: 'No payment ID found for this booking' });
    }

    // Call Stripe to refund
    const refund = await stripeService.refundPayment(bookingData.paymentId);
    
    // Update booking
    await bookingRef.update({
      status: 'rejected',
      paymentStatus: 'refunded',
      refundId: refund.id,
      updatedAt: new Date().toISOString(),
    });
    
    res.status(200).json({ success: true, refund });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { createIntent, handleWebhook, refundBooking };
