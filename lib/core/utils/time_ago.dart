import 'package:flutter/foundation.dart';

/// Time-ago labels cached by published ISO string (avoid parse every build).
final Map<String, String> _timeAgoCache = <String, String>{};

String formatCommentTimeAgo(String published, {DateTime? now}) {
  final cached = _timeAgoCache[published];
  if (cached != null) return cached;

  final date = DateTime.tryParse(published);
  if (date == null) {
    _timeAgoCache[published] = '';
    return '';
  }
  final base = now ?? DateTime.now().toUtc();
  final publishedUtc = date.isUtc ? date : date.toUtc();
  final diff = base.difference(publishedUtc);
  late final String label;
  if (diff.inDays > 365) {
    label = '${diff.inDays ~/ 365} yr. ago';
  } else if (diff.inDays > 30) {
    label = '${diff.inDays ~/ 30} mo. ago';
  } else if (diff.inDays > 0) {
    label = '${diff.inDays} d. ago';
  } else if (diff.inHours > 0) {
    label = '${diff.inHours} hr. ago';
  } else if (diff.inMinutes > 0) {
    label = '${diff.inMinutes} min. ago';
  } else {
    label = 'just now';
  }
  if (_timeAgoCache.length > 800) {
    _timeAgoCache.clear();
  }
  _timeAgoCache[published] = label;
  return label;
}

@visibleForTesting
void clearCommentTimeAgoCache() => _timeAgoCache.clear();
