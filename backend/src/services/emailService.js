const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587,
  secure: false, // Use STARTTLS
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_APP_PASSWORD,
  },
  tls: {
    rejectUnauthorized: false, // Bypass self-signed cert (network proxy)
  },
});

/**
 * Send a warning email to a user who has been reported.
 * @param {string} toEmail - Recipient email address
 * @param {string} userName - Display name of the reported user
 * @param {string} reason - The report reason / category
 * @param {string} details - Additional details from the report
 */
const sendWarningEmail = async (toEmail, userName, reason, details = '') => {
  const mailOptions = {
    from: `"Zeylo Platform" <${process.env.EMAIL_USER}>`,
    to: toEmail,
    subject: '⚠️ Zeylo Platform — Community Guidelines Warning',
    html: `
      <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #1a1a2e; color: #e0e0e0; border-radius: 12px; overflow: hidden;">
        <div style="background: linear-gradient(135deg, #6c3ce0, #4a1fa0); padding: 32px; text-align: center;">
          <h1 style="color: #ffffff; margin: 0; font-size: 24px;">⚠️ Community Guidelines Warning</h1>
        </div>
        <div style="padding: 32px;">
          <p style="font-size: 16px; line-height: 1.6;">
            Dear <strong>${userName || 'User'}</strong>,
          </p>
          <p style="font-size: 15px; line-height: 1.6;">
            We have received a report regarding your recent conduct on the Zeylo platform.
          </p>
          <div style="background: #2a2a4a; border-left: 4px solid #ff6b6b; padding: 16px; border-radius: 8px; margin: 20px 0;">
            <p style="margin: 0 0 8px 0; font-weight: 600; color: #ff6b6b;">Report Category:</p>
            <p style="margin: 0; color: #e0e0e0;">${reason}</p>
            ${details ? `
              <p style="margin: 12px 0 8px 0; font-weight: 600; color: #ff6b6b;">Details:</p>
              <p style="margin: 0; color: #e0e0e0;">${details}</p>
            ` : ''}
          </div>
          <p style="font-size: 15px; line-height: 1.6;">
            Please review our <strong>Community Guidelines</strong> to ensure compliance. Further violations may result in temporary or permanent suspension of your account.
          </p>
          <p style="font-size: 15px; line-height: 1.6;">
            If you believe this warning was issued in error, please contact our support team.
          </p>
          <hr style="border: none; border-top: 1px solid #3a3a5a; margin: 24px 0;" />
          <p style="font-size: 13px; color: #888; text-align: center;">
            This is an automated message from the Zeylo Platform. Please do not reply directly to this email.
          </p>
        </div>
      </div>
    `,
  };

  const info = await transporter.sendMail(mailOptions);
  console.log('Warning email sent:', info.messageId);
  return info;
};

module.exports = { sendWarningEmail };
