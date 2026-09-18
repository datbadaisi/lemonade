/// A persisted Lemmy session that can be switched to without re-entering
/// credentials.
final class StoredAccount {
  const StoredAccount({
    required this.id,
    required this.jwt,
    required this.instanceUrl,
    required this.username,
    this.personId,
    this.avatarUrl,
  });

  /// Stable key: `username@instanceHost` (lowercase username).
  final String id;
  final String jwt;
  final String instanceUrl;
  final String username;
  final int? personId;
  final String? avatarUrl;

  /// Host portion of [instanceUrl], for display (e.g. `lemmy.world`).
  String get instanceHost {
    try {
      final host = Uri.parse(instanceUrl).host;
      if (host.isNotEmpty) return host;
    } catch (_) {}
    return instanceUrl
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'/$'), '');
  }

  /// Human-readable handle: `user@lemmy.world`.
  String get handle => '$username@$instanceHost';

  static String makeId({
    required String username,
    required String instanceUrl,
  }) {
    final host = () {
      try {
        final h = Uri.parse(instanceUrl).host;
        if (h.isNotEmpty) return h.toLowerCase();
      } catch (_) {}
      return instanceUrl
          .replaceFirst(RegExp(r'^https?://'), '')
          .replaceFirst(RegExp(r'/$'), '')
          .toLowerCase();
    }();
    return '${username.toLowerCase()}@$host';
  }

  StoredAccount copyWith({
    String? id,
    String? jwt,
    String? instanceUrl,
    String? username,
    int? personId,
    String? avatarUrl,
    bool clearPersonId = false,
    bool clearAvatarUrl = false,
  }) {
    return StoredAccount(
      id: id ?? this.id,
      jwt: jwt ?? this.jwt,
      instanceUrl: instanceUrl ?? this.instanceUrl,
      username: username ?? this.username,
      personId: clearPersonId ? null : (personId ?? this.personId),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jwt': jwt,
        'instanceUrl': instanceUrl,
        'username': username,
        if (personId != null) 'personId': personId,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };

  factory StoredAccount.fromJson(Map<String, dynamic> json) {
    final instanceUrl = json['instanceUrl'] as String? ?? '';
    final username = json['username'] as String? ?? '';
    final id = json['id'] as String? ??
        makeId(username: username, instanceUrl: instanceUrl);
    final rawPersonId = json['personId'];
    int? personId;
    if (rawPersonId is int) {
      personId = rawPersonId;
    } else if (rawPersonId is String) {
      personId = int.tryParse(rawPersonId);
    }
    return StoredAccount(
      id: id,
      jwt: json['jwt'] as String? ?? '',
      instanceUrl: instanceUrl,
      username: username,
      personId: personId,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
