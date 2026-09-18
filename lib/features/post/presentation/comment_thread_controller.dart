import 'package:flutter/foundation.dart';

import 'package:bluerum/features/ads/domain/ads_config.dart';
import 'package:bluerum/features/ads/domain/ads_placement.dart';
import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/features/post/presentation/comment_thread_flatten.dart';
import 'package:bluerum/shared/models/comment.dart';

/// Single source of truth for a post-detail **comment tree**.
///
/// Owns entities, collapse set, flat rows, body VMs, O(1) index maps, and
/// ad-interleaved display entries (revision-keyed).
///
/// Important for fling fidelity: rebuilding the flat tree must stay structural.
/// It must not eagerly parse every loaded comment body; rows obtain their VM
/// lazily when Flutter actually mounts them near the viewport.
///
/// Listen with [ListenableBuilder] so collapse/load merges rebuild the list
/// without a full [Scaffold] setState when the screen only notifies this
/// controller.
final class CommentThreadController extends ChangeNotifier {
  CommentThreadController({
    this.maxRenderDepth = 8,
    CommentBodyVmStore? bodyVms,
  }) : bodyVms = bodyVms ?? CommentBodyVmStore();

  final int maxRenderDepth;
  final CommentBodyVmStore bodyVms;

  /// All loaded comments, keyed by id.
  final Map<int, CommentView> comments = <int, CommentView>{};

  /// API order of ids (page-aware merge order).
  final List<int> orderedIds = <int>[];

  final Set<int> collapsedIds = <int>{};

  /// Flattened paint rows (collapse + depth cap applied).
  List<CommentFlatRow> rows = const [];

  /// commentId → index in [rows].
  Map<int, int> rowIndexById = const {};

  /// When non-null, flatten treats this id as the thread display root
  /// (continue-thread / focused reply screens).
  int? threadDisplayRootId;

  /// ValueKey map for ListView/Sliver findChildIndex (screen may share).
  final Map<Key, int> idsByKey = <Key, int>{};

  /// Bumps on every structural rebuild so display-entry caches stay coherent.
  int revision = 0;

  List<CommentDisplayEntry>? _displayEntries;
  bool? _displayShowAds;
  int _displayRevision = -1;
  Map<int, int>? _rowIndexToDisplayIndex;

  bool get isEmpty => rows.isEmpty;
  int get rowCount => rows.length;

  CommentView? operator [](int id) => comments[id];

  bool contains(int id) => comments.containsKey(id);

  Key keyFor(int id) {
    final k = ValueKey<int>(id);
    idsByKey[k] = id;
    return k;
  }

  /// Replace first page (or clear then add).
  void resetAndAdd({
    required List<CommentView> pageComments,
    CommentView? contextParent,
    CommentView? threadRoot,
  }) {
    comments.clear();
    orderedIds.clear();
    collapsedIds.clear();
    rows = const [];
    rowIndexById = const {};
    idsByKey.clear();
    bodyVms.clear();
    _invalidateDisplayEntries();

    if (threadRoot != null) {
      if (contextParent != null) {
        _put(contextParent);
      }
      _put(threadRoot);
    }
    for (final cv in pageComments) {
      _put(cv);
    }
    rebuild(notify: true);
  }

  /// Merge additional page comments (load-more / revalidate).
  /// Returns how many **new** ids were inserted.
  int mergeComments(Iterable<CommentView> pageComments) {
    var added = 0;
    for (final cv in pageComments) {
      if (_put(cv)) added++;
    }
    if (added > 0 || rows.isEmpty) {
      rebuild(notify: true);
    }
    return added;
  }

  /// Insert or update a single comment (compose / edit / delete soft-state).
  void upsertComment(CommentView cv, {bool preferFront = false}) {
    final id = cv.comment.id;
    if (comments.containsKey(id)) {
      comments[id] = cv;
    } else {
      comments[id] = cv;
      if (preferFront) {
        orderedIds.insert(0, id);
      } else {
        orderedIds.add(id);
      }
    }
    rebuild(notify: true);
  }

  /// Seed without notify (e.g. cache restore before first frame).
  void seedQuiet({
    required List<CommentView> pageComments,
    CommentView? contextParent,
    CommentView? threadRoot,
  }) {
    comments.clear();
    orderedIds.clear();
    collapsedIds.clear();
    _invalidateDisplayEntries();
    if (threadRoot != null) {
      if (contextParent != null) _put(contextParent);
      _put(threadRoot);
    }
    for (final cv in pageComments) {
      _put(cv);
    }
    rebuild(notify: false);
  }

  void clear({bool notify = true}) {
    comments.clear();
    orderedIds.clear();
    collapsedIds.clear();
    rows = const [];
    rowIndexById = const {};
    idsByKey.clear();
    bodyVms.clear();
    _invalidateDisplayEntries();
    if (notify) notifyListeners();
  }

  bool toggleCollapse(int commentId) {
    if (collapsedIds.contains(commentId)) {
      collapsedIds.remove(commentId);
    } else {
      collapsedIds.add(commentId);
    }
    rebuild(notify: true);
    return collapsedIds.contains(commentId);
  }

  bool isCollapsed(int commentId) => collapsedIds.contains(commentId);

  void setThreadDisplayRoot(int? id) {
    if (threadDisplayRootId == id) return;
    threadDisplayRootId = id;
    rebuild(notify: true);
  }

  void rebuild({bool notify = true}) {
    rows = flattenCommentThread(
      commentMap: comments,
      orderedIds: orderedIds,
      collapsedIds: collapsedIds,
      maxRenderDepth: maxRenderDepth,
      threadDisplayRootId: threadDisplayRootId,
    );
    rowIndexById = commentIdToRowIndex(rows);
    revision++;
    _invalidateDisplayEntries();

    // Do not call bodyVms.prepareAll here — lazy bodyVmFor on mount only.

    final active = comments.keys.toSet();
    idsByKey.removeWhere((_, id) => !active.contains(id));

    if (notify) notifyListeners();
  }

  CommentBodyVm bodyVmFor(CommentView cv) =>
      bodyVms.obtain(commentId: cv.comment.id, content: cv.comment.content);

  /// Comment rows + optional in-feed ads (root-comment cadence).
  ///
  /// Cached until [revision] / [showAds] changes so list build does not
  /// re-walk the tree every frame.
  List<CommentDisplayEntry> bodyEntries({
    required bool showAds,
    int? rootsPerAd,
  }) {
    final roots = rootsPerAd ?? AdsConfig.commentRootsPerAd;
    if (_displayEntries != null &&
        _displayShowAds == showAds &&
        _displayRevision == revision) {
      return _displayEntries!;
    }
    _displayShowAds = showAds;
    _displayRevision = revision;
    final entries = buildCommentDisplayEntries(
      rowCount: rows.length,
      isRootAt: (i) => rows[i].depth == 0,
      rootsPerAd: roots,
      showAds: showAds,
    );
    _displayEntries = entries;
    final map = <int, int>{};
    for (var i = 0; i < entries.length; i++) {
      final rowIndex = entries[i].rowIndex;
      if (rowIndex != null) map[rowIndex] = i;
    }
    _rowIndexToDisplayIndex = map;
    return entries;
  }

  /// Flat row index → index inside [bodyEntries] (O(1) for findChildIndex).
  int? displayIndexForRow(int rowIndex, {required bool showAds}) {
    bodyEntries(showAds: showAds);
    return _rowIndexToDisplayIndex?[rowIndex];
  }

  void _invalidateDisplayEntries() {
    _displayEntries = null;
    _displayRevision = -1;
    _rowIndexToDisplayIndex = null;
  }

  /// Returns true if newly inserted.
  bool _put(CommentView cv) {
    final id = cv.comment.id;
    if (comments.containsKey(id)) {
      comments[id] = cv; // refresh entity
      return false;
    }
    comments[id] = cv;
    orderedIds.add(id);
    return true;
  }

  @override
  void dispose() {
    bodyVms.clear();
    comments.clear();
    orderedIds.clear();
    collapsedIds.clear();
    rows = const [];
    rowIndexById = const {};
    idsByKey.clear();
    _invalidateDisplayEntries();
    super.dispose();
  }
}
