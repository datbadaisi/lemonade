import 'package:bluerum/shared/models/post.dart';
import 'package:flutter/foundation.dart';

import 'post_list_vm_cache.dart';

/// Local SSOT for one post-list surface (community / profile / search / saved).
///
/// Independent of home [feedPostsByIdProvider]; vote overlays stay global.
final class SurfacePostStore extends ChangeNotifier {
  SurfacePostStore();

  final List<int> _order = <int>[];
  final Map<int, PostView> _byId = <int, PostView>{};
  final PostListVmCache vmCache = PostListVmCache();

  List<int> get order => List<int>.unmodifiable(_order);
  int get length => _order.length;
  bool get isEmpty => _order.isEmpty;
  bool get isNotEmpty => _order.isNotEmpty;

  PostView? operator [](int postId) => _byId[postId];

  List<PostView> get posts =>
      [for (final id in _order) _byId[id]!];

  /// Replaces the full list (refresh / first page).
  void replaceAll(List<PostView> list) {
    _order
      ..clear()
      ..addAll(list.map((p) => p.post.id));
    _byId
      ..clear()
      ..addEntries(list.map((p) => MapEntry(p.post.id, p)));
    vmCache.retainOnly(_byId.keys.toSet());
    for (final p in list) {
      vmCache.vmFor(p);
    }
    notifyListeners();
  }

  /// Appends unique posts (load-more). Skips ids already present.
  void append(List<PostView> list) {
    if (list.isEmpty) return;
    var changed = false;
    for (final p in list) {
      final id = p.post.id;
      if (_byId.containsKey(id)) {
        _byId[id] = p;
        vmCache.vmFor(p);
        continue;
      }
      _byId[id] = p;
      _order.add(id);
      vmCache.vmFor(p);
      changed = true;
    }
    if (changed) {
      notifyListeners();
    } else {
      // Still may have updated existing entities.
      notifyListeners();
    }
  }

  void upsert(PostView pv) {
    final id = pv.post.id;
    final had = _byId.containsKey(id);
    _byId[id] = pv;
    if (!had) _order.add(id);
    vmCache.vmFor(pv);
    notifyListeners();
  }

  /// Updates entity without notifying (caller batches).
  void upsertSilent(PostView pv) {
    final id = pv.post.id;
    final had = _byId.containsKey(id);
    _byId[id] = pv;
    if (!had) _order.add(id);
    vmCache.vmFor(pv);
  }

  void remove(int postId) {
    if (!_byId.containsKey(postId)) return;
    _byId.remove(postId);
    _order.remove(postId);
    vmCache.remove(postId);
    notifyListeners();
  }

  void clear() {
    _order.clear();
    _byId.clear();
    vmCache.clear();
    notifyListeners();
  }
}
