abstract final class StorageKeys {
  static const jwt = 'lemmy_jwt';
  static const instance = 'lemmy_instance';
  static const username = 'lemmy_username';
  static const personId = 'lemmy_person_id';

  /// JSON array of [StoredAccount] sessions for multi-account switching.
  static const accounts = 'lemmy_accounts';

  /// Id of the currently active account within [accounts].
  static const activeAccountId = 'lemmy_active_account_id';

  /// `'1'` when the user purchased "Remove ads" (or debug-simulated).
  static const adsRemoved = 'bluerum_ads_removed';

  /// `'0'` disables ads app-wide; absent / other = enabled.
  static const adsEnabled = 'bluerum_ads_enabled';

  /// Home feed layout: compact, normal, or large (the default).
  static const feedViewMode = 'bluerum_feed_view_mode';
}
