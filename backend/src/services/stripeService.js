const stripe = process.env.STRIPE_SECRET_KEY
  ? require('stripe')(process.env.STRIPE_SECRET_KEY)
  : null;

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

const refundPayment = async (paymentIntentId) => {
  try {
    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
    });
    return refund;
  } catch (error) {
    console.error('Stripe Refund Error:', error);
    throw error;
  }
};

module.exports = { createPaymentIntent, refundPayment };
