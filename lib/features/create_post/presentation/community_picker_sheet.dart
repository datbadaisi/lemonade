import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/features/create_post/domain/create_post_helpers.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/list/list_index_map.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

const double _fontMeta = 12;
const double _fontBody = 13;
const double _fontTitle = 16;
const Color _kTextPrimary = Color(0xFF000000);
const Color _kTextSecondary = Color(0xFF525252);
const Color _kSurfaceMuted = Color(0xFFE8E8E8);
const Color _kBorder = Color(0xFFE0E0E0);
const Color _kHint = Color(0x66525252);

const int _kPageLimit = 20;
const double _kRowExtent = 64;

/// Session cache so the first sheet open does not network+setState mid-slide.
List<CommunityView>? _sessionSubscribedCache;
bool _sessionSubscribedFromFollows = false;

/// Opens a self-contained community picker (search + subscribed + load-more).
///
/// All list/search state lives inside the sheet — the host screen is not
/// rebuilt while the user scrolls or types.
///
/// On dismiss, frees decode/paint work and drops **live** image handles left by
/// avatar rows so Cancel/pop of create-post is not fighting a full icon cache.
Future<CommunityView?> showCommunityPickerSheet({
  required BuildContext context,
  required LemmyApiService api,
  CommunityView? selected,
}) async {
  // Warm in background if cold — sheet prefers cache for first paint.
  if (_sessionSubscribedCache == null) {
    unawaited(warmCommunityPickerCache(api));
  }
  final picked = await showModalBottomSheet<CommunityView>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    useSafeArea: true,
    // Default sheet animation ~250–300ms; keep content light until settle.
    builder: (ctx) => _CommunityPickerSheet(
      api: api,
      selected: selected,
    ),
  );
  _releasePickerMediaPressure();
  return picked;
}

/// Drop queued decode/paint left by disposed avatar rows.
///
/// Does **not** call [ImageCache.clearLiveImages] (process-wide thrash on the
/// feed underlay). List refs are cleared in sheet dispose so live handles drop.
void _releasePickerMediaPressure() {
  recoverMediaBudgets(notify: false, abandonInFlight: false);
}

/// Prefetch subscribed list while create-post is open (no UI).
///
/// Makes the first community-sheet open paint from memory instead of fighting
/// the bottom-sheet slide with a network setState.
Future<void> warmCommunityPickerCache(LemmyApiService api) async {
  if (_sessionSubscribedCache != null && _sessionSubscribedCache!.isNotEmpty) {
    return;
  }
  // [loadSubscribedCommunitiesQuiet] sets cache + follows flag on the real path.
  await loadSubscribedCommunitiesQuiet(api);
}

/// Quietly loads subscribed communities (for draft community upgrade).
/// Does not touch any sheet UI.
Future<List<CommunityView>> loadSubscribedCommunitiesQuiet(
  LemmyApiService api,
) async {
  try {
    final list = await api.listCommunities(
      type: 'Subscribed',
      sort: 'TopAll',
      limit: _kPageLimit,
      page: 1,
    );
    if (list.isNotEmpty) {
      _sessionSubscribedCache = list;
      _sessionSubscribedFromFollows = false;
      return list;
    }
  } catch (_) {}
  final follows = await _communitiesFromSiteFollows(api);
  _sessionSubscribedCache = follows;
  _sessionSubscribedFromFollows = follows.isNotEmpty;
  return follows;
}

Future<List<CommunityView>> _communitiesFromSiteFollows(
  LemmyApiService api,
) async {
  final site = await api.getSite();
  final follows = site.myUser?.follows ?? const <dynamic>[];
  final result = <CommunityView>[];

  for (final raw in follows) {
    if (raw is! Map<String, dynamic>) continue;
    final communityJson = raw['community'];
    if (communityJson is! Map<String, dynamic>) continue;
    try {
      final community = Community.fromJson(communityJson);
      result.add(
        CommunityView(
          community: community,
          subscribed: 'Subscribed',
          counts: CommunityAggregates(communityId: community.id),
        ),
      );
    } catch (_) {}
  }

  result.sort((a, b) {
    final at =
        a.community.title.isNotEmpty ? a.community.title : a.community.name;
    final bt =
        b.community.title.isNotEmpty ? b.community.title : b.community.name;
    return at.toLowerCase().compareTo(bt.toLowerCase());
  });
  return result;
}

class _CommunityPickerSheet extends StatefulWidget {
  const _CommunityPickerSheet({
    required this.api,
    this.selected,
  });

  final LemmyApiService api;
  final CommunityView? selected;

  @override
  State<_CommunityPickerSheet> createState() => _CommunityPickerSheetState();
}

class _CommunityPickerSheetState extends State<_CommunityPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  List<CommunityView> _subscribed = [];
  List<CommunityView> _searchResults = [];

  bool _loadingSubscribed = false;
  bool _loadingMoreSubscribed = false;
  bool _hasMoreSubscribed = true;
  int _subscribedPage = 1;
  bool _subscribedFromFollows = false;
  String? _subscribedError;

  bool _searching = false;
  bool _loadingMoreSearch = false;
  bool _hasMoreSearch = true;
  int _searchPage = 1;
  String _activeQuery = '';

  Timer? _debounce;
  Timer? _openSettleTimer;
  bool _loadMoreArmed = true;
  ListIndexMap? _subscribedIndexMap;
  ListIndexMap? _searchIndexMap;

  ListIndexMap _indexOf(List<CommunityView> rows) => ListIndexMap.fromIds([
        for (final c in rows) c.community.id,
      ]);

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);

    // Prefer session cache so first open is not empty→API mid-animation.
    final cached = _sessionSubscribedCache;
    if (cached != null && cached.isNotEmpty) {
      _subscribed = List<CommunityView>.of(cached);
      _loadingSubscribed = false;
      _subscribedFromFollows = _sessionSubscribedFromFollows;
      _hasMoreSubscribed = !_sessionSubscribedFromFollows &&
          cached.length >= _kPageLimit;
      _subscribedPage = 2;
      _subscribedIndexMap = _indexOf(_subscribed);
    } else {
      // Light skeleton only — network waits for open settle.
      _loadingSubscribed = true;
    }

    // Bottom sheet transition is ~250–300ms; hold heavy work until quiet.
    _openSettleTimer = Timer(mediaRouteTransitionQuiet, () {
      if (!mounted) return;
      if (_subscribed.isEmpty) {
        unawaited(_loadSubscribed(reset: true));
      } else {
        // Soft refresh without clearing the list (no skeleton flash).
        unawaited(_loadSubscribed(reset: true, keepVisible: true));
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _openSettleTimer?.cancel();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    // Free list references so live image handles can drop on the next frame.
    _subscribed = const [];
    _searchResults = const [];
    _subscribedIndexMap = null;
    _searchIndexMap = null;
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels < pos.maxScrollExtent - 240) {
      _loadMoreArmed = true;
      return;
    }
    if (!_loadMoreArmed) return;
    _loadMoreArmed = false;
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      _loadSubscribed(reset: false);
    } else {
      _search(query, reset: false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = [];
        _searching = false;
        _loadingMoreSearch = false;
        _hasMoreSearch = true;
        _searchPage = 1;
        _activeQuery = '';
      });
      return;
    }
    // Rebuild so skeleton can show while debounce waits.
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(trimmed, reset: true);
    });
  }

  Future<void> _loadSubscribed({
    required bool reset,
    bool keepVisible = false,
  }) async {
    if (_loadingSubscribed || _loadingMoreSubscribed) return;
    if (!reset) {
      if (!_hasMoreSubscribed || _subscribedFromFollows) {
        _loadMoreArmed = true;
        return;
      }
    }

    final page = reset ? 1 : _subscribedPage;
    // Avoid setState during sheet open when we already show cache/skeleton.
    final shouldShowLoadingChrome = reset && !keepVisible && _subscribed.isEmpty;
    if (shouldShowLoadingChrome || !reset) {
      setState(() {
        if (reset) {
          _loadingSubscribed = true;
          _subscribedError = null;
          _hasMoreSubscribed = true;
          _subscribedFromFollows = false;
          _subscribedPage = 1;
        } else {
          _loadingMoreSubscribed = true;
        }
      });
    } else if (reset) {
      // Soft refresh: keep rows, only track page flags.
      _subscribedError = null;
      _hasMoreSubscribed = true;
      _subscribedFromFollows = false;
      _subscribedPage = 1;
    }

    try {
      final list = await widget.api.listCommunities(
        type: 'Subscribed',
        sort: 'TopAll',
        limit: _kPageLimit,
        page: page,
      );
      if (!mounted) return;

      if (reset && list.isEmpty) {
        final fromFollows = await _communitiesFromSiteFollows(widget.api);
        if (!mounted) return;
        _sessionSubscribedCache = fromFollows;
        _sessionSubscribedFromFollows = fromFollows.isNotEmpty;
        setState(() {
          _subscribed = fromFollows;
          _subscribedIndexMap = _indexOf(fromFollows);
          _loadingSubscribed = false;
          _loadingMoreSubscribed = false;
          _hasMoreSubscribed = false;
          _subscribedFromFollows = fromFollows.isNotEmpty;
          _subscribedPage = 1;
          _subscribedError = null;
        });
        _loadMoreArmed = true;
        return;
      }

      if (reset) {
        _sessionSubscribedCache = list;
        _sessionSubscribedFromFollows = false;
      }
      setState(() {
        if (reset) {
          _subscribed = list;
          _hasMoreSubscribed = list.length >= _kPageLimit;
        } else {
          final ids = _subscribed.map((c) => c.community.id).toSet();
          final unique =
              list.where((c) => ids.add(c.community.id)).toList(growable: false);
          _subscribed.addAll(unique);
          _hasMoreSubscribed =
              list.length >= _kPageLimit && unique.isNotEmpty;
        }
        _subscribedIndexMap = _indexOf(_subscribed);
        _loadingSubscribed = false;
        _loadingMoreSubscribed = false;
        _subscribedPage = page + 1;
        _subscribedFromFollows = false;
        _subscribedError = null;
      });
      _loadMoreArmed = true;
    } catch (e) {
      if (reset) {
        try {
          final fromFollows = await _communitiesFromSiteFollows(widget.api);
          if (!mounted) return;
          _sessionSubscribedCache = fromFollows;
          _sessionSubscribedFromFollows = fromFollows.isNotEmpty;
          setState(() {
            _subscribed = fromFollows;
            _subscribedIndexMap = _indexOf(fromFollows);
            _loadingSubscribed = false;
            _loadingMoreSubscribed = false;
            _hasMoreSubscribed = false;
            _subscribedFromFollows = fromFollows.isNotEmpty;
            _subscribedError =
                fromFollows.isEmpty ? formatCreatePostError(e) : null;
          });
          _loadMoreArmed = true;
          return;
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _loadingSubscribed = false;
        _loadingMoreSubscribed = false;
        if (reset && _subscribed.isEmpty) {
          _subscribedError = formatCreatePostError(e);
        }
      });
      _loadMoreArmed = true;
    }
  }

  Future<void> _search(String query, {required bool reset}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    if (_searching || _loadingMoreSearch) {
      _loadMoreArmed = true;
      return;
    }
    if (!reset && (!_hasMoreSearch || trimmed != _activeQuery)) {
      _loadMoreArmed = true;
      return;
    }

    final page = reset ? 1 : _searchPage;
    setState(() {
      if (reset) {
        _searching = true;
        _searchResults = [];
        _hasMoreSearch = true;
        _searchPage = 1;
        _activeQuery = trimmed;
      } else {
        _loadingMoreSearch = true;
      }
    });

    try {
      final result = await widget.api.search(
        query: trimmed,
        type: 'Communities',
        sort: 'TopAll',
        listingType: 'All',
        page: page,
        limit: _kPageLimit,
      );
      if (!mounted || _activeQuery != trimmed) return;

      final list = List<CommunityView>.from(result.communities);
      setState(() {
        if (reset) {
          _searchResults = list;
          _hasMoreSearch = list.length >= _kPageLimit;
        } else {
          final ids = _searchResults.map((c) => c.community.id).toSet();
          final unique =
              list.where((c) => ids.add(c.community.id)).toList(growable: false);
          _searchResults.addAll(unique);
          _hasMoreSearch = list.length >= _kPageLimit && unique.isNotEmpty;
        }
        _searchIndexMap = _indexOf(_searchResults);
        _searching = false;
        _loadingMoreSearch = false;
        _searchPage = page + 1;
      });
      _loadMoreArmed = true;
    } catch (e) {
      if (!mounted || _activeQuery != trimmed) return;
      setState(() {
        _searching = false;
        _loadingMoreSearch = false;
      });
      _loadMoreArmed = true;
      if (reset && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: ${formatCreatePostError(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Full height under status bar (user expectation for community picker).
    final sheetMaxHeight =
        MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).top;
    final query = _searchCtrl.text.toLowerCase().trim();
    final isSearching = query.isNotEmpty;
    final showSearchSkeleton = isSearching &&
        (query != _activeQuery.toLowerCase() || _searching);
    final displayList = !isSearching
        ? _subscribed
        : (showSearchSkeleton ? const <CommunityView>[] : _searchResults);
    final showListSkeleton = (!isSearching &&
            _loadingSubscribed &&
            displayList.isEmpty) ||
        showSearchSkeleton;
    final isLoadingMore =
        !isSearching ? _loadingMoreSubscribed : _loadingMoreSearch;
    final selectedId = widget.selected?.community.id;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: sheetMaxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Select Community',
                style: TextStyle(
                  fontSize: _fontTitle,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search communities...',
                hintStyle: const TextStyle(
                  fontSize: _fontBody,
                  color: _kHint,
                ),
                prefixIcon: const Icon(
                  MingCuteIcons.mgc_search_2_line,
                  size: 18,
                  color: _kTextSecondary,
                ),
                filled: true,
                fillColor: _kSurfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(
                fontSize: _fontBody,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (!isSearching)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4, top: 4),
                child: Text(
                  _subscribed.isEmpty
                      ? 'Your communities'
                      : 'Your communities (${_subscribed.length})',
                  style: const TextStyle(
                    fontSize: _fontMeta,
                    fontWeight: FontWeight.w600,
                    color: _kTextSecondary,
                  ),
                ),
              ),
            if (isSearching)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4, top: 4),
                child: Text(
                  showSearchSkeleton ? 'Searching…' : 'Search results',
                  style: const TextStyle(
                    fontSize: _fontMeta,
                    fontWeight: FontWeight.w600,
                    color: _kTextSecondary,
                  ),
                ),
              ),
            Expanded(
              child: showListSkeleton
                  ? _buildSkeleton()
                  : displayList.isEmpty
                      ? _buildEmpty(
                          isSearching: isSearching,
                          error: !isSearching ? _subscribedError : null,
                          onRetry: () => _loadSubscribed(reset: true),
                        )
                      : ListView.builder(
                          controller: _scrollCtrl,
                          itemExtent: _kRowExtent,
                          // Tight recycle window — same idea as secondary lists.
                          cacheExtent: 240,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: true,
                          itemCount:
                              displayList.length + (isLoadingMore ? 1 : 0),
                          findChildIndexCallback: (Key key) {
                            if (key is! ValueKey<int>) return null;
                            final map = isSearching
                                ? _searchIndexMap
                                : _subscribedIndexMap;
                            return map?.indexForKeyValue(key.value);
                          },
                          itemBuilder: (context, idx) {
                            if (idx >= displayList.length) {
                              return const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _kTextPrimary,
                                  ),
                                ),
                              );
                            }
                            final c = displayList[idx];
                            return KeyedSubtree(
                              key: ValueKey<int>(c.community.id),
                              child: RepaintBoundary(
                                child: _CommunityRow(
                                  view: c,
                                  selected: selectedId == c.community.id,
                                  onTap: () => Navigator.of(context).pop(c),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton({int count = 8}) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemExtent: _kRowExtent,
      itemCount: count,
      itemBuilder: (_, _) => const _CommunityRowSkeleton(),
    );
  }

  Widget _buildEmpty({
    required bool isSearching,
    String? error,
    required VoidCallback onRetry,
  }) {
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: _fontBody,
                  color: _kTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Text(
        isSearching
            ? 'No communities found.\nTry a different search.'
            : 'No joined communities yet.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: _fontBody,
          color: _kTextSecondary,
        ),
      ),
    );
  }
}

class _CommunityRow extends StatelessWidget {
  const _CommunityRow({
    required this.view,
    required this.selected,
    required this.onTap,
  });

  final CommunityView view;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final community = view.community;
    final hasIcon = community.icon != null && community.icon!.isNotEmpty;
    final title =
        community.title.isNotEmpty ? community.title : community.name;
    final subs = view.counts.subscribers;
    final subtitle = subs > 0
        ? 'c/${community.name} • $subs subscribers'
        : 'c/${community.name}';

    return Material(
      color: selected ? _kSurfaceMuted : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              NetworkAvatar.forList(
                size: 36,
                imageUrl: hasIcon ? community.icon : null,
                name: title,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: _fontBody,
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: _fontMeta,
                        color: _kTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  MingCuteIcons.mgc_check_line,
                  size: 18,
                  color: _kTextPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityRowSkeleton extends StatelessWidget {
  const _CommunityRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          ShimmerPlaceholder(width: 36, height: 36, borderRadius: 18),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerPlaceholder(width: 140, height: 12, borderRadius: 4),
                SizedBox(height: 6),
                ShimmerPlaceholder(width: 100, height: 10, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
