/// Process-wide aspect (width/height) cache for list media.
///
/// Shared by comment list, fullscreen, and row height estimates so reverse
/// fling remounts do not re-probe dimensions.
final Map<String, double> mediaAspectCache = <String, double>{};

double? cachedMediaAspect(String? url) {
  if (url == null || url.isEmpty) return null;
  return mediaAspectCache[url];
}

void putMediaAspect(String url, double aspect) {
  if (url.isEmpty || aspect <= 0 || !aspect.isFinite) return;
  mediaAspectCache[url] = aspect.clamp(0.2, 5.0);
}
