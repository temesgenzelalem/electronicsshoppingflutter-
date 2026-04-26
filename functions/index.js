const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.key);
const nodemailer = require('nodemailer');
const PDFDocument = require('pdfkit');

admin.initializeApp();

// Email transporter
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.pass,
  },
});

// Process payment
exports.processPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { amount, currency, paymentMethodId, orderId } = data;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100, // Convert to cents
      currency: currency,
      payment_method: paymentMethodId,
      confirm: true,
      automatic_payment_methods: {
        enabled: true,
      },
    });

    // Update order status
    await admin.firestore().collection('orders').doc(orderId).update({
      paymentId: paymentIntent.id,
      status: 'confirmed',
    });

    return { success: true, paymentIntent };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Send order confirmation email
exports.sendOrderConfirmationEmail = functions.https.onCall(async (data, context) => {
  const { orderId } = data;

  const orderDoc = await admin.firestore().collection('orders').doc(orderId).get();
  const order = orderDoc.data();

  const userDoc = await admin.firestore().collection('users').doc(order.userId).get();
  const user = userDoc.data();

  const mailOptions = {
    from: 'ElectroMart Pro <noreply@electromartpro.com>',
    to: user.email,
    subject: `Order Confirmation - ${orderId}`,
    html: `
      <h1>Thank you for your order!</h1>
      <p>Order ID: ${orderId}</p>
      <p>Total: \$${order.totalAmount}</p>
      <p>Status: ${order.status}</p>
    `,
  };

  await transporter.sendMail(mailOptions);
});

// Generate invoice PDF
exports.generateInvoice = functions.https.onCall(async (data, context) => {
  const { orderId } = data;

  const orderDoc = await admin.firestore().collection('orders').doc(orderId).get();
  const order = orderDoc.data();

  const doc = new PDFDocument();
  let buffers = [];
  doc.on('data', buffers.push.bind(buffers));
  doc.on('end', () => {
    const pdfData = Buffer.concat(buffers);
    // Upload to Storage and return URL
  });

  doc.fontSize(25).text('ElectroMart Pro Invoice', 100, 100);
  doc.text(`Order ID: ${orderId}`, 100, 150);
  doc.text(`Total: \$${order.totalAmount}`, 100, 200);

  doc.end();

  return { success: true };
});

// Update product stock
exports.updateProductStock = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();

    for (const item of order.items) {
      const productRef = admin.firestore().collection('products').doc(item.productId);
      await admin.firestore().runTransaction(async (transaction) => {
        const productDoc = await transaction.get(productRef);
        const newStock = productDoc.data().stock - item.quantity;
        transaction.update(productRef, { stock: newStock });
      });
    }
  });

// Send push notification
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  const { userId, title, body, data: notificationData } = data;

  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const fcmToken = userDoc.data().fcmToken;

  if (fcmToken) {
    const message = {
      token: fcmToken,
      notification: {
        title: title,
        body: body,
      },
      data: notificationData,
    };

    await admin.messaging().send(message);
  }

  // Also save to Firestore notifications
  await admin.firestore().collection('notifications').doc(userId).collection('notifications').add({
    title,
    body,
    type: 'general',
    data: notificationData,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});

// Clean abandoned carts
exports.cleanAbandonedCarts = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const carts = await admin.firestore()
      .collection('carts')
      .where('updatedAt', '<', twentyFourHoursAgo)
      .get();

    const batch = admin.firestore().batch();
    carts.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
  });

// Generate sales report
exports.generateSalesReport = functions.https.onCall(async (data, context) => {
  const { startDate, endDate } = data;

  const orders = await admin.firestore()
    .collection('orders')
    .where('orderDate', '>=', new Date(startDate))
    .where('orderDate', '<=', new Date(endDate))
    .get();

  let totalSales = 0;
  let totalOrders = orders.size;

  orders.forEach((doc) => {
    totalSales += doc.data().totalAmount;
  });

  return {
    totalSales,
    totalOrders,
    averageOrderValue: totalSales / totalOrders,
  };
});

// Admin functions
exports.addProduct = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Check if user is admin
  const userDoc = await admin.firestore().collection('users').doc(context.auth.uid).get();
  if (userDoc.data().role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'User must be admin');
  }

  await admin.firestore().collection('products').add(data);
});

exports.updateProduct = functions.https.onCall(async (data, context) => {
  const { productId, ...updateData } = data;

  await admin.firestore().collection('products').doc(productId).update(updateData);
});

exports.deleteProduct = functions.https.onCall(async (data, context) => {
  const { productId } = data;

  await admin.firestore().collection('products').doc(productId).delete();
});

exports.addBanner = functions.https.onCall(async (data, context) => {
  await admin.firestore().collection('banners').add(data);
});

exports.createCoupon = functions.https.onCall(async (data, context) => {
  await admin.firestore().collection('coupons').doc(data.code).set(data);
});

exports.updateOrderStatus = functions.https.onCall(async (data, context) => {
  const { orderId, status } = data;

  await admin.firestore().collection('orders').doc(orderId).update({
    status,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send notification to user
  const orderDoc = await admin.firestore().collection('orders').doc(orderId).get();
  const userId = orderDoc.data().userId;

  await admin.firestore().collection('notifications').doc(userId).collection('notifications').add({
    title: 'Order Update',
    body: `Your order status has been updated to ${status}`,
    type: 'orderUpdate',
    data: { orderId },
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});