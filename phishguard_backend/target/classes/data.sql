-- ===================================================
-- PhishGuard Seed Data
-- Blacklisted Domains (India-focused phishing domains)
-- ===================================================

INSERT IGNORE INTO blacklisted_domains (domain, category) VALUES
-- Fake SBI Domains
('sbi-secure-login.com', 'BANK'),
('sbionline-kyc.com', 'BANK'),
('sbi-alert-kyc.in', 'BANK'),
('sbinetbanking-update.com', 'BANK'),
('sbi-rewardpoint.com', 'BANK'),
('onlinesbi-netbanking.com', 'BANK'),
('sbi-yono-kyc.com', 'BANK'),
('sbiyono-rewardpoints.com', 'BANK'),
('sbicardkyc.com', 'BANK'),
('sbi-bank-update.in', 'BANK'),

-- Fake HDFC Domains
('hdfc-netbanking-secure.com', 'BANK'),
('hdfcbank-kyc-update.in', 'BANK'),
('hdfc-rewardpoints.in', 'BANK'),
('hdfcbankindia-update.com', 'BANK'),
('hdfc-account-verify.com', 'BANK'),

-- Fake ICICI Domains
('icici-bank-kyc.in', 'BANK'),
('icicibanklogin-secure.com', 'BANK'),
('icici-alertkyc.com', 'BANK'),
('icicibank-rewardpoints.in', 'BANK'),

-- Fake Axis Domains
('axisbank-kyc-update.in', 'BANK'),
('axis-bank-secure-login.com', 'BANK'),

-- Fake Kotak Domains
('kotak-kyc-update.in', 'BANK'),
('kotakbank-reward.com', 'BANK'),

-- UPI Scam Domains
('upi-refund-claim.com', 'UPI'),
('upi-cashback-offer.in', 'UPI'),
('bhim-upi-reward.com', 'UPI'),
('paytm-reward-cashback.in', 'UPI'),
('phonepe-cashback-now.com', 'UPI'),
('googlepay-claim-reward.com', 'UPI'),
('upi-prize-winner.in', 'UPI'),

-- Fake Government Portals
('aadhaar-update-online.in', 'GOVT'),
('uidai-aadhaar-kyc.com', 'GOVT'),
('incometax-refund-claim.in', 'GOVT'),
('pan-card-apply-online.in', 'GOVT'),
('passportindia-renewal.in', 'GOVT'),
('pm-kisan-subsidy-claim.in', 'GOVT'),
('aadhaar-link-bank.com', 'GOVT'),
('epfindia-kyc-update.in', 'GOVT'),

-- Fake Courier Domains
('delhivery-parcel-pending.com', 'COURIER'),
('indiapost-track-parcel.in', 'COURIER'),
('bluedart-delivery-alert.com', 'COURIER'),
('dtdc-shipment-update.in', 'COURIER'),
('fedex-delivery-failed.in', 'COURIER'),
('delhivery-customs-fee.com', 'COURIER'),
('courier-delivery-charge.in', 'COURIER'),

-- Generic Phishing
('verify-account-now.com', 'PHISHING'),
('account-suspended-verify.in', 'PHISHING'),
('secure-login-verify.com', 'PHISHING'),
('urgent-account-update.in', 'PHISHING'),
('prize-winner-claim.com', 'PHISHING'),
('free-recharge-offer.in', 'PHISHING'),
('update-kyc-immediately.com', 'PHISHING'),
('otp-verify-account.in', 'PHISHING');

-- ===================================================
-- Trusted Domains (Whitelist)
-- ===================================================

INSERT IGNORE INTO trusted_domains (domain, brand_name) VALUES
('sbi.co.in', 'State Bank of India'),
('onlinesbi.sbi', 'SBI Online Banking'),
('hdfcbank.com', 'HDFC Bank'),
('icicibank.com', 'ICICI Bank'),
('axisbank.com', 'Axis Bank'),
('kotak.com', 'Kotak Mahindra Bank'),
('pnbindia.in', 'Punjab National Bank'),
('bankofbaroda.in', 'Bank of Baroda'),
('uidai.gov.in', 'UIDAI Aadhaar'),
('incometax.gov.in', 'Income Tax India'),
('tin-nsdl.com', 'NSDL PAN Services'),
('passportindia.gov.in', 'Passport Seva'),
('epfindia.gov.in', 'EPFO'),
('india.gov.in', 'Government of India'),
('paytm.com', 'Paytm'),
('phonepe.com', 'PhonePe'),
('googlepay.com', 'Google Pay'),
('delhivery.com', 'Delhivery'),
('bluedart.com', 'Blue Dart'),
('indiapost.gov.in', 'India Post'),
('amazon.in', 'Amazon India'),
('flipkart.com', 'Flipkart'),
('irctc.co.in', 'IRCTC'),
('myntra.com', 'Myntra'),
('razorpay.com', 'Razorpay'),
('cashfree.com', 'Cashfree');

-- ===================================================
-- Alerts (Threat Feed Seed Data)
-- ===================================================

INSERT IGNORE INTO alerts (title, description, severity, category, is_active) VALUES
('⚠️ Fake SBI KYC Update Campaign Active', 'Cybercriminals are sending SMS messages impersonating SBI asking users to update KYC via a fake link. Do NOT click any link from unverified SMS. Always visit sbi.co.in directly.', 'CRITICAL', 'BANK_SCAM', true),
('🔴 Aadhaar Refund Scam Spreading on WhatsApp', 'A viral WhatsApp message claims the government is offering ₹2,500 Aadhaar refund. The link leads to a phishing site collecting OTPs. UIDAI does NOT offer such refunds.', 'CRITICAL', 'GOVT_SCAM', true),
('⚠️ Fake Delhivery Parcel Scam', 'Fraudsters are sending fake delivery failure SMS messages from fake Delhivery numbers, asking users to pay a ₹25 customs fee via UPI to receive a parcel. This is a scam.', 'HIGH', 'COURIER_SCAM', true),
('🟡 Fake HDFC Reward Points Expiry Alert', 'Phishing emails claiming HDFC reward points will expire are circulating. They redirect to a cloned HDFC site to steal credentials. HDFC never sends reward alerts via unofficial channels.', 'HIGH', 'BANK_SCAM', true),
('🔴 UPI QR Code Scam on OLX/Facebook Marketplace', 'Scammers posing as army personnel or buyers are sending "payment QR codes" on OLX. Scanning these QR codes deducts money from victims. Never scan QR codes from unknown sellers.', 'CRITICAL', 'UPI_SCAM', true),
('🟡 PAN Card Reactivation Phishing Email', 'Fake emails impersonating Income Tax Department claim your PAN card is deactivated. The link leads to a form stealing Aadhaar + PAN + bank details.', 'HIGH', 'GOVT_SCAM', true),
('🟢 Google Pay Fake Cashback Offer', 'WhatsApp messages offering GPay cashback by clicking a link are circulating. These links ask for UPI PIN. Google Pay never asks for UPI PIN via links.', 'MEDIUM', 'UPI_SCAM', true),
('⚠️ New Typosquatted ICICI Domains Detected', 'Security researchers detected 12 new domains mimicking ICICI Bank (e.g., iciici-bank.com, icici-banking.in). PhishGuard has added these to the blacklist.', 'HIGH', 'BANK_SCAM', true),
('🟡 PM Kisan Subsidy Scam via SMS', 'Fake SMS messages claim PM Kisan Samman Nidhi payment is pending and ask users to update bank details on a fraudulent portal. Do NOT share bank details via any SMS link.', 'MEDIUM', 'GOVT_SCAM', true),
('🔴 OTP Scam Targeting Senior Citizens', 'A new social engineering scam is targeting senior citizens by impersonating bank employees and asking for OTPs to "reverse a failed transaction". Never share OTP with anyone.', 'CRITICAL', 'BANK_SCAM', true);
