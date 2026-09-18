import 'package:bluerum/core/constants/api_constants.dart';
import 'package:bluerum/features/auth/domain/stored_account.dart';

final class AuthState {
  const AuthState({
    required this.initialized,
    required this.instanceUrl,
    this.jwt,
    this.username,
    this.personId,
    this.unreadReplies = 0,
    this.unreadMentions = 0,
    this.unreadPrivateMessages = 0,
    this.accounts = const [],
    this.activeAccountId,
  });

  const AuthState.loading()
    : initialized = false,
      instanceUrl = ApiConstants.defaultInstance,
      jwt = null,
      username = null,
      personId = null,
      unreadReplies = 0,
      unreadMentions = 0,
      unreadPrivateMessages = 0,
      accounts = const [],
      activeAccountId = null;

  final bool initialized;
  final String instanceUrl;
  final String? jwt;
  final String? username;
  final int? personId;
  final int unreadReplies;
  final int unreadMentions;
  final int unreadPrivateMessages;
  final List<StoredAccount> accounts;
  final String? activeAccountId;

  bool get isLoggedIn => jwt != null && jwt!.isNotEmpty;
  int get totalUnreadNotifications => unreadReplies + unreadMentions;
  int get totalUnreadAll => totalUnreadNotifications + unreadPrivateMessages;

  bool isMe({int? personId, String? username}) {
    if (!isLoggedIn) return false;
    if (personId != null && this.personId != null && personId == this.personId) {
      return true;
    }
    if (username != null &&
        this.username != null &&
        username.toLowerCase() == this.username!.toLowerCase()) {
      return true;
    }
    return false;
  }
}
