# Post Detail Smooth Scroll Architecture

| Field | Value |
|-------|-------|
| **Document** | Post Detail absolute-performance restructure |
| **Date** | 2026-07-25 |
| **Status** | Waves 0–7 implemented (2026-07-25) |
| **Surface** | `PostDetailScreen` + comment list |
| **Sibling** | `docs/home-feed-smooth-scroll-architecture.md` |

---

## Vietnamese summary

Màn bài chi tiết đã có nhiều tối ưu (body VM, vote per-id, scroll-gate media/ad, keep-alive budget, idle load-more) nhưng vẫn monolith ~4.6k dòng, list variable-height, markdown trên row rich, collapse qua parent `setState`. Roadmap: **6 plane** (shell · data · list · row · media · ads/interaction), ship wave nhỏ **có đo**, **không** đập markdown app-wide — dùng 3-tier body (plain / linksOnly / fullRich).

---

## Goals

1. Stable **60 fps** continuous fling on mid-range Android (90 stretch).
2. Reverse fling without blank-gray rows; media paints on idle.
3. Vote / collapse / swipe-parent without hitching the full list tree.
4. Links stay blue + tappable without full `MarkdownBody` cost on URL-only comments.
5. Incremental PRs; each plane changeable without reopening the monolith.

## Non-goals

- Rewrite markdown engine from scratch.
- Perfect zero hitch with dense native ads + media + fullRich on low-end.
- Big-bang single-PR rewrite of `post_detail_screen.dart`.

---

## Planes (target)

0. **Shell** — route, AppBar, Scaffold, comment bar only  
1. **Data** — `CommentThreadController`, entities, collapse, flat + display entries, VMs  
2. **List** — virtualization, extents, O(1) index maps, scroll phase, idle pagination  
3. **Row** — per-id `CommentRowTile` (home-feed tile pattern)  
4. **Media** — aspect in data plane, `ScrollStableNetworkImage`, decode budget  
5. **Ads / interaction** — existing ad path; swipe/collapse/vote isolated  

### Body paint tiers

| Tier | When | Widget |
|------|------|--------|
| plain | No markup | `Text` |
| linksOnly | URL / markdown links only | Precomputed `Text.rich` spans |
| fullRich | Bold, code, spoiler, lists… | `BluerumMarkdown` |

---

## Waves

| Wave | Work | Status |
|------|------|--------|
| 0 | Metrics protocol + this doc | **Done** |
| 1 | O(1) index maps + flattener extract | **Done** (full file split deferred) |
| 2 | Collapse via `_listRevision` (list-only rebuild) | **Done** |
| 3 | Body paint tiers plain / linksOnly / fullRich | **Done** |
| 4 | Height estimates + scroll jump math (`comment_list_extents.dart`) | **Done** — **no** forced `itemExtentBuilder` (clips variable rows) |
| 5 | Shared `mediaAspectCache` + header height measure | **Done** |
| 6 | Keep-alive 72 / cacheExtent 1600 / image cache 450·160MB | **Done** |
| 7 | Riverpod `CommentThreadController` SSOT + `CustomScrollView` sliver header | **Done** |
| — | Full split of 4k-line screen widgets into many files | Optional refactor (not FPS) |

---

## PR0 — Metrics baseline protocol

**Before claiming any wave “done”, capture:**

| Field | Record |
|-------|--------|
| Device | model, Android version, Impeller on/off |
| Build | profile mode (not debug) |
| Thread | ~50 / ~200 / ~500 comments; media density; ads on/off |
| Gesture | 5s fling down; 5s reverse; collapse deep branch; vote one row |
| Tools | Flutter DevTools Performance; optional `FrameTiming` overlay |
| Numbers | worst frame ms; jank frames/s; build/layout sample |

**Compare** same protocol after each wave. No absolute-FPS claim without PR0 + after numbers.

### Manual checklist (QA)

- [ ] Open long post detail cold  
- [ ] Fling through media + ad slots  
- [ ] Reverse fling (no blank gray)  
- [ ] Tap link (blue + opens)  
- [ ] Collapse parent with many children  
- [ ] Swipe right → parent sheet  
- [ ] Vote without visible list hitch  
- [ ] Load more at bottom after fling ends  

---

## Keep (already correct)

- `CommentBodyVm` + store  
- `PostDetailVoteStore`  
- Local scroll phase (not home global)  
- Idle load-more / idle precache  
- `ScrollStableNetworkImage` + decode budget  
- First still + `+N` (no nested list carousel)  
- Static thread painters  
- Ad fixed height + far-dispose  
- Budgeted keep-alive policy object  
- Page cache + generation  

## Debt to remove

- Monolith ownership of tree + list  
- Collapse full DFS + parent `setState`  
- Full markdown on every `needsRich` row  
- Linear `findChildIndex` with ads  
- Media aspect only in render plane  
- No formal extent / height estimate for virtualization  

---

## Implementation notes

See session plan: post-detail absolute performance restructure.  
Start extract at Wave 1 after O(1) maps; do not start with markdown rewrite or keep-alive deletion.

## Secondary comment lists (not full thread kit)

Profile comments + Search comments + Notifications use a **minimal** subset (2026-08-01, search stills 2026-08-03, inbox stills 2026-08-03):

- Profile: `CommentBodyVm` + `CommentBodyPaint` (fullRich → plain preview in list); fixed still thumb (no `CommentMediaWidget` / video play); O(1) index; idle load-more + still precache.
- Search: same body VM tiers + fixed still thumb (`CommentListStillThumb`); O(1) index; idle load-more + still precache.
- Notifications: same body VM tiers + still thumb; idle load-more + still precache; max 3 plain lines.

Do **not** port thread flatten / collapse / ads / keep-alive 72 / detail image boost / carousel autoplay to those surfaces.
