import 'package:bluerum/features/create_post/domain/create_post_helpers.dart';
import 'package:bluerum/shared/widgets/media/upload_item.dart';

/// Whether the comment compose form can submit.
bool canSubmitComment({
  required String rawBody,
  required bool isPosting,
  required Iterable<UploadItem> uploads,
}) {
  if (isPosting) return false;
  for (final item in uploads) {
    if (item.isUploading || item.error != null) return false;
  }
  final content = assemblePostBody(rawBody: rawBody, uploads: uploads);
  return content.trim().isNotEmpty;
}

/// True when the editor content matches the original comment (edit mode).
///
/// Compares [editorRawText] (markdown with `[label](url)`) against the
/// **text half** of [originalContent] after media embeds are split out, and
/// [uploads] against those embeds — same model as post edit.
bool isCommentEditUnchanged({
  required String editorRawText,
  required String originalContent,
  Iterable<UploadItem> uploads = const [],
}) {
  final split = splitPostBodyForEdit(originalContent);
  return editorRawText.trim() == split.text.trim() &&
      sameUploadUrls(uploads, split.media);
}

/// User-facing error copy for comment compose (same mapping as create-post).
String formatCommentComposeError(Object error) => formatCreatePostError(error);
