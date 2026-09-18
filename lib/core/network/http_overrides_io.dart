import 'dart:io';

void configureHttpOverrides() {
  HttpOverrides.global = _BluerumHttpOverrides();
}

/// App-wide [HttpClient] for Flutter image loads / dart:io networking.
///
/// Timeouts matter: [ImageDecodeBudget] holds a single process-wide slot while
/// `precacheImage` runs. A hung TCP connect used to pin that slot forever and
/// leave the feed/detail on gray placeholders until process death.
final class _BluerumHttpOverrides extends HttpOverrides {
  static const Duration _connectionTimeout = Duration(seconds: 12);
  static const Duration _idleTimeout = Duration(seconds: 15);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)
      ..userAgent =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
          'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
      ..connectionTimeout = _connectionTimeout
      ..idleTimeout = _idleTimeout;
    return client;
  }
}
