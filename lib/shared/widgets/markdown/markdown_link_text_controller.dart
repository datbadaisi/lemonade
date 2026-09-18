import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:bluerum/app/theme/app_colors.dart';

/// A markdown inline link as a character range over plain display text.
class LinkEntry {
  final int start;
  final int end;
  final String url;
  const LinkEntry(this.start, this.end, this.url);
}

/// [TextEditingController] that stores display text + link metadata and
/// can reconstruct markdown `[label](url)` via [rawText].
///
/// Links are rendered as accent-color spans in the editor (same weight, no underline).
class MarkdownLinkTextController extends TextEditingController {
  final List<LinkEntry> _links = [];
  String _previousText = '';

  List<LinkEntry> get links => List.unmodifiable(_links);

  /// Reconstructs full Markdown with `[label](url)` syntax.
  String get rawText {
    if (_links.isEmpty) return text;
    final buf = StringBuffer();
    var lastEnd = 0;
    for (final link in _links) {
      if (link.start < lastEnd ||
          link.start > text.length ||
          link.end > text.length ||
          link.start >= link.end) {
        continue;
      }
      buf.write(text.substring(lastEnd, link.start));
      buf.write('[${text.substring(link.start, link.end)}](${link.url})');
      lastEnd = link.end;
    }
    buf.write(text.substring(lastEnd));
    return buf.toString();
  }

  /// Sets controller content from markdown, parsing inline links
  /// (`[label](url)`) while leaving image syntax (`![alt](url)`) intact.
  void setRawText(String markdown) {
    final plain = StringBuffer();
    final parsed = <LinkEntry>[];
    final pattern = RegExp(r'(!?)\[([^\]]*)\]\(([^)]*)\)');
    var last = 0;

    for (final match in pattern.allMatches(markdown)) {
      plain.write(markdown.substring(last, match.start));
      final isImage = match.group(1) == '!';
      final label = match.group(2) ?? '';
      final url = match.group(3) ?? '';

      if (isImage) {
        // Keep image markdown as-is (media is usually attached separately).
        plain.write(match.group(0));
      } else {
        final start = plain.length;
        plain.write(label);
        final end = plain.length;
        if (end > start && url.isNotEmpty) {
          parsed.add(LinkEntry(start, end, url));
        }
      }
      last = match.end;
    }
    plain.write(markdown.substring(last));

    final plainText = plain.toString();
    _links
      ..clear()
      ..addAll(parsed);
    _previousText = plainText;
    super.value = TextEditingValue(
      text: plainText,
      selection: TextSelection.collapsed(offset: plainText.length),
    );
  }

  /// Returns the link entry that contains [offset], or null.
  LinkEntry? getLinkAt(int offset) {
    for (final link in _links) {
      if (offset >= link.start && offset < link.end) return link;
    }
    return null;
  }

  /// Returns the link entry that exactly covers [start..end], or null.
  LinkEntry? getLinkForRange(int start, int end) {
    for (final link in _links) {
      if (link.start == start && link.end == end) return link;
    }
    return null;
  }

  /// Removes the link that exactly covers [start..end].
  bool removeLink(int start, int end) {
    final before = _links.length;
    _links.removeWhere((l) => l.start == start && l.end == end);
    if (_links.length != before) {
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Removes the link at [offset].
  bool removeLinkAt(int offset) {
    final link = getLinkAt(offset);
    if (link == null) return false;
    return removeLink(link.start, link.end);
  }

  /// Removes any links that overlap the given range.
  bool removeLinksOverlapping(int start, int end) {
    final before = _links.length;
    _links.removeWhere((l) => l.start < end && l.end > start);
    if (_links.length != before) {
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Adds a new link at the given range.
  void addLink(int start, int end, String url) {
    if (start < 0 || end > text.length || start >= end) return;
    removeLinksOverlapping(start, end);
    _links.add(LinkEntry(start, end, url));
    _links.sort((a, b) => a.start.compareTo(b.start));
    // Collapse selection after the linked range without going through
    // [value] setter (avoids re-running link adjustment).
    super.value = value.copyWith(
      selection: TextSelection.collapsed(offset: end),
    );
  }

  /// Updates the link at [start..end] with a new URL.
  bool updateLink(int start, int end, String url) {
    for (var i = 0; i < _links.length; i++) {
      if (_links[i].start == start && _links[i].end == end) {
        _links[i] = LinkEntry(start, end, url);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Finds an existing link covering the current selection [selStart..selEnd].
  LinkEntry? findLinkForSelection(int selStart, int selEnd) {
    if (selStart < 0 || selEnd < 0) return null;

    // Collapsed cursor
    if (selStart == selEnd) {
      for (final link in _links) {
        if (selStart >= link.start && selStart < link.end) return link;
      }
      // Cursor sitting right after a linked word → still edit that link.
      for (final link in _links) {
        if (selStart == link.end) return link;
      }
      return null;
    }

    // Exact match
    for (final link in _links) {
      if (link.start == selStart && link.end == selEnd) return link;
    }
    // Fully inside a link
    for (final link in _links) {
      if (selStart >= link.start && selEnd <= link.end) return link;
    }
    // Selection fully covers a link
    for (final link in _links) {
      if (selStart <= link.start && selEnd >= link.end) return link;
    }
    return null;
  }

  /// Inserts or replaces a link using an explicit range (captured before the
  /// link sheet steals focus / clears selection).
  ///
  /// - [rangeStart]..[rangeEnd] is the plain-text range to replace.
  /// - [displayText] becomes the visible label.
  /// - [url] is the destination (should already be normalized).
  void insertOrReplaceLink({
    required int rangeStart,
    required int rangeEnd,
    required String displayText,
    required String url,
  }) {
    final label = displayText.isEmpty ? url : displayText;
    if (label.isEmpty || url.isEmpty) return;

    final safeStart = rangeStart.clamp(0, text.length);
    final safeEnd = rangeEnd.clamp(safeStart, text.length);

    // Drop any links that overlap the old range before the text rewrite so
    // _adjustLinks does not try to preserve stale ranges.
    if (_links.isNotEmpty) {
      _links.removeWhere((l) => l.start < safeEnd && l.end > safeStart);
    }

    final newText = text.replaceRange(safeStart, safeEnd, label);
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: safeStart + label.length),
    );

    addLink(safeStart, safeStart + label.length, url);
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = _previousText;
    _adjustLinks(oldText, newValue.text);
    _previousText = newValue.text;
    super.value = newValue;
  }

  void _adjustLinks(String oldText, String newText) {
    if (oldText == newText || _links.isEmpty) return;

    final commonLen =
        oldText.length < newText.length ? oldText.length : newText.length;
    var editStart = 0;
    while (editStart < commonLen &&
        oldText[editStart] == newText[editStart]) {
      editStart++;
    }

    var editEndOld = oldText.length;
    var editEndNew = newText.length;
    while (editEndOld > editStart &&
        editEndNew > editStart &&
        oldText[editEndOld - 1] == newText[editEndNew - 1]) {
      editEndOld--;
      editEndNew--;
    }

    final newLen = editEndNew - editStart;
    final delta = newLen - (editEndOld - editStart);
    final newLenTotal = newText.length;

    final adjusted = <LinkEntry>[];
    for (final link in _links) {
      if (link.end <= editStart) {
        adjusted.add(link);
      } else if (link.start >= editEndOld) {
        final s = link.start + delta;
        final e = link.end + delta;
        if (e > s && e <= newLenTotal) {
          adjusted.add(LinkEntry(s, e, link.url));
        }
      } else if (editStart >= link.start && editEndOld <= link.end) {
        final newEnd = (link.end + delta).clamp(link.start + 1, newLenTotal);
        if (newEnd > link.start) {
          adjusted.add(LinkEntry(link.start, newEnd, link.url));
        }
      } else if (link.start >= editStart && link.end <= editEndOld) {
        final s = editStart;
        final e = editEndNew;
        if (e > s) {
          adjusted.add(LinkEntry(s, e, link.url));
        }
      } else if (editStart < link.start &&
          editEndOld > link.start &&
          editEndOld <= link.end) {
        final s = editStart + newLen;
        final e = (link.end + delta).clamp(s + 1, newLenTotal);
        if (e > s) {
          adjusted.add(LinkEntry(s, e, link.url));
        }
      } else if (link.start < editStart &&
          link.end > editStart &&
          link.end <= editEndOld) {
        if (link.start < editStart) {
          adjusted.add(LinkEntry(link.start, editStart, link.url));
        }
      }
      // else: complex cross-boundary edit → drop the link
    }

    _links
      ..clear()
      ..addAll(adjusted);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_links.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final linkStyle = (style ?? const TextStyle()).copyWith(
      color: AppColors.action,
      decoration: TextDecoration.none,
    );

    final children = <InlineSpan>[];
    var lastEnd = 0;

    for (final link in _links) {
      if (link.start < lastEnd ||
          link.start > text.length ||
          link.end > text.length ||
          link.start >= link.end) {
        continue;
      }
      if (link.start > lastEnd) {
        children.add(TextSpan(
          text: text.substring(lastEnd, link.start),
          style: style,
        ));
      }
      children.add(TextSpan(
        text: text.substring(link.start, link.end),
        style: linkStyle,
      ));
      lastEnd = link.end;
    }

    if (lastEnd < text.length) {
      children.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return TextSpan(children: children, style: style);
  }
}

/// Normalizes a user-entered URL (adds https:// when missing).
String normalizeMarkdownUrl(String url) {
  var trimmed = url.trim();
  if (trimmed.isEmpty) return trimmed;
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    trimmed = 'https://$trimmed';
  }
  return trimmed;
}

/// Captured text range + optional existing link when the insert sheet opens.
class LinkInsertContext {
  final int rangeStart;
  final int rangeEnd;
  final LinkEntry? existingLink;
  final bool hasSelection;
  final String initialDisplayText;
  final String initialUrl;

  const LinkInsertContext({
    required this.rangeStart,
    required this.rangeEnd,
    required this.existingLink,
    required this.hasSelection,
    required this.initialDisplayText,
    required this.initialUrl,
  });

  bool get isEditingLink => existingLink != null;
}

/// Snapshot of selection + link state before the body field loses focus.
LinkInsertContext captureLinkInsertContext(MarkdownLinkTextController ctrl) {
  final selection = ctrl.selection;
  final text = ctrl.text;
  final hasValidSelection = selection.isValid;
  final selStart = hasValidSelection ? selection.start : text.length;
  final selEnd = hasValidSelection ? selection.end : selStart;
  final hasSelection = hasValidSelection && selStart != selEnd;

  final existingLink = ctrl.findLinkForSelection(selStart, selEnd);

  late final String initialDisplayText;
  late final String initialUrl;
  late final int rangeStart;
  late final int rangeEnd;

  if (existingLink != null && !hasSelection) {
    // Cursor inside an existing link → edit that whole link range.
    rangeStart = existingLink.start;
    rangeEnd = existingLink.end;
    initialDisplayText = text.substring(existingLink.start, existingLink.end);
    initialUrl = existingLink.url;
  } else if (hasSelection) {
    rangeStart = selStart;
    rangeEnd = selEnd;
    initialDisplayText = text.substring(selStart, selEnd);
    // Prefill URL if the selection sits on / covers an existing link.
    initialUrl = existingLink?.url ?? '';
  } else {
    rangeStart = selStart;
    rangeEnd = selEnd;
    initialDisplayText = '';
    initialUrl = '';
  }

  return LinkInsertContext(
    rangeStart: rangeStart,
    rangeEnd: rangeEnd,
    existingLink: existingLink,
    hasSelection: hasSelection,
    initialDisplayText: initialDisplayText,
    initialUrl: initialUrl,
  );
}

/// Shows the insert/edit link bottom sheet and applies the result to [controller].
///
/// Returns true if a change was applied (insert / update / remove).
Future<bool> showMarkdownLinkBottomSheet({
  required BuildContext context,
  required MarkdownLinkTextController controller,
  FocusNode? bodyFocus,
}) async {
  // Capture selection BEFORE unfocus — otherwise many platforms clear it.
  final insertCtx = captureLinkInsertContext(controller);

  // Drop focus cleanly before opening another route (avoids focus-tree /
  // GlobalKey clashes between the body field and the sheet fields).
  bodyFocus?.unfocus();
  FocusManager.instance.primaryFocus?.unfocus();

  final result = await showModalBottomSheet<_LinkSheetResult>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _MarkdownLinkSheet(insertCtx: insertCtx),
  );

  if (result == null) return false;

  if (result.action == _LinkSheetAction.remove) {
    if (insertCtx.existingLink != null) {
      controller.removeLink(
        insertCtx.existingLink!.start,
        insertCtx.existingLink!.end,
      );
      return true;
    }
    return false;
  }

  final url = result.url.trim();
  if (url.isEmpty) return false;

  final displayText = result.displayText.trim();
  final label = displayText.isEmpty ? url : displayText;
  final normalized = normalizeMarkdownUrl(url);

  controller.insertOrReplaceLink(
    rangeStart: insertCtx.rangeStart,
    rangeEnd: insertCtx.rangeEnd,
    displayText: label,
    url: normalized,
  );
  return true;
}

enum _LinkSheetAction { apply, remove }

class _LinkSheetResult {
  final _LinkSheetAction action;
  final String displayText;
  final String url;

  const _LinkSheetResult({
    required this.action,
    this.displayText = '',
    this.url = '',
  });
}

/// Owns its TextEditingControllers + FocusNodes so they are disposed with the
/// route (not in a parent `finally` while the sheet is still animating out).
class _MarkdownLinkSheet extends StatefulWidget {
  final LinkInsertContext insertCtx;

  const _MarkdownLinkSheet({required this.insertCtx});

  @override
  State<_MarkdownLinkSheet> createState() => _MarkdownLinkSheetState();
}

class _MarkdownLinkSheetState extends State<_MarkdownLinkSheet> {
  late final TextEditingController _displayCtrl;
  late final TextEditingController _urlCtrl;
  late final FocusNode _displayFocus;
  late final FocusNode _urlFocus;

  @override
  void initState() {
    super.initState();
    final ctx = widget.insertCtx;
    _displayCtrl = TextEditingController(text: ctx.initialDisplayText);
    _urlCtrl = TextEditingController(text: ctx.initialUrl);
    _displayFocus = FocusNode(debugLabel: 'link-sheet-display');
    _urlFocus = FocusNode(debugLabel: 'link-sheet-url');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ctx.isEditingLink) {
        _urlFocus.requestFocus();
      } else {
        _displayFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _displayFocus.dispose();
    _urlFocus.dispose();
    _displayCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _popApply() {
    Navigator.of(context).pop(
      _LinkSheetResult(
        action: _LinkSheetAction.apply,
        displayText: _displayCtrl.text,
        url: _urlCtrl.text,
      ),
    );
  }

  void _popRemove() {
    Navigator.of(context).pop(
      const _LinkSheetResult(action: _LinkSheetAction.remove),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final insertCtx = widget.insertCtx;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  insertCtx.isEditingLink ? 'Edit Link' : 'Insert Link',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _displayCtrl,
                focusNode: _displayFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _urlFocus.requestFocus(),
                decoration: InputDecoration(
                  hintText: 'Text to display',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF525252).withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFE8E8E8),
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
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlCtrl,
                focusNode: _urlFocus,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _popApply(),
                decoration: InputDecoration(
                  hintText: 'URL',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF525252).withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFE8E8E8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.textPrimary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (insertCtx.isEditingLink)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextButton.icon(
                    onPressed: _popRemove,
                    icon: const Icon(
                      MingCuteIcons.mgc_link_2_line,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    label: const Text(
                      'Remove Link',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _popApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  insertCtx.isEditingLink ? 'Update' : 'Apply',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
