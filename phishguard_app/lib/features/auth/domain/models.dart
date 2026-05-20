class UserModel {
  final int userId;
  final String username;
  final String email;
  final String accessToken;
  final String refreshToken;
  final int totalScans;
  final int blockedThreats;
  final String preferredLanguage;

  const UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.totalScans,
    required this.blockedThreats,
    required this.preferredLanguage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      totalScans: (json['totalScans'] as num?)?.toInt() ?? 0,
      blockedThreats: (json['blockedThreats'] as num?)?.toInt() ?? 0,
      preferredLanguage: json['preferredLanguage']?.toString() ?? 'en',
    );
  }
}

class ScanResultModel {
  final int? historyId;
  final String scanType;
  final String scannedContent;
  final String resultStatus;
  final int riskScore;
  final String? domainName;
  final bool sslStatus;
  final int redirectCount;
  final int domainAgeDays;
  final bool blacklisted;
  final bool trusted;
  final List<String> aiReasons;
  final DateTime? scannedAt;

  const ScanResultModel({
    this.historyId,
    required this.scanType,
    required this.scannedContent,
    required this.resultStatus,
    required this.riskScore,
    this.domainName,
    required this.sslStatus,
    required this.redirectCount,
    required this.domainAgeDays,
    required this.blacklisted,
    required this.trusted,
    required this.aiReasons,
    this.scannedAt,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      historyId: json['historyId'] as int?,
      scanType: json['scanType'] as String? ?? 'URL',
      scannedContent: json['scannedContent'] as String? ?? '',
      resultStatus: json['resultStatus'] as String? ?? 'SAFE',
      riskScore: json['riskScore'] as int? ?? 0,
      domainName: json['domainName'] as String?,
      sslStatus: json['sslStatus'] as bool? ?? false,
      redirectCount: json['redirectCount'] as int? ?? 0,
      domainAgeDays: json['domainAgeDays'] as int? ?? -1,
      blacklisted: json['blacklisted'] as bool? ?? false,
      trusted: json['trusted'] as bool? ?? false,
      aiReasons: (json['aiReasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      scannedAt: json['scannedAt'] != null
          ? DateTime.tryParse(json['scannedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'historyId': historyId,
    'scanType': scanType,
    'scannedContent': scannedContent,
    'resultStatus': resultStatus,
    'riskScore': riskScore,
    'domainName': domainName,
    'sslStatus': sslStatus,
    'redirectCount': redirectCount,
    'domainAgeDays': domainAgeDays,
    'blacklisted': blacklisted,
    'trusted': trusted,
    'aiReasons': aiReasons,
    'scannedAt': scannedAt?.toIso8601String(),
  };
}
