import 'package:bluerum/core/utils/markdown_utils.dart';
import 'package:bluerum/shared/models/post.dart';

/// Precomputed fields for one discover community row.
///
/// Built **once** per content identity (not on every list build / recycle) so
/// horizontal fling does not re-run markdown AST parse or number formatting.
final class DiscoverCommunityRowVm {
  const DiscoverCommunityRowVm({
    required this.id,
    required this.name,
    required this.title,
    required this.iconUrl,
    required this.descriptionPlain,
    required this.statsLine,
    required this.subscribed,
  });

  final int id;
  final String name;
  final String title;
  final String? iconUrl;

  /// Markdown-stripped, trimmed description for one-line preview (may be empty).
  final String descriptionPlain;

  /// e.g. `1.2k members · 340 active/wk`
  final String statsLine;

  /// Server subscribe state at build time (`Subscribed` / `Pending` / …).
  final String subscribed;

  bool get hasIcon => iconUrl != null && iconUrl!.isNotEmpty;
  bool get hasDescription => descriptionPlain.isNotEmpty;

  factory DiscoverCommunityRowVm.fromView(CommunityView view) {
    final c = view.community;
    final title = c.title.isNotEmpty ? c.title : c.name;
    final descRaw = c.description ?? '';
    final desc = descRaw.isEmpty ? '' : markdownToPlainText(descRaw).trim();
    final counts = view.counts;
    return DiscoverCommunityRowVm(
      id: c.id,
      name: c.name,
      title: title,
      iconUrl: c.icon,
      descriptionPlain: desc,
      statsLine:
          '${formatCompactCount(counts.subscribers)} members · '
          '${formatCompactCount(counts.usersActiveWeek)} active/wk',
      subscribed: view.subscribed,
    );
  }
}

/// Per-surface cache of [DiscoverCommunityRowVm] keyed by community id.
///
/// Invalidates when title / name / icon / description / counts / subscribe
/// string change so markdown never re-runs on pure rebuilds.
final class DiscoverCommunityVmCache {
  final Map<int, DiscoverCommunityRowVm> _vms = <int, DiscoverCommunityRowVm>{};
  final Map<int, String> _identity = <int, String>{};

  DiscoverCommunityRowVm vmFor(CommunityView view) {
    final id = view.community.id;
    final identity = _identityOf(view);
    final existing = _vms[id];
    if (existing != null && _identity[id] == identity) {
      return existing;
    }
    final vm = DiscoverCommunityRowVm.fromView(view);
    _vms[id] = vm;
    _identity[id] = identity;
    return vm;
  }

  DiscoverCommunityRowVm? peek(int communityId) => _vms[communityId];

  void warm(Iterable<CommunityView> views) {
    for (final v in views) {
      vmFor(v);
    }
  }

  void retainOnly(Set<int> activeIds) {
    _vms.removeWhere((id, _) => !activeIds.contains(id));
    _identity.removeWhere((id, _) => !activeIds.contains(id));
  }

  void clear() {
    _vms.clear();
    _identity.clear();
  }

  static String _identityOf(CommunityView view) {
    final c = view.community;
    final counts = view.counts;
    return '${c.name}\u0001${c.title}\u0001${c.icon ?? ''}\u0001'
        '${c.description ?? ''}\u0001${counts.subscribers}\u0001'
        '${counts.usersActiveWeek}\u0001${view.subscribed}';
  }
}

/// Compact count label shared by discover rows (1.2k / 3.4M).
String formatCompactCount(int n) {
  if (n >= 1000000) {
    final v = n / 1000000;
    return '${v.toStringAsFixed(v >= 10 ? 0 : 1)}M';
  }
  if (n >= 1000) {
    final v = n / 1000;
    return '${v.toStringAsFixed(v >= 10 ? 0 : 1)}k';
  }
  return '$n';
}

/// Chunk a flat list into columns of [rowsPerColumn] (last column may be short).
List<List<T>> chunkDiscoverColumns<T>(
  List<T> items, {
  required int rowsPerColumn,
}) {
  assert(rowsPerColumn > 0);
  if (items.isEmpty) return const [];
  final columns = <List<T>>[];
  for (var i = 0; i < items.length; i += rowsPerColumn) {
    final end = (i + rowsPerColumn).clamp(0, items.length);
    columns.add(items.sublist(i, end));
  }
  return columns;
}
