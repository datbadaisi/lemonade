import 'dart:async';
import 'dart:typed_data';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/markdown_utils.dart';
import 'package:bluerum/core/utils/media_upload_policy.dart';
import 'package:bluerum/features/comment/data/comment_repository_impl.dart';
import 'package:bluerum/features/comment/domain/comment_compose_helpers.dart';
import 'package:bluerum/features/comment/domain/submit_comment.dart';
import 'package:bluerum/features/create_post/domain/create_post_helpers.dart';
import 'package:bluerum/features/post/data/post_repository_impl.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/shared/models/site.dart';
import 'package:bluerum/shared/widgets/auth/login_required_scaffold.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/shared/widgets/compose/media_attach_list.dart';
import 'package:bluerum/shared/widgets/compose/media_attach_sheet.dart';
import 'package:bluerum/shared/widgets/markdown/markdown_link_text_controller.dart';
import 'package:bluerum/shared/widgets/media/upload_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Full-screen comment compose page (Reddit-style).
///
/// Shows post context and a large text area. Pops with the created
/// [CommentView] on success so the caller can insert it at the top.
class CommentComposeScreen extends ConsumerStatefulWidget {
  final PostView postView;

  /// If set, this is a reply to an existing comment.
  final CommentView? parentComment;

  /// If set, this is editing an existing comment.
  final CommentView? editingComment;

  const CommentComposeScreen({
    super.key,
    required this.postView,
    this.parentComment,
    this.editingComment,
  });

  @override
  ConsumerState<CommentComposeScreen> createState() =>
      _CommentComposeScreenState();
}

class _CommentComposeScreenState extends ConsumerState<CommentComposeScreen> {
  LemmyApiService get _api => ref.read(lemmyApiClientProvider);
  final MarkdownLinkTextController _bodyCtrl = MarkdownLinkTextController();
  final FocusNode _bodyFocus = FocusNode();
  bool _isPosting = false;
  final MediaAttachList _media = MediaAttachList();

  bool get _isReply => widget.parentComment != null;
  bool get _isEditing => widget.editingComment != null;

  List<PersonView> _mentionSuggestions = [];
  bool _isLoadingMentions = false;
  String? _activeMentionQuery;
  int? _activeMentionAtIndex;
  Timer? _mentionDebounce;
  Timer? _autosaveDebounce;

  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    _bodyCtrl.addListener(_onBodyChanged);
    if (widget.editingComment != null) {
      _prefillFromEditingComment(widget.editingComment!);
    } else {
      _loadDraft();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bodyFocus.requestFocus();
    });
  }

  /// Text in the editor, media embeds in the tray — mirrors post edit UX.
  void _prefillFromEditingComment(CommentView commentView) {
    final split = splitPostBodyForEdit(commentView.comment.content);
    if (split.text.isNotEmpty) {
      _bodyCtrl.setRawText(split.text);
    }
    for (final m in split.media) {
      _media.add(UploadItem.remote(url: m.url, isVideo: m.isVideo));
    }
  }

  @override
  void dispose() {
    _bodyCtrl.removeListener(_onBodyChanged);
    _mentionDebounce?.cancel();
    _autosaveDebounce?.cancel();
    _bodyCtrl.dispose();
    _bodyFocus.dispose();
    _media.dispose();
    super.dispose();
  }

  void _onBodyChanged() {
    setState(() {});
    _scheduleAutosave();
    _handleMentionQuery();
  }

  void _scheduleAutosave() {
    if (_isEditing) return;
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(const Duration(milliseconds: 800), () {
      if (!mounted || _isPosting) return;
      if (_bodyCtrl.rawText.trim().isEmpty) return;
      _saveDraft();
    });
  }

  String _getDraftKey() {
    final postId = widget.postView.post.id;
    final parentId = widget.parentComment?.comment.id ?? 0;
    return 'comment_draft_${postId}_$parentId';
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedText = prefs.getString(_getDraftKey());
      if (savedText != null && savedText.isNotEmpty) {
        setState(() {
          _bodyCtrl.setRawText(savedText);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Draft restored'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_getDraftKey(), _bodyCtrl.rawText);
    } catch (_) {}
  }

  Future<void> _deleteDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getDraftKey());
    } catch (_) {}
  }

  Future<bool> _onBackButtonPressed() async {
    if (_isEditing) {
      final unchanged = isCommentEditUnchanged(
        editorRawText: _bodyCtrl.rawText,
        originalContent: widget.editingComment!.comment.content,
        uploads: _media.items,
      );
      if (unchanged) return true;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
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
            'Are you sure you want to discard your changes?',
            style: TextStyle(fontSize: _fontBody, color: _kTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Keep Editing',
                style: TextStyle(
                  color: _kTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
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
      return confirm ?? false;
    }

    if (_bodyCtrl.rawText.trim().isEmpty) {
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
          'You can save this comment as a draft to finish it later.',
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
    }
    if (result == 'save') {
      unawaited(_saveDraft());
      return true;
    }
    return false;
  }

  // ── Mentions ─────────────────────────────────────────────────────────────

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
    } catch (e) {
      if (mounted && _activeMentionQuery == query) {
        setState(() {
          _mentionSuggestions = [];
          _isLoadingMentions = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not search users: ${formatCommentComposeError(e)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
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
      item.error = formatCommentComposeError(e);
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
    _bodyFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    unawaited(
      showMediaAttachSheet(
        context: context,
        list: _media,
        uploadItem: _uploadSingleItem,
        formatError: formatCommentComposeError,
        useRootNavigator: true,
      ),
    );
  }

  Future<void> _showLinkBottomSheet() async {
    final changed = await showMarkdownLinkBottomSheet(
      context: context,
      controller: _bodyCtrl,
      bodyFocus: _bodyFocus,
    );
    if (changed && mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!ref.read(authRepositoryProvider).isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in to post a comment')));
      return;
    }
    if (!canSubmitComment(
      rawBody: _bodyCtrl.rawText,
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
      }
      return;
    }

    final finalContent = assemblePostBody(
      rawBody: _bodyCtrl.rawText,
      uploads: _media.items,
    );

    setState(() => _isPosting = true);

    try {
      final cv = await submitComment(
        repository: ref.read(commentRepositoryProvider),
        content: finalContent,
        postId: widget.postView.post.id,
        parentId: widget.parentComment?.comment.id,
        editingCommentId: widget.editingComment?.comment.id,
      );
      if (!_isEditing) {
        _autosaveDebounce?.cancel();
        unawaited(_deleteDraft());
      }
      if (mounted) {
        _canPop = true;
        Navigator.of(context).pop(cv);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatCommentComposeError(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _contextPlainText(String markdown, {double fontSize = _fontBody}) {
    final plain = markdownToPlainText(markdown);
    if (plain.isEmpty) return const SizedBox.shrink();
    return Text(
      plain,
      style: TextStyle(
        fontSize: fontSize,
        color: _kTextPrimary,
        height: 1.4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return const LoginRequiredScaffold(title: 'Your comment is waiting');
    }
    final bottom = MediaQuery.of(context).padding.bottom;
    // Media badge / Post: rebuild via ListenableBuilder on [_media] only.

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onBackButtonPressed();
        if (shouldPop && mounted) {
          _canPop = true;
          if (context.mounted) Navigator.of(context).pop();
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
                message: 'Images & GIFs',
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
                    final canPost = canSubmitComment(
                      rawBody: _bodyCtrl.rawText,
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
            Expanded(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isReply) ...[
                            Row(
                              children: [
                                NetworkAvatar(
                                  size: 20,
                                  imageUrl: widget.postView.creator.avatar,
                                  name: widget
                                      .postView.creator.displayNameOrName,
                                  backgroundColor: _kSurfaceMuted,
                                  foregroundColor: _kTextSecondary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'u/${widget.postView.creator.displayNameOrName}',
                                    style: const TextStyle(
                                      fontSize: _fontMeta,
                                      fontWeight: FontWeight.w600,
                                      color: _kTextSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Text(
                                  widget.postView.post.name,
                                  style: const TextStyle(
                                    fontSize: _fontBody,
                                    fontWeight: FontWeight.w600,
                                    color: _kTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (!_isReply &&
                              widget.postView.post.body != null &&
                              widget.postView.post.body!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: _contextPlainText(
                                  widget.postView.post.body!,
                                ),
                              ),
                            ),
                          ],
                          if (_isReply)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        NetworkAvatar(
                                          size: 18,
                                          imageUrl: widget
                                              .parentComment!.creator.avatar,
                                          name: widget.parentComment!.creator
                                              .displayNameOrName,
                                          backgroundColor:
                                              _kSurfaceMuted,
                                          foregroundColor:
                                              _kTextSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'u/${widget.parentComment!.creator.displayNameOrName}',
                                            style: const TextStyle(
                                              fontSize: _fontMeta,
                                              fontWeight: FontWeight.w600,
                                              color: _kTextSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    _contextPlainText(
                                      widget.parentComment!.comment.content,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    // Expand the editor to the remaining viewport so taps on
                    // empty space focus the field and open the keyboard —
                    // not only the short placeholder hit-box.
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
                          hintText: 'What are your thoughts?',
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
