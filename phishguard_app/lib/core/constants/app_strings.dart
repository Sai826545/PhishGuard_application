class AppStrings {
  AppStrings._();

  static const String appName = 'PhishGuard';
  static const String tagline = 'Protecting You From Scams';
  static const String version = '1.0.0';

  // Onboarding
  static const String onboard1Title = 'Detect Phishing Links';
  static const String onboard1Desc =
      'Instantly scan suspicious URLs, emails, and SMS messages before you click. Our AI engine analyzes threats in real-time.';
  static const String onboard2Title = 'QR Code Scam Protection';
  static const String onboard2Desc =
      'Protect yourself from fake UPI QR codes, payment scams, and malicious redirects hidden inside innocent-looking QR codes.';
  static const String onboard3Title = 'India-Specific Fraud Guard';
  static const String onboard3Desc =
      'Specialized protection against SBI/HDFC/ICICI fake portals, Aadhaar KYC scams, courier fraud, and government portal impersonation.';

  // Auth
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String username = 'Username';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String createAccount = 'Create Account';
  static const String signIn = 'Sign In';

  // Navigation
  static const String home = 'Home';
  static const String scan = 'Scan';
  static const String history = 'History';
  static const String alerts = 'Alerts';
  static const String settings = 'Settings';

  // Home
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String securityScore = 'Security Score';
  static const String totalScans = 'Total Scans';
  static const String threatsBlocked = 'Threats Blocked';
  static const String quickActions = 'Quick Actions';
  static const String latestAlerts = 'Latest Alerts';
  static const String cyberTip = '💡 Security Tip';

  // Scanners
  static const String urlScanner = 'URL Scanner';
  static const String qrScanner = 'QR Scanner';
  static const String smsScanner = 'SMS Scanner';
  static const String emailScanner = 'Email Scanner';
  static const String pasteLink = 'Paste suspicious link here...';
  static const String scanNow = 'Scan Now';
  static const String clearText = 'Clear';
  static const String pasteButton = 'Paste';
  static const String recentLinks = 'Recent Scans';

  // Results
  static const String scanResult = 'Scan Result';
  static const String riskScore = 'Risk Score';
  static const String domainInfo = 'Domain Information';
  static const String aiReasons = 'Why This Result?';
  static const String sslStatus = 'SSL Certificate';
  static const String domainAge = 'Domain Age';
  static const String redirectCount = 'Redirects';
  static const String blacklistStatus = 'Blacklist Status';

  // Status Labels
  static const String safe = 'SAFE';
  static const String suspicious = 'SUSPICIOUS';
  static const String dangerous = 'DANGEROUS';

  // Report
  static const String reportScam = 'Report Scam';
  static const String reportCategory = 'Scam Category';
  static const String reportDescription = 'Describe the scam...';
  static const String submitReport = 'Submit Report';

  // Profile
  static const String profile = 'Profile';
  static const String achievements = 'Achievements';
  static const String joinedOn = 'Joined';

  // Settings
  static const String darkMode = 'Dark Mode';
  static const String biometricLogin = 'Biometric Login';
  static const String notifications = 'Notifications';
  static const String language = 'Language';
  static const String clearHistory = 'Clear Scan History';
  static const String logout = 'Logout';
  static const String privacyPolicy = 'Privacy Policy';
  static const String helpAbout = 'Help & About';

  // Errors
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Something went wrong. Please try again.';
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String weakPassword = 'Password must be at least 6 characters';

  // API
  static const String baseUrl = 'http://192.168.1.5:8081/api';
}

class AppSizes {
  AppSizes._();

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusFull = 999.0;

  // Icon sizes
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // Font sizes
  static const double textXS = 10.0;
  static const double textSM = 12.0;
  static const double textMD = 14.0;
  static const double textLG = 16.0;
  static const double textXL = 18.0;
  static const double textXXL = 22.0;
  static const double textDisplay = 28.0;
  static const double textHero = 36.0;

  // Component
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  static const double cardElevation = 0.0;
  static const double bottomNavHeight = 72.0;
  static const double appBarHeight = 64.0;
}
