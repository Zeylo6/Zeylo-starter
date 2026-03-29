const stripe = process.env.STRIPE_SECRET_KEY
  ? require("stripe")(process.env.STRIPE_SECRET_KEY)
  : null;
const stripeService = require("../services/stripeService");
const { db } = require("../config/firebase");
const notificationService = require("../services/notificationService");

const createIntent = async (req, res) => {
  try {
    const { amount, bookingId, email, type = "booking", mysteryId } = req.body;

    //Attaching sticky notes (metadata) to the payment so we remember it later
    const metadata = { bookingId, type };
    if (mysteryId) metadata.mysteryId = mysteryId;

    //Asking the stripe to create a payment intent
    const paymentIntent = await stripeService.createPaymentIntent(
      amount,
      "usd",
      metadata,
      email,
    );

    //Returning the stripe's client secret into the flutter app
    res.status(200).json({
      clientSecret: paymentIntent.client_secret,
      publishableKey: process.env.STRIPE_PUBLISHABLE_KEY,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const handleWebhook = async (req, res) => {
  const sig = req.headers["stripe-signature"];
  let event;

  try {
    // This is the security check. Stripe sends a secret signature with every webhook.
    // If it doesn't match, it means the request is not actually from Stripe.
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET,
    );
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  //This is the event that is sent when the payment is successful
  if (event.type === "payment_intent.succeeded") {
    const paymentIntent = event.data.object;

    //Extracting the sticky notes we attached earlier
    const bookingId = paymentIntent.metadata.bookingId;
    const type = paymentIntent.metadata.type || "booking";
    d;
    if (type === "mystery") {
      const mysteryId = paymentIntent.metadata.mysteryId;
      if (mysteryId) {
        // Update mystery status in Firestore
        await db.collection("mysteries").doc(mysteryId).update({
          status: "accepted",
          paymentId: paymentIntent.id,
          paidAt: new Date().toISOString(),
        });
      }

      // Update booking status in Firestore to pending for the host to accept
      await db.collection("bookings").doc(bookingId).update({
        status: "pending",
        paymentStatus: "paid",
        paymentId: paymentIntent.id,
        paidAt: new Date().toISOString(),
      });

      // Notify host of new mystery booking
      const bookingDoc = await db.collection("bookings").doc(bookingId).get();
      if (bookingDoc.exists) {
        const hostId = bookingDoc.data().hostId;
        await notificationService.notifyHostOfBooking(hostId, {
          title: "New Mystery Booking! 🎁",
          body: "A seeker has been matched to your experience. Check it out!",
          bookingId,
          type: "mystery_booking",
        });
      }
    } else {
      // Update booking status in Firestore
      await db.collection("bookings").doc(bookingId).update({
        status: "confirmed",
        paymentId: paymentIntent.id,
        paidAt: new Date().toISOString(),
      });

      // Notify host of confirmed booking
      const bookingDoc = await db.collection("bookings").doc(bookingId).get();
      if (bookingDoc.exists) {
        const data = bookingDoc.data();
        await notificationService.notifyHostOfBooking(data.hostId, {
          title: "Booking Confirmed! ✅",
          body: `Booking for "${data.experienceTitle}" has been confirmed and paid.`,
          bookingId,
          type: "payment_received",
        });
      }
    }
  }

  res.json({ received: true });
};

const refundBooking = async (req, res) => {
  try {
    const { bookingId } = req.body;

    // Get booking doc
    const bookingRef = db.collection("bookings").doc(bookingId);
    const bookingDoc = await bookingRef.get();

    if (!bookingDoc.exists) {
      return res.status(404).json({ error: "Booking not found" });
    }

    const bookingData = bookingDoc.data();
    if (!bookingData.paymentId) {
      return res
        .status(400)
        .json({ error: "No payment ID found for this booking" });
    }

    // Call Stripe to refund
    const refund = await stripeService.refundPayment(bookingData.paymentId);

    // Update booking
    await bookingRef.update({
      status: "rejected",
      paymentStatus: "refunded",
      refundId: refund.id,
      updatedAt: new Date().toISOString(),
    });

    // Notify seeker of refund/rejection
    await notificationService.notifySeekerOfBookingUpdate(bookingData.userId, {
      title: "Booking Rejected ❌",
      body: `Your booking for "${bookingData.experienceTitle}" was rejected and a refund has been processed.`,
      bookingId,
      type: "booking_rejected",
    });

    res.status(200).json({ success: true, refund });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { createIntent, handleWebhook, refundBooking };
