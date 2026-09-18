import 'package:flutter/foundation.dart';

import 'package:bluerum/shared/widgets/media/upload_item.dart';

/// Shared media tray for create-post and comment-compose.
///
/// Parents listen via [ListenableBuilder] instead of full-screen [setState]
/// on every upload tick. The attach sheet listens to the same list.
final class MediaAttachList extends ChangeNotifier {
  final List<UploadItem> items = <UploadItem>[];
  bool _disposed = false;

  int get length => items.length;

  int get successfulCount => items.where((e) => e.isSuccessful).length;

  bool get isAnyUploading => items.any((e) => e.isUploading);

  bool get hasAnyError => items.any((e) => e.error != null);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  void add(UploadItem item) {
    if (_disposed) return;
    items.add(item);
    notifyListeners();
  }

  void addAll(Iterable<UploadItem> more) {
    if (_disposed) return;
    final list = more.toList(growable: false);
    if (list.isEmpty) return;
    items.addAll(list);
    notifyListeners();
  }

  void removeAt(int index) {
    if (_disposed) return;
    if (index < 0 || index >= items.length) return;
    items.removeAt(index).cancel();
    notifyListeners();
  }

  /// Call after mutating fields on an existing [UploadItem] (upload progress).
  void markChanged() {
    if (_disposed) return;
    notifyListeners();
  }

  void cancelAll() {
    for (final item in items) {
      item.cancel();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    cancelAll();
    items.clear();
    super.dispose();
  }
}
