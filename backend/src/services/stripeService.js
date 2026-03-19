const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const createPaymentIntent = async (amount, currency = 'usd', metadata = {}, receiptEmail = null) => {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Stripe expects amount in cents
      currency,
      metadata,
      automatic_payment_methods: { enabled: true },
      ...(receiptEmail && { receipt_email: receiptEmail }),
    });
    return paymentIntent;
  } catch (error) {
    console.error('Stripe Error:', error);
    throw error;
  }
};

module.exports = { createPaymentIntent };
