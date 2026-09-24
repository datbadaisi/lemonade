import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/constants/storage_keys.dart';

enum FeedViewMode {
  compact('Compact'),
  normal('Normal'),
  large('Large');

  const FeedViewMode(this.label);

  final String label;

  static FeedViewMode fromStorage(String? value) {
    for (final mode in values) {
      if (mode.name == value) return mode;
    }
    return large;
  }
}

class FeedViewSettingsNotifier extends Notifier<FeedViewMode> {
  @override
  FeedViewMode build() => FeedViewMode.fromStorage(
    ref.watch(keyValueStoreProvider).getString(StorageKeys.feedViewMode),
  );

  Future<void> setMode(FeedViewMode mode) async {
    if (state == mode) return;
    state = mode;
    await ref
        .read(keyValueStoreProvider)
        .setString(StorageKeys.feedViewMode, mode.name);
  }
}

final feedViewSettingsProvider =
    NotifierProvider<FeedViewSettingsNotifier, FeedViewMode>(
      FeedViewSettingsNotifier.new,
    );
