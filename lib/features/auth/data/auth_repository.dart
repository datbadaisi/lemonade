import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:bluerum/core/constants/api_constants.dart';
import 'package:bluerum/core/constants/storage_keys.dart';
import 'package:bluerum/core/storage/key_value_store.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/features/auth/domain/stored_account.dart';

/// Manages authentication state: JWT token, current instance, user info, and
/// multiple saved sessions. Persists to SharedPreferences so the user stays
/// logged in across restarts and can switch accounts without re-entering
/// credentials.
class AuthService extends ChangeNotifier {
  AuthService({required KeyValueStore store}) : _store = store;

  final KeyValueStore _store;

  String? _jwt;
  String? _instanceUrl;
  String? _username;
  int? _personId;
  String? _avatarUrl;
  bool _initialized = false;

  final List<StoredAccount> _accounts = [];
  String? _activeAccountId;

  int _unreadReplies = 0;
  int _unreadMentions = 0;
  int _unreadPrivateMessages = 0;

  String? get jwt => _jwt;
  String? get instanceUrl => _instanceUrl;

  /// Last-used instance for guests and logged-in users (never force-default
  /// on logout — only fall back when nothing is stored).
  String get activeInstanceUrl =>
      _instanceUrl ?? ApiConstants.defaultInstance;

  String? get username => _username;
  int? get personId => _personId;
  String? get avatarUrl => _avatarUrl;
  bool get isLoggedIn => _jwt != null && _jwt!.isNotEmpty;
  bool get initialized => _initialized;

  /// Saved sessions (including the active one when logged in).
  List<StoredAccount> get accounts => List.unmodifiable(_accounts);

  String? get activeAccountId => _activeAccountId;

  int get unreadReplies => _unreadReplies;
  int get unreadMentions => _unreadMentions;
  int get unreadPrivateMessages => _unreadPrivateMessages;
  int get totalUnreadNotifications => _unreadReplies + _unreadMentions;
  int get totalUnreadAll =>
      _unreadReplies + _unreadMentions + _unreadPrivateMessages;

  /// True if [personId] or [username] matches the signed-in account.
  bool isMe({int? personId, String? username}) {
    if (!isLoggedIn) return false;
    if (personId != null && _personId != null && personId == _personId) {
      return true;
    }
    if (username != null &&
        _username != null &&
        username.toLowerCase() == _username!.toLowerCase()) {
      return true;
    }
    return false;
  }

  /// Update unread count manually or from an external response.
  void setUnreadCounts({
    required int replies,
    required int mentions,
    required int privateMessages,
  }) {
    _unreadReplies = replies;
    _unreadMentions = mentions;
    _unreadPrivateMessages = privateMessages;
    notifyListeners();
  }

  /// Fetch unread counts from server.
  Future<void> fetchUnreadCounts(LemmyApiService api) async {
    if (!isLoggedIn) return;
    try {
      final unread = await api.getUnreadCount();
      _unreadReplies = unread.replies;
      _unreadMentions = unread.mentions;
      _unreadPrivateMessages = unread.privateMessages;
      notifyListeners();
    } catch (_) {}
  }

  /// Decrement replies unread count.
  void decrementReplies([int count = 1]) {
    _unreadReplies = (_unreadReplies - count).clamp(0, 9999);
    notifyListeners();
  }

  /// Decrement mentions unread count.
  void decrementMentions([int count = 1]) {
    _unreadMentions = (_unreadMentions - count).clamp(0, 9999);
    notifyListeners();
  }

  /// Decrement private messages unread count.
  void decrementPrivateMessages([int count = 1]) {
    _unreadPrivateMessages = (_unreadPrivateMessages - count).clamp(0, 9999);
    notifyListeners();
  }

  /// Clear all notifications unread count.
  void clearAllNotifications() {
    _unreadReplies = 0;
    _unreadMentions = 0;
    _unreadPrivateMessages = 0;
    notifyListeners();
  }

  /// Load persisted auth state from disk. Call once at app startup.
  Future<void> init() async {
    await _loadAccounts();
    await _migrateLegacySessionIfNeeded();

    final activeId = _store.getString(StorageKeys.activeAccountId);
    StoredAccount? active;
    if (activeId != null) {
      active = _findAccount(activeId);
    }
    active ??= _accounts.isNotEmpty ? _accounts.first : null;

    if (active != null) {
      _applyAccount(active);
      _activeAccountId = active.id;
    } else {
      // Guest: keep last instance if any.
      _instanceUrl = _store.getString(StorageKeys.instance);
      _jwt = null;
      _username = null;
      _personId = null;
      _avatarUrl = null;
      _activeAccountId = null;
    }

    _initialized = true;
    notifyListeners();
  }

  /// Log in: call the API, store the JWT, resolve identity, upsert into the
  /// multi-account list, and set as active. Existing accounts are preserved.
  ///
  /// When [instanceUrl] is provided, the shared API client is pointed at that
  /// host for the attempt only. On failure, a previous session is restored so
  /// adding another account cannot corrupt the active account's instance.
  Future<LoginResponse> login({
    required LemmyApiService api,
    required String usernameOrEmail,
    required String password,
    String? totpToken,
    String? instanceUrl,
  }) async {
    // Persist the current session before credentials change so it stays in the
    // account list when the user is adding another account.
    await _syncActiveIntoAccounts();

    final previous = isLoggedIn && _activeAccountId != null
        ? _findAccount(_activeAccountId!)
        : null;

    final targetInstance = instanceUrl ?? activeInstanceUrl;
    api.setBaseUrl(targetInstance);

    try {
      final response = await api.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
        totpToken: totpToken,
      );

      if (response.jwt != null && response.jwt!.isNotEmpty) {
        _instanceUrl = targetInstance;
        _jwt = response.jwt;
        // Temporary until site.my_user resolves the canonical Lemmy name/id.
        _username = usernameOrEmail;
        _personId = null;
        _avatarUrl = null;
        api.setAuthToken(_jwt!);
        await _resolveIdentity(api);
        await _upsertActiveAndPersist();
      }
      notifyListeners();
      return response;
    } catch (e) {
      // Restore previous session if login failed mid-flight (e.g. after the
      // client was pointed at another host for an add-account attempt).
      if (previous != null) {
        _applyAccount(previous);
        _activeAccountId = previous.id;
        api.setBaseUrl(previous.instanceUrl);
        api.setAuthToken(previous.jwt);
        await _persistActiveSessionKeys();
        notifyListeners();
      } else if (instanceUrl != null) {
        // Guest: remember the instance they tried so the form stays useful.
        _instanceUrl = instanceUrl;
        await _store.setString(StorageKeys.instance, instanceUrl);
        notifyListeners();
      }
      rethrow;
    }
  }

  /// Switch the active session to a saved account. No-op if already active or
  /// the account is unknown.
  Future<void> switchAccount(
    String accountId, {
    LemmyApiService? api,
  }) async {
    if (accountId == _activeAccountId) return;
    final account = _findAccount(accountId);
    if (account == null) return;

    await _syncActiveIntoAccounts();

    _applyAccount(account);
    _activeAccountId = account.id;
    _clearUnread();
    api?.setBaseUrl(account.instanceUrl);
    api?.setAuthToken(account.jwt);

    await _store.setString(StorageKeys.activeAccountId, account.id);
    await _persistActiveSessionKeys();
    notifyListeners();
  }

  /// Log out the active account only. If other accounts remain, switch to the
  /// first remaining session; otherwise clear auth entirely.
  Future<void> logout({LemmyApiService? api}) async {
    final leavingId = _activeAccountId;
    if (leavingId != null) {
      _accounts.removeWhere((a) => a.id == leavingId);
    } else if (isLoggedIn && _username != null) {
      final id = StoredAccount.makeId(
        username: _username!,
        instanceUrl: activeInstanceUrl,
      );
      _accounts.removeWhere((a) => a.id == id);
    }

    if (_accounts.isNotEmpty) {
      final next = _accounts.first;
      _applyAccount(next);
      _activeAccountId = next.id;
      _clearUnread();
      api?.setBaseUrl(next.instanceUrl);
      api?.setAuthToken(next.jwt);
      await _store.setString(StorageKeys.activeAccountId, next.id);
      await _persistAccounts();
      await _persistActiveSessionKeys();
      notifyListeners();
      return;
    }

    _jwt = null;
    _username = null;
    _personId = null;
    _avatarUrl = null;
    _activeAccountId = null;
    _clearUnread();
    api?.setAuthToken(null);
    await _store.remove(StorageKeys.jwt);
    await _store.remove(StorageKeys.username);
    await _store.remove(StorageKeys.personId);
    await _store.remove(StorageKeys.activeAccountId);
    await _persistAccounts();
    // Keep last instance URL for the login form.
    notifyListeners();
  }

  /// Update the stored instance URL (guest or active session).
  Future<void> setInstance(String url) async {
    _instanceUrl = url;
    await _store.setString(StorageKeys.instance, url);
    // If logged in, keep the active account entry in sync.
    if (isLoggedIn && _activeAccountId != null) {
      final idx = _accounts.indexWhere((a) => a.id == _activeAccountId);
      if (idx >= 0) {
        final old = _accounts[idx];
        final updated = old.copyWith(instanceUrl: url);
        // Id is host-scoped; rebuild if host changed after a successful login
        // identity resolve — for setInstance alone, keep old id until login.
        _accounts[idx] = updated;
        await _persistAccounts();
      }
    }
    notifyListeners();
  }

  /// Set JWT after registration (when no login call was made).
  Future<void> setJwt(String token, {LemmyApiService? api}) async {
    await _syncActiveIntoAccounts();
    _jwt = token;
    api?.setAuthToken(token);
    if (api != null) {
      await _resolveIdentity(api);
    }
    await _upsertActiveAndPersist();
    notifyListeners();
  }

  /// Resolve canonical Lemmy person name + id via GET /site (my_user).
  Future<void> _resolveIdentity(LemmyApiService api) async {
    try {
      final site = await api.getSite();
      final person = site.myUser?.localUserView.person;
      if (person != null) {
        if (person.name.isNotEmpty) _username = person.name;
        if (person.id != 0) _personId = person.id;
        _avatarUrl = person.avatar;
      }
    } catch (_) {
      // Keep login input as username fallback.
    }
  }

  /// Refresh identity when already logged in (e.g. app resume).
  Future<void> refreshIdentity(LemmyApiService api) async {
    if (!isLoggedIn) return;
    await _resolveIdentity(api);
    await _upsertActiveAndPersist();
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  void _applyAccount(StoredAccount account) {
    _jwt = account.jwt;
    _instanceUrl = account.instanceUrl;
    _username = account.username;
    _personId = account.personId;
    _avatarUrl = account.avatarUrl;
  }

  void _clearUnread() {
    _unreadReplies = 0;
    _unreadMentions = 0;
    _unreadPrivateMessages = 0;
  }

  StoredAccount? _findAccount(String id) {
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  StoredAccount? _buildActiveAccount() {
    if (!isLoggedIn || _jwt == null || _username == null) return null;
    final id = StoredAccount.makeId(
      username: _username!,
      instanceUrl: activeInstanceUrl,
    );
    return StoredAccount(
      id: id,
      jwt: _jwt!,
      instanceUrl: activeInstanceUrl,
      username: _username!,
      personId: _personId,
      avatarUrl: _avatarUrl,
    );
  }

  /// Write the in-memory active session into [_accounts] (upsert by id).
  Future<void> _syncActiveIntoAccounts() async {
    final account = _buildActiveAccount();
    if (account == null) return;
    _upsertAccount(account);
    _activeAccountId = account.id;
    await _persistAccounts();
    await _store.setString(StorageKeys.activeAccountId, account.id);
  }

  Future<void> _upsertActiveAndPersist() async {
    final account = _buildActiveAccount();
    if (account == null) return;
    _upsertAccount(account);
    _activeAccountId = account.id;
    await _persistAccounts();
    await _store.setString(StorageKeys.activeAccountId, account.id);
    await _persistActiveSessionKeys();
  }

  void _upsertAccount(StoredAccount account) {
    final idx = _accounts.indexWhere((a) => a.id == account.id);
    if (idx >= 0) {
      _accounts[idx] = account;
    } else {
      // Also replace entries that share the same personId+instance (e.g. login
      // with email first, then resolve to username — old id may differ).
      if (account.personId != null) {
        _accounts.removeWhere(
          (a) =>
              a.personId == account.personId &&
              a.instanceHost == account.instanceHost &&
              a.id != account.id,
        );
      }
      _accounts.add(account);
    }
  }

  Future<void> _loadAccounts() async {
    _accounts.clear();
    final raw = _store.getString(StorageKeys.accounts);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final account = StoredAccount.fromJson(item);
          if (account.jwt.isNotEmpty && account.username.isNotEmpty) {
            _accounts.add(account);
          }
        } else if (item is Map) {
          final account = StoredAccount.fromJson(
            Map<String, dynamic>.from(item),
          );
          if (account.jwt.isNotEmpty && account.username.isNotEmpty) {
            _accounts.add(account);
          }
        }
      }
    } catch (_) {
      // Corrupt list — start fresh; legacy migration may still recover.
    }
  }

  /// One-time migration from single-session keys into the multi-account list.
  Future<void> _migrateLegacySessionIfNeeded() async {
    if (_accounts.isNotEmpty) return;
    final jwt = _store.getString(StorageKeys.jwt);
    final username = _store.getString(StorageKeys.username);
    final instance = _store.getString(StorageKeys.instance);
    if (jwt == null ||
        jwt.isEmpty ||
        username == null ||
        username.isEmpty ||
        instance == null ||
        instance.isEmpty) {
      return;
    }
    final rawId = _store.getString(StorageKeys.personId);
    final personId = rawId == null ? null : int.tryParse(rawId);
    final account = StoredAccount(
      id: StoredAccount.makeId(username: username, instanceUrl: instance),
      jwt: jwt,
      instanceUrl: instance,
      username: username,
      personId: personId,
    );
    _accounts.add(account);
    await _persistAccounts();
    await _store.setString(StorageKeys.activeAccountId, account.id);
  }

  Future<void> _persistAccounts() async {
    final encoded = jsonEncode(_accounts.map((a) => a.toJson()).toList());
    await _store.setString(StorageKeys.accounts, encoded);
  }

  Future<void> _persistActiveSessionKeys() async {
    if (_jwt != null) {
      await _store.setString(StorageKeys.jwt, _jwt!);
    } else {
      await _store.remove(StorageKeys.jwt);
    }
    if (_instanceUrl != null) {
      await _store.setString(StorageKeys.instance, _instanceUrl!);
    }
    if (_username != null) {
      await _store.setString(StorageKeys.username, _username!);
    } else {
      await _store.remove(StorageKeys.username);
    }
    if (_personId != null) {
      await _store.setString(StorageKeys.personId, '$_personId');
    } else {
      await _store.remove(StorageKeys.personId);
    }
  }
}
