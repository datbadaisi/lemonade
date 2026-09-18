# Post-list surface architecture (absolute fling perf)

Shared kit for **every** post-card list: Home, Community, Profile posts, Search (All + Posts), Saved.

Parity with post-detail + home-feed portable wins — dials vary by surface weight.

## Kit location

`lib/shared/widgets/post_list/`

| File | Role |
|------|------|
| `post_list_memory.dart` | Height probe + optional budgeted keep-alive |
| `post_list_index.dart` | O(1) findChildIndex maps |
| `post_list_vm_cache.dart` | Markdown/media once per body identity |
| `post_list_store.dart` | Local byId + order SSOT per surface |
| `optimized_post_list_tile.dart` | `feedOptimized` + VM + overlay select |
| `surface_post_interactions.dart` | Vote/save without requiring home feed map |
| `post_list_idle_precache.dart` | Idle-only media warm |

Home re-exports memory via `feed_list_memory.dart` typedefs.

## 6-plane contract

1. **Shell** — NestedScroll morph stays local; posts sliver not driven by vote setState.
2. **Data** — `SurfacePostStore` (or home Riverpod SSOT); global vote/save **overlays**.
3. **List** — cacheExtent 480–600, **pure virtualization** (`maxKeptRows: 0`, `addAutomaticKeepAlives: false`), O(1) index, idle + debounced load-more.
4. **Row** — `OptimizedPostListTile` / `HomeFeedTile` (`feedOptimized: true`).
5. **Media** — ScrollStable + feed decode tier; precache **only** when scroll phase is `idle`.
6. **Ads** — home only (kit supports posts-only elsewhere).

## Surface dials (standard — Home parity)

| Surface | maxKeptRows | aAK | cacheExtent | scroll phase | load-more |
|---------|-------------|-----|-------------|--------------|-----------|
| Home | **0** | false | 480 | global `feedScrollPhaseListenable` | idle + 180ms debounce |
| Community | **0** | false | 480 | local | idle + 180ms debounce |
| Profile posts | **0** | false | 480 | local | idle + 180ms debounce |
| Search Posts | **0** | false | 480 | local | idle + 180ms debounce |
| Search All | **0** | false | 600 | local | n/a (page-1) |
| Saved | **0** | false | 600 | local | idle + 180ms debounce |

`maxKeptRows > 0` is **optional** only if reverse-fling is critical (6–8 max). Do **not** use 16–24 — OOM risk with full media cards.

### Height vs keep-alive

| Policy | Wrapper |
|--------|---------|
| `maxKeptRows == 0` | `PostListHeightProbe` (measure only) |
| `maxKeptRows > 0` | `PostListKeepAlive` + `addAutomaticKeepAlives: true` |

## Vote isolation

- **Never** `setState` parent list on vote.
- Optimistic overlay → tile `select(postId)` rebuild only.
- Surface store `upsertSilent` on success (base stays consistent without notify).
- Saved unsave may remove row via store `notifyListeners` — intentional.

## Non-goals

- ImageCache boost 450/160 (detail-only).
- Forced `itemExtent` (variable card heights).
- Ads on community/search/profile/saved unless product asks.
- Fling proxy rows (retired from Home; blank flash).

## Status (2026-08-01)

| Surface | Status |
|---------|--------|
| Home | Done — pure virtualize, idle precache, debounced load-more |
| Community | Done — Home dials + kit |
| Profile posts | Done — Home dials + kit |
| Profile comments | Minimal kit: `CommentBodyVm` + paint tiers / plain preview, fixed still thumb (no video play), O(1) index, idle load-more + still precache |
| Search All / Posts | Done — Home dials + silent base upsert |
| Search comments | Minimal kit: `CommentBodyVm` + paint tiers / plain preview, fixed still thumb (no video play), O(1) index, idle load-more + still precache |
| Notifications (replies/mentions) | Minimal kit: `CommentBodyVm` + paint tiers / plain preview, fixed still thumb (no video play), idle load-more + still precache |
| Saved | Done — Home dials + kit |
| Shared kit + tests | Done |

### Comment rows (what they are)

**Not** `PostCard` post tiles. They are list rows for **comments** (Profile → Comments tab, Search → Comments / All, Notifications). Full PostCard kit does not apply.

| Surface | Body | Index | Notes |
|---------|------|-------|-------|
| Post Detail | full 3-tier + thread | O(1) | gold standard |
| Profile comments | VM + plain/linksOnly; fullRich → plain preview max 4 lines; fixed-height still thumb (feed decode, poster-only) | O(1) | tap → post detail |
| Search comments | VM + plain/linksOnly; fullRich → plain preview max 4 lines; fixed-height still thumb (feed decode, poster-only) | O(1) | same secondary kit as profile comments |
| Notifications | VM + plain/linksOnly; fullRich → plain preview max 3 lines; fixed-height still thumb | keys | tap → post detail thread |
