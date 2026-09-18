import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluerum/app/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/features/community/presentation/community_detail_screen.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/auth/login_required_scaffold.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';

const Color _accent = Color(0xFF000000);
const Color _textPrimary = Color(0xFF000000);
const Color _textSecondary = Color(0xFF525252);

class SubscribedCommunitiesScreen extends ConsumerStatefulWidget {
  final int personId;

  const SubscribedCommunitiesScreen({
    super.key,
    required this.personId,
  });

  @override
  ConsumerState<SubscribedCommunitiesScreen> createState() => _SubscribedCommunitiesScreenState();
}

class _SubscribedCommunitiesScreenState extends ConsumerState<SubscribedCommunitiesScreen> {
  LemmyApiService get _api => ref.read(lemmyApiClientProvider);
  List<CommunityView> _communities = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  final Map<int, bool> _unsubscribingMap = {};

  @override
  void initState() {
    super.initState();
    if (ref.read(authRepositoryProvider).isLoggedIn) {
      _fetchSubscribed(reset: true);
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _fetchSubscribed(reset: false);
      }
    }
  }

  Future<void> _fetchSubscribed({required bool reset}) async {
    if (!mounted) return;
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final list = await _api.listCommunities(
        type: 'Subscribed',
        page: _page,
        limit: _limit);

      if (mounted) {
        setState(() {
          if (reset) {
            _communities = list;
            _hasMore = list.length >= _limit;
          } else {
            final seen = _communities.map((c) => c.community.id).toSet();
            final unique =
                list.where((c) => seen.add(c.community.id)).toList();
            _communities.addAll(unique);
            _hasMore = list.length >= _limit && unique.isNotEmpty;
          }
          _isLoading = false;
          _isLoadingMore = false;
          _page++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _error = formatError(e);
        });
      }
    }
  }

  Future<void> _unsubscribe(Community community) async {
    final title = community.title.isNotEmpty ? community.title : community.name;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Unsubscribe',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF000000))),
        content: Text('Are you sure you want to unsubscribe from c/${community.name}?', style: const TextStyle(fontSize: 13, color: Color(0xFF525252))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 13, color: Color(0xFF525252), fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Unsubscribe',
              style: TextStyle(fontSize: 13, color: Color(0xFFE53935), fontWeight: FontWeight.w700))),
        ]));

    if (confirm != true) return;

    setState(() {
      _unsubscribingMap[community.id] = true;
    });

    try {
      await _api.followCommunity(communityId: community.id, follow: false);
      if (mounted) {
        setState(() {
          _communities.removeWhere((item) => item.community.id == community.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unsubscribed from $title')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${formatError(e)}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _unsubscribingMap.remove(community.id);
        });
      }
    }
  }

  Widget _buildLetterAvatar(String title, double size) {
    final initial = title.trim().isNotEmpty ? title.trim()[0].toUpperCase() : '?';
    final colors = [
      const Color(0xFF3B6073),
      const Color(0xFF8A307F),
      const Color(0xFF0F2027),
      const Color(0xFF1E3C72),
      const Color(0xFF2C5364),
    ];
    final color = colors[title.length % colors.length];

    return Container(
      width: size,
      height: size,
      color: color,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
          color: Colors.white)));
  }

  Widget _buildCommunityTile(CommunityView communityView) {
    final community = communityView.community;
    final title = community.title.isNotEmpty ? community.title : community.name;
    final subtitle = 'c/${community.name}';
    final isUnsubscribing = _unsubscribingMap[community.id] ?? false;
    final hasIcon = community.icon != null && community.icon!.isNotEmpty;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CommunityDetailScreen(
              communityId: community.id)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            NetworkAvatar.forList(
              size: 40,
              imageUrl: hasIcon ? community.icon : null,
              name: title,
              fallback: _buildLetterAvatar(title, 40),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: _textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                ])),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: isUnsubscribing ? null : () => _unsubscribe(community),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF525252),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(80, 32)),
              child: isUnsubscribing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF525252)))
                  : const Text(
                      'Unsubscribe',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
          ])));
  }

  Widget _buildSkeletonTile() {
    return const SubscribedCommunityTileSkeleton();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return const LoginRequiredScaffold(title: 'Your communities are waiting');
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Subscribed',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(MingCuteIcons.mgc_left_line, color: _textPrimary),
          onPressed: () => Navigator.of(context).pop()),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _communities.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemBuilder: (context, index) => _buildSkeletonTile());
    }

    if (_error != null && _communities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(MingCuteIcons.mgc_wifi_off_line, size: 48, color: _textSecondary),
              const SizedBox(height: 12),
              const Text(
                'Could not load subscriptions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(fontSize: 13, color: _textSecondary),
                textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => _fetchSubscribed(reset: true),
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999))),
                child: const Text('Retry', style: TextStyle(color: Colors.white))),
            ])));
    }

    if (_communities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE8E8E8),
                shape: BoxShape.circle),
              child: const Icon(MingCuteIcons.mgc_group_3_line, size: 40, color: _textSecondary)),
            const SizedBox(height: 16),
            const Text(
              'No subscriptions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Communities you subscribe to will appear here.',
              style: TextStyle(fontSize: 13, color: _textSecondary)),
          ]));
    }

    return RefreshIndicator(
      onRefresh: () => runWithMediaBudgetRecovery(
        () => _fetchSubscribed(reset: true),
        isMounted: () => mounted,
      ),
      color: _accent,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        // Avatar list: recycle tight like Search Communities.
        cacheExtent: 240,
        itemCount: _communities.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == _communities.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _accent))));
          }
          final c = _communities[index];
          return KeyedSubtree(
            key: ValueKey<int>(c.community.id),
            child: RepaintBoundary(child: _buildCommunityTile(c)),
          );
        }));
  }
}
