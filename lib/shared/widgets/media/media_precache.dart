import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

/// Shared wall-clock limit for still precache / decode-slot jobs.
/// [ImageDecodeBudget.jobTimeout] reads this value.
const Duration mediaPrecacheTimeout = Duration(seconds: 12);

/// Decode width for in-page stills (feed cards, detail hero, comments).
///
/// Single policy so feed paint, feed precache, and detail hero share one
/// ImageCache key. Cap 960; full-screen viewers use a higher width.
int inPageMediaMemCacheWidth(BuildContext context) {
  final logical = MediaQuery.sizeOf(context).width.clamp(1.0, 480.0);
  final dpr = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.5);
  return (logical * dpr).round().clamp(1, 960);
}

/// Provider key matching [NetworkMediaImage] / [CachedNetworkImage] + width.
ImageProvider mediaImageProvider(String url, {required int cacheWidth}) =>
    ResizeImage(CachedNetworkImageProvider(url), width: cacheWidth);

/// Warm a single still into the same cache key used at paint.
///
/// Hard [timeout] so idle precache loops cannot hang forever on a bad URL.
Future<void> precacheMediaImage(
  BuildContext context,
  String url, {
  int? cacheWidth,
  Duration? timeout,
}) {
  if (url.isEmpty) return Future.value();
  final width = cacheWidth ?? inPageMediaMemCacheWidth(context);
  final future = precacheImage(
    mediaImageProvider(url, cacheWidth: width),
    context,
    onError: (_, _) {},
  );
  final limit = timeout ?? mediaPrecacheTimeout;
  return future.timeout(limit, onTimeout: () {});
}

/// Warms nearby still images before the user swipes to them.
void precacheMediaAround(
  BuildContext context,
  List<String> urls,
  int index, {
  required int cacheWidth,
  int radius = 2,
}) {
  for (
    var candidate = index - radius;
    candidate <= index + radius;
    candidate++
  ) {
    if (candidate < 0 || candidate >= urls.length) continue;
    final url = urls[candidate];
    if (url.isEmpty) continue;
    unawaited(
      precacheMediaImage(context, url, cacheWidth: cacheWidth),
    );
  }
}
