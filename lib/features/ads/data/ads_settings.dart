import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/constants/storage_keys.dart';
import 'package:bluerum/core/storage/key_value_store.dart';

/// Snapshot of ad visibility flags.
///
/// - [adsRemoved]: set after a successful "Remove ads" purchase (or debug).
/// - [adsEnabled]: master kill-switch (default on).
///
/// UI should gate on [showAds].
final class AdsState {
  const AdsState({
    required this.adsRemoved,
    required this.adsEnabled,
  });

  final bool adsRemoved;
  final bool adsEnabled;

  bool get showAds => adsEnabled && !adsRemoved;

  AdsState copyWith({bool? adsRemoved, bool? adsEnabled}) {
    return AdsState(
      adsRemoved: adsRemoved ?? this.adsRemoved,
      adsEnabled: adsEnabled ?? this.adsEnabled,
    );
  }
}

/// Persists and exposes ad flags for the remove-ads IAP path.
class AdsSettingsNotifier extends Notifier<AdsState> {
  KeyValueStore get _store => ref.read(keyValueStoreProvider);

  @override
  AdsState build() {
    final store = ref.watch(keyValueStoreProvider);
    final removed = store.getString(StorageKeys.adsRemoved) == '1';
    // Default enabled when key is absent.
    final enabled = store.getString(StorageKeys.adsEnabled) != '0';
    return AdsState(adsRemoved: removed, adsEnabled: enabled);
  }

  /// Call from the future IAP flow after a verified purchase (or restore).
  Future<void> setAdsRemoved(bool removed) async {
    if (state.adsRemoved == removed) return;
    if (removed) {
      await _store.setString(StorageKeys.adsRemoved, '1');
    } else {
      await _store.remove(StorageKeys.adsRemoved);
    }
    state = state.copyWith(adsRemoved: removed);
  }

  /// Master kill-switch. Prefer remote config later; local for now.
  Future<void> setAdsEnabled(bool enabled) async {
    if (state.adsEnabled == enabled) return;
    if (enabled) {
      await _store.remove(StorageKeys.adsEnabled);
    } else {
      await _store.setString(StorageKeys.adsEnabled, '0');
    }
    state = state.copyWith(adsEnabled: enabled);
  }
}

final adsSettingsProvider =
    NotifierProvider<AdsSettingsNotifier, AdsState>(AdsSettingsNotifier.new);
