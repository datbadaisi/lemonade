import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/models/site.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/shared/widgets/auth/login_required_scaffold.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';

class BlocksScreen extends ConsumerStatefulWidget {
  final int personId;

  const BlocksScreen({
    super.key,
    required this.personId,
  });

  @override
  ConsumerState<BlocksScreen> createState() => _BlocksScreenState();
}

class _BlocksScreenState extends ConsumerState<BlocksScreen> {
  LemmyApiService get _api => ref.read(lemmyApiClientProvider);
  List<PersonBlockView> _personBlocks = [];
  List<CommunityBlockView> _communityBlocks = [];
  List<InstanceBlockView> _instanceBlocks = [];
  bool _isLoading = true;
  String? _error;

  final Map<int, bool> _unblockingUsers = {};
  final Map<int, bool> _unblockingCommunities = {};
  final Map<int, bool> _unblockingInstances = {};


  Future<int> _resolvePersonId() async {
    if (widget.personId != 0) return widget.personId;
    final site = await _api.getSite();
    return site.myUser?.person.id ?? 0;
  }

  @override
  void initState() {
    super.initState();
    if (ref.read(authRepositoryProvider).isLoggedIn) _fetchBlocks();
  }

  Future<void> _fetchBlocks() async {
    if (!mounted) return;
    final canKeepExisting = _personBlocks.isNotEmpty ||
        _communityBlocks.isNotEmpty ||
        _instanceBlocks.isNotEmpty;
    setState(() {
      _isLoading = !canKeepExisting;
      _error = null;
    });

    try {
      final siteInfo = await _api.fetchSiteInfo();
      if (mounted) {
        setState(() {
          _personBlocks = siteInfo.myUser?.personBlocks ?? [];
          _communityBlocks = siteInfo.myUser?.communityBlocks ?? [];
          _instanceBlocks = siteInfo.myUser?.instanceBlocks ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = canKeepExisting ? null : formatError(e);
        });
      }
    }
  }

  Future<void> _unblockUser(Person target) async {
    final username = target.name;
    final domain = target.actorId.isNotEmpty
        ? (Uri.tryParse(target.actorId)?.host ?? '')
        : '';
    final formattedUser = 'u/$username${domain.isNotEmpty ? '@$domain' : ''}';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Unblock User',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF000000))),
        content: Text('Are you sure you want to unblock $formattedUser?', style: const TextStyle(fontSize: 13, color: Color(0xFF525252))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 13, color: Color(0xFF525252), fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Unblock',
              style: TextStyle(fontSize: 13, color: Color(0xFFE53935), fontWeight: FontWeight.w700))),
        ]));

    if (confirm != true) return;

    setState(() {
      _unblockingUsers[target.id] = true;
    });

    try {
      await _api.blockPerson(personId: target.id, block: false);
      if (mounted) {
        setState(() {
          _personBlocks.removeWhere((item) => item.target.id == target.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unblocked $formattedUser')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${formatError(e)}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _unblockingUsers.remove(target.id);
        });
      }
    }
  }

  Future<void> _unblockCommunity(Community target) async {
    final name = target.name;
    final domain = target.actorId.isNotEmpty
        ? (Uri.tryParse(target.actorId)?.host ?? '')
        : '';
    final formattedCommunity = 'c/$name${domain.isNotEmpty ? '@$domain' : ''}';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Unblock Community',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF000000))),
        content: Text('Are you sure you want to unblock $formattedCommunity?', style: const TextStyle(fontSize: 13, color: Color(0xFF525252))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 13, color: Color(0xFF525252), fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Unblock',
              style: TextStyle(fontSize: 13, color: Color(0xFFE53935), fontWeight: FontWeight.w700))),
        ]));

    if (confirm != true) return;

    setState(() {
      _unblockingCommunities[target.id] = true;
    });

    try {
      await _api.blockCommunity(communityId: target.id, block: false);
      if (mounted) {
        setState(() {
          _communityBlocks.removeWhere((item) => item.community.id == target.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unblocked $formattedCommunity')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${formatError(e)}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _unblockingCommunities.remove(target.id);
        });
      }
    }
  }

  Future<void> _unblockInstance(Instance target) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Unblock Instance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF000000))),
        content: Text('Are you sure you want to unblock ${target.domain}?', style: const TextStyle(fontSize: 13, color: Color(0xFF525252))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 13, color: Color(0xFF525252), fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Unblock',
              style: TextStyle(fontSize: 13, color: Color(0xFFE53935), fontWeight: FontWeight.w700))),
        ]));

    if (confirm != true) return;

    setState(() {
      _unblockingInstances[target.id] = true;
    });

    try {
      await _api.blockInstance(instanceId: target.id, block: false);
      if (mounted) {
        setState(() {
          _instanceBlocks.removeWhere((item) => item.instance.id == target.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unblocked ${target.domain}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${formatError(e)}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _unblockingInstances.remove(target.id);
        });
      }
    }
  }

  Widget _buildUnblockButton({
    required VoidCallback onPressed,
    required String label,
    required bool isLoading,
  }) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF525252),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(70, 32)),
      child: isLoading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF525252)))
          : Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold)));
  }

  Widget _buildUserTile(PersonBlockView blockView) {
    final person = blockView.target;
    final username = person.name;
    final domain = person.actorId.isNotEmpty
        ? (Uri.tryParse(person.actorId)?.host ?? '')
        : '';
    final subtitle = 'u/$username${domain.isNotEmpty ? '@$domain' : ''}';
    final isUnblocking = _unblockingUsers[person.id] ?? false;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF000000)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 12),
          _buildUnblockButton(
            onPressed: () => _unblockUser(person),
            label: 'Unblock',
            isLoading: isUnblocking),
        ]));
  }

  Widget _buildCommunityTile(CommunityBlockView blockView) {
    final community = blockView.community;
    final title = community.title.isNotEmpty ? community.title : community.name;
    final name = community.name;
    final domain = community.actorId.isNotEmpty
        ? (Uri.tryParse(community.actorId)?.host ?? '')
        : '';
    final subtitle = 'c/$name${domain.isNotEmpty ? '@$domain' : ''}';
    final isUnblocking = _unblockingCommunities[community.id] ?? false;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF000000)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF525252)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              ])),
          const SizedBox(width: 12),
          _buildUnblockButton(
            onPressed: () => _unblockCommunity(community),
            label: 'Unblock',
            isLoading: isUnblocking),
        ]));
  }

  Widget _buildInstanceTile(InstanceBlockView blockView) {
    final instance = blockView.instance;
    final name = instance.domain;
    final isUnblocking = _unblockingInstances[instance.id] ?? false;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF000000)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 12),
          _buildUnblockButton(
            onPressed: () => _unblockInstance(instance),
            label: 'Unblock',
            isLoading: isUnblocking),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return const LoginRequiredScaffold(title: 'Your blocks are waiting');
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Blocks',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF000000))),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(MingCuteIcons.mgc_left_line, color: Color(0xFF000000)),
            onPressed: () => Navigator.of(context).pop()),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: TabBar(
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelColor: Color(0xFF000000),
              unselectedLabelColor: Color(0xFF525252),
              labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: 'Block User'),
                Tab(text: 'Block Community'),
                Tab(text: 'Block Instance'),
              ],
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null &&
        _personBlocks.isEmpty &&
        _communityBlocks.isEmpty &&
        _instanceBlocks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(MingCuteIcons.mgc_wifi_off_line, size: 48, color: Color(0xFF525252)),
              const SizedBox(height: 12),
              const Text(
                'Could not load blocks',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF000000))),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF525252)),
                textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _fetchBlocks,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999))),
                child: const Text('Retry', style: TextStyle(color: Colors.white))),
            ])));
    }

    return TabBarView(
      children: [
        BlockedList<PersonBlockView>(
          items: _personBlocks,
          title: 'Users',
          emptyMessage: 'No blocked users',
          onRefresh: _refreshBlocks,
          isLoading: _isLoading,
          hasSubtitle: false,
          itemBuilder: (context, blockView, _) => _buildUserTile(blockView)),
        BlockedList<CommunityBlockView>(
          items: _communityBlocks,
          title: 'Communities',
          emptyMessage: 'No blocked communities',
          onRefresh: _refreshBlocks,
          isLoading: _isLoading,
          hasSubtitle: true,
          itemBuilder: (context, blockView, _) => _buildCommunityTile(blockView)),
        BlockedList<InstanceBlockView>(
          items: _instanceBlocks,
          title: 'Instances',
          emptyMessage: 'No blocked instances',
          onRefresh: _refreshBlocks,
          isLoading: _isLoading,
          hasSubtitle: false,
          itemBuilder: (context, blockView, _) => _buildInstanceTile(blockView)),
      ]);
  }

  Future<void> _refreshBlocks() => runWithMediaBudgetRecovery(
        _fetchBlocks,
        isMounted: () => mounted,
      );
}

class BlockedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final String emptyMessage;
  final String title;
  final bool isLoading;
  final bool hasSubtitle;

  const BlockedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.emptyMessage,
    required this.title,
    required this.isLoading,
    required this.hasSubtitle,
  });

  @override
  State<BlockedList<T>> createState() => _BlockedListState<T>();
}

class _BlockedListState<T> extends State<BlockedList<T>> {
  final ScrollController _scrollController = ScrollController();
  int _visibleCount = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
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
      if (_visibleCount < widget.items.length && !_isLoadingMore) {
        setState(() {
          _isLoadingMore = true;
        });
        // Simulate network loading delay for standard scroll loading feel
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _visibleCount = (_visibleCount + 10).clamp(0, widget.items.length);
              _isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  Widget _buildSkeletonBlockTile({required bool hasSubtitle}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Skeleton(height: 14, width: 140),
                if (hasSubtitle) ...[
                  const SizedBox(height: 6),
                  const Skeleton(height: 11, width: 180),
                ],
              ])),
          const SizedBox(width: 12),
          const Skeleton(height: 32, width: 70),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.items.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemBuilder: (context, index) => _buildSkeletonBlockTile(hasSubtitle: widget.hasSubtitle));
    }

    if (widget.items.isEmpty) {
      return Align(
        alignment: const Alignment(0.0, -0.2),
        child: Text(
          widget.emptyMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000))));
    }

    final displayCount = _visibleCount.clamp(0, widget.items.length);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: const Color(0xFF000000),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        // Text-only rows but still recycle tightly when list is long.
        cacheExtent: 240,
        itemCount: displayCount + (_visibleCount < widget.items.length ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == displayCount) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF000000)))));
          }
          return RepaintBoundary(
            child: widget.itemBuilder(context, widget.items[index], index),
          );
        }));
  }
}
