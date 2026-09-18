import 'package:bluerum/features/feed/presentation/post_card_vm.dart';
import 'package:bluerum/shared/models/post.dart';

/// Per-surface cache of [PostCardVm] keyed by post id.
///
/// Invalidates when body / name / thumbnail / url / imageDetails change so
/// markdown + media extract never re-run on pure vote/score rebuilds.
final class PostListVmCache {
  final Map<int, PostCardVm> _vms = <int, PostCardVm>{};
  final Map<int, String> _identity = <int, String>{};

  PostCardVm vmFor(PostView pv) {
    final id = pv.post.id;
    final identity = _identityOf(pv);
    final existing = _vms[id];
    if (existing != null && _identity[id] == identity) {
      return existing;
    }
    final vm = PostCardVm.fromPostView(pv);
    _vms[id] = vm;
    _identity[id] = identity;
    return vm;
  }

  PostCardVm? peek(int postId) => _vms[postId];

  void remove(int postId) {
    _vms.remove(postId);
    _identity.remove(postId);
  }

  void retainOnly(Set<int> activeIds) {
    _vms.removeWhere((id, _) => !activeIds.contains(id));
    _identity.removeWhere((id, _) => !activeIds.contains(id));
  }

  void clear() {
    _vms.clear();
    _identity.clear();
  }

  static String _identityOf(PostView pv) {
    final p = pv.post;
    final d = pv.imageDetails;
    return '${p.name}\u0001${p.body ?? ''}\u0001${p.url ?? ''}\u0001'
        '${p.thumbnailUrl ?? ''}\u0001${p.embedTitle ?? ''}\u0001'
        '${d?.width ?? 0}x${d?.height ?? 0}\u0001${p.nsfw}';
  }
}
