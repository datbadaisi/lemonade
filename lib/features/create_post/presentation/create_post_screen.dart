import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/media_upload_policy.dart';
import 'package:bluerum/features/create_post/domain/create_post_helpers.dart';
import 'package:bluerum/features/create_post/presentation/community_picker_sheet.dart';
import 'package:bluerum/features/post/data/post_repository_impl.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/models/site.dart';
import 'package:bluerum/shared/widgets/auth/login_required_scaffold.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/compose/media_attach_list.dart';
import 'package:bluerum/shared/widgets/compose/media_attach_sheet.dart';
import 'package:bluerum/shared/widgets/markdown/markdown_link_text_controller.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/media/upload_item.dart';

// Compose design system (mirror feed / search / notif / profile)
// Spacing: 4 · 8 · 12 · 16
// Type: 10 label · 12 meta · 13 body · 16 title / app-bar action
// Color: #000 primary · #525252 meta · #E8E8E8 surface · #E0E0E0 border
const double _spaceXs = 4;
const double _spaceSm = 8;
const double _spaceMd = 12;
const double _spaceLg = 16;

const double _fontLabel = 10;
const double _fontMeta = 12;
const double _fontBody = 13;
const double _fontTitle = 16;

const Color _kTextPrimary = Color(0xFF000000);
const Color _kTextSecondary = Color(0xFF525252);
const Color _kSurfaceMuted = Color(0xFFE8E8E8);
const Color _kBorder = Color(0xFFE0E0E0);
/// Hint: #525252 @ ~40%
const Color _kHint = Color(0x66525252);

class CreatePostScreen extends ConsumerStatefulWidget {
  final CommunityView? initialCommunity;

  /// When set, the screen edits this post instead of creating a new one.
  final PostView? editingPost;

  /// When set, prefill title/body/url/nsfw from this post to create a cross-post
  /// (POST `/post` with the same URL so Lemmy groups them as `cross_posts`).
  final PostView? crossPostFrom;

  const CreatePostScreen({
    super.key,
    this.initialCommunity,
    this.editingPost,
    this.crossPostFrom,
  });

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  LemmyApiService get _api => ref.read(lemmyApiClientProvider);
  final TextEditingController _titleCtrl = TextEditingController();
  final MarkdownLinkTextController _bodyCtrl = MarkdownLinkTextController();
  final TextEditingController _urlCtrl = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _bodyFocus = FocusNode();
  final FocusNode _urlFocus = FocusNode();

  bool _isPosting = false;
  bool _isNsfw = false;
  bool _showUrlField = false;

  CommunityView? _selectedCommunity;
  Timer? _autosaveDebounce;

  final MediaAttachList _media = MediaAttachList();

  List<PersonView> _mentionSuggestions = [];
  bool _isLoadingMentions = false;
  String? _activeMentionQuery;
  int? _activeMentionAtIndex;
  Timer? _mentionDebounce;

  bool _canPop = false;
  bool _draftRestoredSnackShown = false;

  /// Draft community fields kept until subscribed list is ready to merge.
  int? _pendingDraftCommunityId;
  String? _pendingDraftCommunityName;
  String? _pendingDraftCommunityTitle;
  String? _pendingDraftCommunityIcon;

  bool get _isEditing => widget.editingPost != null;

  bool get _isCrossPosting => widget.crossPostFrom != null;

  @override
  void initState() {
    super.initState();
    _bodyCtrl.addListener(_onBodyChanged);
    _titleCtrl.addListener(_onFormChanged);
    _urlCtrl.addListener(_onFormChanged);

    if (widget.editingPost != null) {
      _prefillFromEditingPost(widget.editingPost!);
    } else if (widget.crossPostFrom != null) {
      _prefillFromCrossPost(widget.crossPostFrom!);
    } else if (widget.initialCommunity != null) {
      _selectedCommunity = widget.initialCommunity;
    }

    if (!_isEditing && ref.read(authRepositoryProvider).isLoggedIn) {
      // Cross-post is prefilled from the source post — don't clobber with draft.
      if (!_isCrossPosting) {
        _loadDraft();
      }
      // Quiet warm for draft community upgrade (no sheet / no setState storm).
      unawaited(_warmDraftCommunity());
      // Prefetch subscribed list so first community-sheet open is cache-hit.
      unawaited(warmCommunityPickerCache(_api));
    }

    // Auto-focus title after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _titleFocus.requestFocus();
    });
  }

  void _prefillFromEditingPost(PostView postView) {
    final post = postView.post;
    _titleCtrl.text = post.name;

    // Mirror create UX: text in editor, media embeds in the tray — not raw
    // `![image](url)` markdown.
    final split = splitPostBodyForEdit(post.body);
    if (split.text.isNotEmpty) {
      _bodyCtrl.setRawText(split.text);
    }
    for (final m in split.media) {
      _media.add(UploadItem.remote(url: m.url, isVideo: m.isVideo));
    }

    if (post.url != null && post.url!.isNotEmpty) {
      _urlCtrl.text = post.url!;
      _showUrlField = true;
    }
    _isNsfw = post.nsfw;
    _selectedCommunity = CommunityView(
      community: postView.community,
      subscribed: postView.subscribed,
      counts: CommunityAggregates(communityId: postView.community.id),
    );
  }

  /// Prefill create form for a cross-post (new community, same link/content).
  ///
  /// Community is intentionally left empty so the user picks where to post.
  /// URL uses the original link (or `ap_id`) so Lemmy returns it in
  /// `GetPostResponse.cross_posts`.
  void _prefillFromCrossPost(PostView postView) {
    final post = postView.post;
    _titleCtrl.text = post.name;

    final split = splitPostBodyForEdit(post.body);
    if (split.text.isNotEmpty) {
      _bodyCtrl.setRawText(split.text);
    }
    for (final m in split.media) {
      _media.add(UploadItem.remote(url: m.url, isVideo: m.isVideo));
    }

    final url = crossPostUrl(url: post.url, apId: post.apId);
    if (url.isNotEmpty) {
      _urlCtrl.text = url;
      _showUrlField = true;
    }
    _isNsfw = post.nsfw;
  }

  @override
  void dispose() {
    _bodyCtrl.removeListener(_onBodyChanged);
    _titleCtrl.removeListener(_onFormChanged);
    _urlCtrl.removeListener(_onFormChanged);
    _autosaveDebounce?.cancel();
    _mentionDebounce?.cancel();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _urlCtrl.dispose();
    _titleFocus.dispose();
    _bodyFocus.dispose();
    _urlFocus.dispose();
    _media.dispose();
    // Drop leftover decode/paint queues so the underlay is not fighting pop.
    recoverMediaBudgets(notify: false, abandonInFlight: false);
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
    _scheduleAutosave();
  }

  void _onBodyChanged() {
    setState(() {});
    _scheduleAutosave();
    _handleMentionQuery();
  }

  void _scheduleAutosave() {
    if (_isEditing || _isCrossPosting) return;
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(const Duration(milliseconds: 800), () {
      if (!mounted || _isPosting) return;
      final title = _titleCtrl.text.trim();
      final body = _bodyCtrl.text.trim();
      final url = _urlCtrl.text.trim();
      if (title.isEmpty && body.isEmpty && url.isEmpty && !_isNsfw) return;
      _saveDraft();
    });
  }

  /// Quietly resolve draft community against subscribed list (no UI rebuild storm).
  Future<void> _warmDraftCommunity() async {
    final id = _pendingDraftCommunityId;
    if (id == null) return;
    try {
      final list = await loadSubscribedCommunitiesQuiet(_api);
      if (!mounted) return;
      CommunityView? match;
      for (final c in list) {
        if (c.community.id == id) {
          match = c;
          break;
        }
      }
      if (match == null) return;
      setState(() {
        _selectedCommunity = match;
        _pendingDraftCommunityId = null;
        _pendingDraftCommunityName = null;
        _pendingDraftCommunityTitle = null;
        _pendingDraftCommunityIcon = null;
      });
    } catch (_) {}
  }

  static const _draftTitleKey = 'post_draft_title';
  static const _draftBodyKey = 'post_draft_body';
  static const _draftUrlKey = 'post_draft_url';
  static const _draftCommunityIdKey = 'post_draft_community_id';
  static const _draftCommunityNameKey = 'post_draft_community_name';
  static const _draftCommunityTitleKey = 'post_draft_community_title';
  static const _draftCommunityIconKey = 'post_draft_community_icon';
  static const _draftNsfwKey = 'post_draft_nsfw';

  Future<void> _loadDraft() async {
    // Prefer explicit initial community from navigation over draft.
    if (widget.initialCommunity != null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final title = prefs.getString(_draftTitleKey) ?? '';
      final body = prefs.getString(_draftBodyKey) ?? '';
      final url = prefs.getString(_draftUrlKey) ?? '';
      final communityId = prefs.getInt(_draftCommunityIdKey);
      final communityName = prefs.getString(_draftCommunityNameKey);
      final communityTitle = prefs.getString(_draftCommunityTitleKey);
      final communityIcon = prefs.getString(_draftCommunityIconKey);
      final nsfw = prefs.getBool(_draftNsfwKey) ?? false;

      final hasDraft =
          title.isNotEmpty ||
          body.isNotEmpty ||
          url.isNotEmpty ||
          communityId != null ||
          nsfw;
      if (!hasDraft || !mounted) return;

      setState(() {
        if (title.isNotEmpty) _titleCtrl.text = title;
        if (body.isNotEmpty) {
          _bodyCtrl.setRawText(body);
        }
        if (url.isNotEmpty) {
          _urlCtrl.text = url;
          _showUrlField = true;
        }
        _isNsfw = nsfw;
        if (communityId != null && _selectedCommunity == null) {
          _pendingDraftCommunityId = communityId;
          _pendingDraftCommunityName = communityName;
          _pendingDraftCommunityTitle = communityTitle;
          _pendingDraftCommunityIcon = communityIcon;
          // Immediate stub so UI shows the draft community even before list loads.
          _selectedCommunity = _communityStub(
            id: communityId,
            name: communityName ?? 'community',
            title: communityTitle ?? communityName ?? 'Community',
            icon: communityIcon,
          );
        }
      });

      if (!_draftRestoredSnackShown && mounted) {
        _draftRestoredSnackShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft restored'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  CommunityView _communityStub({
    required int id,
    required String name,
    required String title,
    String? icon,
  }) {
    return CommunityView(
      community: Community(id: id, name: name, title: title, icon: icon),
      subscribed: 'Subscribed',
      counts: CommunityAggregates(communityId: id),
    );
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftTitleKey, _titleCtrl.text);
      await prefs.setString(_draftBodyKey, _bodyCtrl.rawText);
      await prefs.setString(_draftUrlKey, _urlCtrl.text);
      await prefs.setBool(_draftNsfwKey, _isNsfw);
      if (_selectedCommunity != null) {
        final c = _selectedCommunity!.community;
        await prefs.setInt(_draftCommunityIdKey, c.id);
        await prefs.setString(_draftCommunityNameKey, c.name);
        await prefs.setString(_draftCommunityTitleKey, c.title);
        if (c.icon != null && c.icon!.isNotEmpty) {
          await prefs.setString(_draftCommunityIconKey, c.icon!);
        } else {
          await prefs.remove(_draftCommunityIconKey);
        }
      } else {
        await prefs.remove(_draftCommunityIdKey);
        await prefs.remove(_draftCommunityNameKey);
        await prefs.remove(_draftCommunityTitleKey);
        await prefs.remove(_draftCommunityIconKey);
      }
    } catch (_) {}
  }

  Future<void> _deleteDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftTitleKey);
      await prefs.remove(_draftBodyKey);
      await prefs.remove(_draftUrlKey);
      await prefs.remove(_draftCommunityIdKey);
      await prefs.remove(_draftCommunityNameKey);
      await prefs.remove(_draftCommunityTitleKey);
      await prefs.remove(_draftCommunityIconKey);
      await prefs.remove(_draftNsfwKey);
    } catch (_) {}
  }

  /// Sync check — used so Cancel can leave without an async microtask gap.
  bool _isEmptyCreateForm() {
    if (_isEditing || _isCrossPosting) return false;
    return _titleCtrl.text.trim().isEmpty &&
        _bodyCtrl.text.trim().isEmpty &&
        _urlCtrl.text.trim().isEmpty &&
        !_isNsfw &&
        _media.isEmpty;
  }

  Future<bool> _onBackButtonPressed() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    final url = _urlCtrl.text.trim();

    if (_isEditing) {
      final original = widget.editingPost!.post;
      final originalSplit = splitPostBodyForEdit(original.body);
      // Compare raw markdown (not display text) so links match split body.
      final bodyRaw = _bodyCtrl.rawText.trim();
      final unchanged =
          title == original.name.trim() &&
          bodyRaw == originalSplit.text.trim() &&
          url == (original.url ?? '').trim() &&
          _isNsfw == original.nsfw &&
          sameUploadUrls(_media.items, originalSplit.media);
      if (unchanged) return true;

      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Discard edits?',
            style: TextStyle(
              fontSize: _fontTitle,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          content: const Text(
            'Your changes will be lost if you leave without saving.',
            style: TextStyle(fontSize: _fontBody, color: _kTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Keep editing',
                style: TextStyle(
                  color: _kTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Discard',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return discard == true;
    }

    // Cross-post: leave without touching the normal create-post draft.
    if (_isCrossPosting) {
      final source = widget.crossPostFrom!.post;
      final sourceSplit = splitPostBodyForEdit(source.body);
      final expectedUrl = crossPostUrl(url: source.url, apId: source.apId);
      final bodyRaw = _bodyCtrl.rawText.trim();
      final unchanged =
          title == source.name.trim() &&
          bodyRaw == sourceSplit.text.trim() &&
          url == expectedUrl &&
          _isNsfw == source.nsfw &&
          _selectedCommunity == null &&
          sameUploadUrls(_media.items, sourceSplit.media);
      if (unchanged) return true;

      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Discard cross-post?',
            style: TextStyle(
              fontSize: _fontTitle,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          content: const Text(
            'Your changes will be lost if you leave without posting.',
            style: TextStyle(fontSize: _fontBody, color: _kTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Keep editing',
                style: TextStyle(
                  color: _kTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Discard',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return discard == true;
    }

    if (_isEmptyCreateForm() ||
        (title.isEmpty && body.isEmpty && url.isEmpty && !_isNsfw)) {
      unawaited(_deleteDraft());
      return true;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Save draft?',
          style: TextStyle(
            fontSize: _fontTitle,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        content: const Text(
          'You can save this post as a draft to finish it later.',
          style: TextStyle(fontSize: _fontBody, color: _kTextSecondary),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text(
              'Discard',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('save'),
            style: TextButton.styleFrom(
              foregroundColor: _kTextPrimary,
            ),
            child: const Text(
              'Save Draft',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('keep'),
            style: TextButton.styleFrom(foregroundColor: _kTextSecondary),
            child: const Text(
              'Keep Editing',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    if (result == 'discard') {
      unawaited(_deleteDraft());
      return true;
    } else if (result == 'save') {
      unawaited(_saveDraft());
      return true;
    }

    return false;
  }

  Widget _buildLetterAvatar(String title, double size) {
    final initial = title.trim().isNotEmpty
        ? title.trim()[0].toUpperCase()
        : '?';
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
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _showCommunitySelector() async {
    _titleFocus.unfocus();
    _bodyFocus.unfocus();
    _urlFocus.unfocus();
    final picked = await showCommunityPickerSheet(
      context: context,
      api: _api,
      selected: _selectedCommunity,
    );
    // Sheet already released picker media pressure; one post-frame idle so
    // Cancel right after dismiss is not on the same frames as sheet teardown.
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedCommunity = picked);
      _scheduleAutosave();
    }
  }

  Future<void> _uploadSingleItem(UploadItem item) async {
    if (item.isRemote) return;

    final name = item.file.name;
    item.isUploading = true;
    item.error = null;
    _media.markChanged();

    try {
      final bytes =
          (item.isVideo ? null : item.bytes) ?? await item.file.readAsBytes();
      final url = await ref
          .read(postRepositoryProvider)
          .uploadImage(
            bytes,
            name,
            mimeType: MediaUploadPolicy.mimeType(item.file),
            onCancelReady: item.attachCancellation,
          );
      if (item.isCancelled) return;
      item.url = url;
      item.isUploading = false;
      item.error = null;
    } catch (e) {
      item.isUploading = false;
      item.error = formatCreatePostError(e);
    } finally {
      _media.markChanged();
    }
  }

  Future<void> _handleKeyboardGif(KeyboardInsertedContent content) async {
    final data = content.data;
    if (data == null || data.isEmpty) return;
    if (!content.mimeType.startsWith('image/')) return;
    if (_media.length >= MediaUploadPolicy.maxItems) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can attach up to 10 media items')),
        );
      }
      return;
    }
    if (data.length > MediaUploadPolicy.maxImageBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keyboard image exceeds the 15 MB limit'),
          ),
        );
      }
      return;
    }

    final ext = content.mimeType.contains('gif') ? 'gif' : 'png';
    final fileName = 'keyboard_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final file = XFile.fromData(
      data,
      name: fileName,
      mimeType: content.mimeType,
    );
    final item = UploadItem(file: file, bytes: data);
    _media.add(item);
    await _uploadSingleItem(item);
  }

  void _showImageManagerBottomSheet() {
    _titleFocus.unfocus();
    _bodyFocus.unfocus();
    _urlFocus.unfocus();
    unawaited(
      showMediaAttachSheet(
        context: context,
        list: _media,
        uploadItem: _uploadSingleItem,
        formatError: formatCreatePostError,
      ),
    );
  }

  Future<void> _showLinkBottomSheet() async {
    // Same shared flow as comment compose: capture selection first, then sheet.
    final changed = await showMarkdownLinkBottomSheet(
      context: context,
      controller: _bodyCtrl,
      bodyFocus: _bodyFocus,
    );
    if (changed && mounted) setState(() {});
  }

  // ── Mentions (same behavior as comment compose) ──────────────────────────

  void _handleMentionQuery() {
    final text = _bodyCtrl.text;
    final selection = _bodyCtrl.selection;
    if (!selection.isValid || selection.start != selection.end) {
      _cancelMention();
      return;
    }
    final cursorPos = selection.start;
    if (cursorPos == 0) {
      _cancelMention();
      return;
    }

    var atIndex = -1;
    for (var i = cursorPos - 1; i >= 0; i--) {
      final char = text[i];
      if (char == ' ' || char == '\n') break;
      if (char == '@') {
        atIndex = i;
        break;
      }
    }

    if (atIndex == -1) {
      _cancelMention();
      return;
    }

    if (atIndex > 0) {
      final charBefore = text[atIndex - 1];
      if (charBefore != ' ' && charBefore != '\n') {
        _cancelMention();
        return;
      }
    }

    final query = text.substring(atIndex + 1, cursorPos);
    _activeMentionQuery = query;
    _activeMentionAtIndex = atIndex;

    if (query.isEmpty) {
      setState(() {
        _mentionSuggestions = [];
        _isLoadingMentions = false;
      });
      return;
    }

    _mentionDebounce?.cancel();
    _mentionDebounce = Timer(const Duration(milliseconds: 300), () {
      _fetchMentionSuggestions(query);
    });
  }

  void _cancelMention() {
    _mentionDebounce?.cancel();
    if (_activeMentionQuery != null || _mentionSuggestions.isNotEmpty) {
      setState(() {
        _activeMentionQuery = null;
        _activeMentionAtIndex = null;
        _mentionSuggestions = [];
        _isLoadingMentions = false;
      });
    }
  }

  Future<void> _fetchMentionSuggestions(String query) async {
    setState(() => _isLoadingMentions = true);
    try {
      final results = await _api.searchUsers(query: query, limit: 10);
      if (mounted && _activeMentionQuery == query) {
        setState(() {
          _mentionSuggestions = results;
          _isLoadingMentions = false;
        });
      }
    } catch (_) {
      if (mounted && _activeMentionQuery == query) {
        setState(() => _isLoadingMentions = false);
      }
    }
  }

  void _applyMention(PersonView personView) {
    if (_activeMentionAtIndex == null) return;

    final person = personView.person;
    final username = person.name;
    final domain = person.actorId.isNotEmpty
        ? (Uri.tryParse(person.actorId)?.host ?? '')
        : '';
    final mentionText = '@$username${domain.isNotEmpty ? '@$domain' : ''} ';

    final text = _bodyCtrl.text;
    final selection = _bodyCtrl.selection;
    if (!selection.isValid) return;

    final start = _activeMentionAtIndex!;
    final end = selection.start;
    final newText = text.replaceRange(start, end, mentionText);

    _bodyCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + mentionText.length),
    );

    setState(() {
      _activeMentionQuery = null;
      _activeMentionAtIndex = null;
      _mentionSuggestions = [];
    });
  }

  Widget _buildMentionSuggestions() {
    if (_activeMentionQuery == null) return const SizedBox.shrink();
    if (_mentionSuggestions.isEmpty && !_isLoadingMentions) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoadingMentions)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(_kTextPrimary),
            ),
          if (_mentionSuggestions.isNotEmpty)
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _mentionSuggestions.length,
                itemBuilder: (context, index) {
                  final personView = _mentionSuggestions[index];
                  final person = personView.person;
                  final displayName = person.displayNameOrName;
                  final username = person.name;
                  final domain = person.actorId.isNotEmpty
                      ? (Uri.tryParse(person.actorId)?.host ?? '')
                      : '';

                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: NetworkAvatar.forList(
                      size: 28,
                      imageUrl: person.avatar,
                      name: displayName,
                      fallbackIcon: MingCuteIcons.mgc_user_3_line,
                      backgroundColor: _kSurfaceMuted,
                      foregroundColor: _kTextSecondary,
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: _fontBody,
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '@$username${domain.isNotEmpty ? '@$domain' : ''}',
                      style: const TextStyle(
                        fontSize: _fontMeta,
                        color: _kTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _applyMention(personView),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!ref.read(authRepositoryProvider).isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Log in to edit this post' : 'Log in to create a post',
          ),
        ),
      );
      return;
    }
    final title = _titleCtrl.text.trim();
    if (!canCreatePost(
      title: title,
      hasCommunity: _selectedCommunity != null,
      isPosting: _isPosting,
      uploads: _media.items,
    )) {
      if (_media.items.any((u) => u.error != null) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fix or remove failed media before posting'),
            backgroundColor: AppColors.danger,
          ),
        );
      } else if (title.length > kPostTitleMaxLength && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Title must be at most $kPostTitleMaxLength characters',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    setState(() {
      _isPosting = true;
    });

    final bodyText = assemblePostBody(
      rawBody: _bodyCtrl.rawText,
      uploads: _media.items,
    );
    final postUrl = normalizePostUrl(_urlCtrl.text);

    try {
      final PostView postView;
      if (_isEditing) {
        // OpenAPI EditPost: required post_id; other fields optional (omit = unchanged).
        // Full-form edit always sends name/body/nsfw; body may be "" to clear text.
        // url only sent when non-empty (empty string is not a valid Url on many instances).
        postView = await ref
            .read(postRepositoryProvider)
            .editPost(
              postId: widget.editingPost!.post.id,
              name: title,
              body: bodyText,
              url: postUrl,
              nsfw: _isNsfw,
            );
      } else {
        postView = await ref
            .read(postRepositoryProvider)
            .createPost(
              name: title,
              communityId: _selectedCommunity!.community.id,
              body: bodyText.isNotEmpty ? bodyText : null,
              url: postUrl,
              nsfw: _isNsfw ? true : null,
            );
        _autosaveDebounce?.cancel();
        // Cross-post must not wipe the user's normal create-post draft.
        if (!_isCrossPosting) {
          await _deleteDraft();
        }
      }

      if (!mounted) return;
      // Avoid setState(_canPop)+pop races with PopScope / InheritedWidget
      // teardown (can trigger '_dependents.isEmpty' assertions).
      _canPop = true;
      if (context.mounted) {
        Navigator.of(context).pop(postView);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatCreatePostError(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return const LoginRequiredScaffold(title: 'Your post is waiting');
    }
    final bottom = MediaQuery.of(context).padding.bottom;
    // Media badge / Post enabled: ListenableBuilder on [_media] only — do not
    // full-screen setState on every upload tick (MediaAttachList earns its keep).
    final titleTooLong = _titleCtrl.text.trim().length > kPostTitleMaxLength;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Empty create form: leave immediately (no async/dialog microtask gap).
        // Heavy after community picker because cancel used to await a Future
        // while ImageCache was still holding picker avatars.
        if (_isEmptyCreateForm()) {
          unawaited(_deleteDraft());
          _canPop = true;
          if (context.mounted) Navigator.of(context).pop();
          return;
        }
        final shouldPop = await _onBackButtonPressed();
        if (shouldPop && mounted) {
          // Do not setState before pop — rebuild mid-pop tears down
          // InheritedElements while dependents are still attached.
          _canPop = true;
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          leadingWidth: 100,
          leading: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: TextButton(
                onPressed: _isPosting
                    ? null
                    : () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  foregroundColor: _kTextPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: _fontTitle, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          actions: [
            // Post-level URL (link post) — distinct from inline body links.
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: 'Post URL (optional)',
                child: Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showUrlField = !_showUrlField;
                      });
                      if (_showUrlField) {
                        _urlFocus.requestFocus();
                      } else {
                        _urlFocus.unfocus();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Icon(
                        _showUrlField
                            ? MingCuteIcons.mgc_globe_fill
                            : MingCuteIcons.mgc_globe_line,
                        color: _kTextPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Inline markdown link in body — same UX as comment compose.
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: 'Insert Link',
                child: Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: _showLinkBottomSheet,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Icon(
                        MingCuteIcons.mgc_link_2_line,
                        color: _kTextPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: 'Images & Media',
                child: Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: _showImageManagerBottomSheet,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListenableBuilder(
                        listenable: _media,
                        builder: (context, _) {
                          final successfulCount = _media.successfulCount;
                          final isAnyUploading = _media.isAnyUploading;
                          final hasAnyError = _media.hasAnyError;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                MingCuteIcons.mgc_photo_album_2_line,
                                color: _kTextPrimary,
                                size: 20,
                              ),
                              if (successfulCount > 0 ||
                                  isAnyUploading ||
                                  hasAnyError)
                                Positioned(
                                  right: -7,
                                  top: -6,
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        if (isAnyUploading)
                                          const Positioned.fill(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              color: _kTextPrimary,
                                            ),
                                          ),
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: hasAnyError
                                                ? AppColors.danger
                                                : _kTextPrimary,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$successfulCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w800,
                                              height: 1.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ListenableBuilder(
                  listenable: _media,
                  builder: (context, _) {
                    final canPost = canCreatePost(
                      title: _titleCtrl.text,
                      hasCommunity: _selectedCommunity != null,
                      isPosting: _isPosting,
                      uploads: _media.items,
                    );
                    return TextButton(
                      onPressed: canPost ? _submit : null,
                      style: TextButton.styleFrom(
                        foregroundColor: _kTextPrimary,
                        disabledForegroundColor: _kBorder,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kTextPrimary,
                              ),
                            )
                          : Text(
                              _isEditing ? 'Save' : 'Post',
                              style: const TextStyle(
                                fontSize: _fontTitle,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _isEditing ? null : _showCommunitySelector,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedCommunity != null) ...[
                            NetworkAvatar(
                              size: 20,
                              imageUrl:
                                  _selectedCommunity!.community.icon != null &&
                                      _selectedCommunity!
                                          .community
                                          .icon!
                                          .isNotEmpty
                                  ? _selectedCommunity!.community.icon
                                  : null,
                              name:
                                  _selectedCommunity!.community.title.isNotEmpty
                                  ? _selectedCommunity!.community.title
                                  : _selectedCommunity!.community.name,
                              fallback: _buildLetterAvatar(
                                _selectedCommunity!.community.title.isNotEmpty
                                    ? _selectedCommunity!.community.title
                                    : _selectedCommunity!.community.name,
                                20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _selectedCommunity!.community.title.isNotEmpty
                                    ? _selectedCommunity!.community.title
                                    : _selectedCommunity!.community.name,
                                style: const TextStyle(
                                  fontSize: _fontBody,
                                  fontWeight: FontWeight.w600,
                                  color: _kTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              MingCuteIcons.mgc_group_3_line,
                              size: 16,
                              color: _kTextPrimary,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Choose a community',
                              style: TextStyle(
                                fontSize: _fontBody,
                                fontWeight: FontWeight.w600,
                                color: _kTextPrimary,
                              ),
                            ),
                          ],
                          if (!_isEditing) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              MingCuteIcons.mgc_down_line,
                              size: 14,
                              color: _kTextPrimary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title field
                          TextField(
                            controller: _titleCtrl,
                            focusNode: _titleFocus,
                            maxLines: null,
                            maxLength: kPostTitleMaxLength,
                            style: TextStyle(
                              fontSize: _fontTitle,
                              fontWeight: FontWeight.w700,
                              color: titleTooLong
                                  ? AppColors.danger
                                  : _kTextPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'An interesting title',
                              hintStyle: TextStyle(
                                fontSize: _fontTitle,
                                fontWeight: FontWeight.w700,
                                color: _kHint,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              counterText: '',
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          if (titleTooLong)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Title is too long',
                                style: TextStyle(
                                  fontSize: _fontMeta,
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Optional post URL field (plain, matches title/body style)
                          if (_showUrlField) ...[
                            TextField(
                              controller: _urlCtrl,
                              focusNode: _urlFocus,
                              keyboardType: TextInputType.url,
                              decoration: const InputDecoration(
                                hintText: 'Link URL (optional)',
                                hintStyle: TextStyle(
                                  fontSize: _fontBody,
                                  color: _kHint,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontSize: _fontBody,
                                color: _kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Body editor only — media is managed via the app-bar sheet
                  // (same as comment compose; no inline preview strip).
                  // Expand body editor to remaining viewport so taps on empty
                  // space focus the field (not only the short placeholder box).
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: TextField(
                        controller: _bodyCtrl,
                        focusNode: _bodyFocus,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        scrollPadding: const EdgeInsets.only(bottom: 140.0),
                        textCapitalization: TextCapitalization.sentences,
                        contentInsertionConfiguration:
                            ContentInsertionConfiguration(
                              onContentInserted: _handleKeyboardGif,
                              allowedMimeTypes: const <String>[
                                'image/png',
                                'image/gif',
                                'image/jpeg',
                                'image/webp',
                                'image/*',
                              ],
                            ),
                        decoration: const InputDecoration(
                          hintText: 'Body text (optional)',
                          hintStyle: TextStyle(
                            fontSize: _fontBody,
                            color: _kHint,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: _fontBody,
                          color: _kTextPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildMentionSuggestions(),
            SizedBox(height: bottom > 0 ? bottom : 16),
          ],
        ),
      ),
    );
  }
}

