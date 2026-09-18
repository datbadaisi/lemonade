import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/utils/error_utils.dart';
import 'package:bluerum/core/utils/media_utils.dart';
import 'package:bluerum/shared/widgets/markdown/markdown_link_text_controller.dart';
import 'package:bluerum/shared/widgets/media/upload_item.dart';

/// Lemmy title length soft limit used by most instances.
const int kPostTitleMaxLength = 200;

/// One media embed split out of post body markdown for the edit form.
class SplitBodyMedia {
  final String url;
  final bool isVideo;

  const SplitBodyMedia({required this.url, required this.isVideo});
}

/// Text + media tray payload after splitting an existing post body for edit.
class SplitPostBodyForEdit {
  final String text;
  final List<SplitBodyMedia> media;

  const SplitPostBodyForEdit({
    required this.text,
    required this.media,
  });
}

/// Markdown image embed: `![alt](url)` (same shape [assemblePostBody] writes).
final _markdownImageEmbed = RegExp(
  r'!\[([^\]]*)\]\((https?://[^)\s]+)\)',
);

/// Splits post body into plain editor text and media-tray attachments.
///
/// Embeds matching `![…](url)` are removed from [text] and listed in [media]
/// (in document order). Matches create-flow UX: text in the field, media in
/// the tray; [assemblePostBody] re-appends embeds on save.
SplitPostBodyForEdit splitPostBodyForEdit(String? body) {
  if (body == null || body.isEmpty) {
    return const SplitPostBodyForEdit(text: '', media: []);
  }

  final media = <SplitBodyMedia>[];
  final seen = <String>{};

  for (final match in _markdownImageEmbed.allMatches(body)) {
    final alt = match.group(1) ?? '';
    final url = match.group(2)!;
    if (!seen.add(url)) continue;
    final isVideo =
        alt.toLowerCase() == 'video' || isVideoUrl(url) || isNativeVideoUrl(url);
    media.add(SplitBodyMedia(url: url, isVideo: isVideo));
  }

  var text = body.replaceAll(_markdownImageEmbed, '');
  // Collapse leftover blank lines from stripped embeds.
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

  return SplitPostBodyForEdit(text: text, media: media);
}

/// Whether current upload URLs match the original split (order-sensitive).
bool sameUploadUrls(
  Iterable<UploadItem> uploads,
  Iterable<SplitBodyMedia> originalMedia,
) {
  final current = uploads
      .where((u) => u.isSuccessful)
      .map((u) => u.url!)
      .toList(growable: false);
  final original = originalMedia.map((m) => m.url).toList(growable: false);
  if (current.length != original.length) return false;
  for (var i = 0; i < current.length; i++) {
    if (current[i] != original[i]) return false;
  }
  return true;
}

/// URL that links cross-posts in Lemmy (shared `url` on [CreatePost]).
///
/// Prefer the original post link when present; otherwise use [apId] so text
/// posts still group under `GetPostResponse.cross_posts`.
String crossPostUrl({required String? url, required String apId}) {
  if (url != null && url.trim().isNotEmpty) return url.trim();
  return apId.trim();
}

/// Whether the create-post form can submit.
bool canCreatePost({
  required String title,
  required bool hasCommunity,
  required bool isPosting,
  required Iterable<UploadItem> uploads,
}) {
  final trimmed = title.trim();
  if (trimmed.isEmpty || trimmed.length > kPostTitleMaxLength) return false;
  if (!hasCommunity || isPosting) return false;
  for (final item in uploads) {
    if (item.isUploading || item.error != null) return false;
  }
  return true;
}

/// Builds the markdown body: editor raw text + successful media embeds.
///
/// Uses each [UploadItem]'s own mime/path (not a reconstructed empty item) so
/// videos are tagged correctly even when the pict-rs URL has no extension.
String assemblePostBody({
  required String rawBody,
  required Iterable<UploadItem> uploads,
}) {
  var bodyText = rawBody.trim();
  final successful = uploads.where((item) => item.isSuccessful).toList();
  if (successful.isEmpty) return bodyText;

  final mediaMarkdown = successful.map((item) {
    final url = item.url!;
    return item.isVideo ? '![video]($url)' : '![image]($url)';
  }).join('\n\n');

  if (bodyText.isEmpty) return mediaMarkdown;
  return '$bodyText\n\n$mediaMarkdown';
}

/// Normalizes the post-level URL field (adds https when scheme is missing).
String? normalizePostUrl(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  return normalizeMarkdownUrl(trimmed);
}

String formatCreatePostError(Object error) => formatError(error);
