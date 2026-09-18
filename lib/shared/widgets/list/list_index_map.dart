/// O(1) [ListView]/[SliverChildBuilderDelegate] recycle index lookup.
///
/// Canonical helper for Search / Notifications / picker avatar lists — avoids
/// linear scans on every element recycle (same idea as [PostListIndexMap]).
final class ListIndexMap {
  /// Homogeneous id lists (`ValueKey<int>(id)`).
  ListIndexMap.fromIds(List<int> ids, {this.footerSlots = 0})
      : _intToIndex = <int, int>{
          for (var i = 0; i < ids.length; i++) ids[i]: i,
        },
        _stringToIndex = const {};

  /// Heterogeneous string keys (`ValueKey('r_12')`, …).
  ListIndexMap.fromStringKeys(List<String> keys, {this.footerSlots = 0})
      : _intToIndex = const {},
        _stringToIndex = <String, int>{
          for (var i = 0; i < keys.length; i++) keys[i]: i,
        };

  final Map<int, int> _intToIndex;
  final Map<String, int> _stringToIndex;
  final int footerSlots;

  /// Resolves a [ValueKey] `.value` to a list index.
  int? indexForKeyValue(Object? value) {
    if (value is int) return _intToIndex[value];
    if (value is String) return _stringToIndex[value];
    return null;
  }
}
