class AppSettings {
  final String? linkedinAuthToken;
  final String? linkedinRefreshToken;
  final String? linkedinClientId;
  final String? linkedinClientSecret;
  final String? xAuthToken;
  final String? xRefreshToken;
  final String? xClientId;
  final String? xClientSecret;
  final String? geminiToken;
  final int publishPerWeek;
  final String? genModel;
  final String? embedModel;
  final String themeMode;
  final bool copyToLinkedin;
  final bool copyToX;

  const AppSettings({
    this.linkedinAuthToken,
    this.linkedinRefreshToken,
    this.linkedinClientId,
    this.linkedinClientSecret,
    this.xAuthToken,
    this.xRefreshToken,
    this.xClientId,
    this.xClientSecret,
    this.geminiToken,
    this.publishPerWeek = 3,
    this.genModel,
    this.embedModel,
    this.themeMode = 'system',
    this.copyToLinkedin = false,
    this.copyToX = false,
  });

  bool get isLinkedInConnected => linkedinAuthToken != null && linkedinAuthToken!.isNotEmpty;
  bool get isXConnected => xAuthToken != null && xAuthToken!.isNotEmpty;
  bool get hasGeminiToken => geminiToken != null && geminiToken!.isNotEmpty;
  bool get hasLinkedInCredentials =>
      linkedinClientId != null && linkedinClientId!.isNotEmpty &&
      linkedinClientSecret != null && linkedinClientSecret!.isNotEmpty;
  bool get hasXCredentials =>
      xClientId != null && xClientId!.isNotEmpty;

  String get effectiveGenModel => (genModel != null && genModel!.isNotEmpty) ? genModel! : 'gemini-2.0-flash';
  String get effectiveEmbedModel => (embedModel != null && embedModel!.isNotEmpty) ? embedModel! : 'text-embedding-004';

  AppSettings copyWith({
    String? linkedinAuthToken,
    String? linkedinRefreshToken,
    String? linkedinClientId,
    String? linkedinClientSecret,
    String? xAuthToken,
    String? xRefreshToken,
    String? xClientId,
    String? xClientSecret,
    String? geminiToken,
    int? publishPerWeek,
    String? genModel,
    String? embedModel,
    String? themeMode,
    bool? copyToLinkedin,
    bool? copyToX,
    bool clearLinkedin = false,
    bool clearX = false,
  }) {
    return AppSettings(
      linkedinAuthToken: clearLinkedin ? null : linkedinAuthToken ?? this.linkedinAuthToken,
      linkedinRefreshToken: clearLinkedin ? null : linkedinRefreshToken ?? this.linkedinRefreshToken,
      linkedinClientId: linkedinClientId ?? this.linkedinClientId,
      linkedinClientSecret: linkedinClientSecret ?? this.linkedinClientSecret,
      xAuthToken: clearX ? null : xAuthToken ?? this.xAuthToken,
      xRefreshToken: clearX ? null : xRefreshToken ?? this.xRefreshToken,
      xClientId: xClientId ?? this.xClientId,
      xClientSecret: xClientSecret ?? this.xClientSecret,
      geminiToken: geminiToken ?? this.geminiToken,
      publishPerWeek: publishPerWeek ?? this.publishPerWeek,
      genModel: genModel ?? this.genModel,
      embedModel: embedModel ?? this.embedModel,
      themeMode: themeMode ?? this.themeMode,
      copyToLinkedin: copyToLinkedin ?? this.copyToLinkedin,
      copyToX: copyToX ?? this.copyToX,
    );
  }
}
