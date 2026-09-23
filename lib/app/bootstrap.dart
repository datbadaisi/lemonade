import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/app.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/http_overrides.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/core/storage/shared_prefs_store.dart';
import 'package:bluerum/features/ads/ads_bootstrap.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/subscription/data/subscription_providers.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Shared ImageCache for every CachedNetworkImage / ResizeImage.
  // In-page stills decode up to 960px (~2× the old 480 tier). Keep a modest
  // bank: enough for a few visible cards without the 128MB reverse-fling
  // OOM that hit mid-range Android. Reverse re-decode beats process death.
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 100;
  imageCache.maximumSizeBytes = 64 << 20;
  configureHttpOverrides();

  final store = await SharedPrefsStore.create();
  final authService = AuthService(store: store);
  await authService.init();

  final container = ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(store),
      authRepositoryProvider.overrideWithValue(authService),
    ],
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const BluerumApp()),
  );

  // Defer Mobile Ads + in-app purchases until after the first two frames so cold
  // start does not race WebView/Dynamite/Billing against first paint
  // (profile: Choreographer "Skipped ~30 frames" on A16 when both ran
  // before runApp returned). InFeedNativeAd awaits [initializeMobileAds].
  WidgetsBinding.instance.addPostFrameCallback((_) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ignore: unawaited_futures
      initializeMobileAds();
      // ignore: unawaited_futures
      container.read(lifetimePurchaseBootstrapProvider.future);
    });
  });

  // After the first frame, refresh canonical person name/id if already logged in
  // (fixes older sessions that stored email as username).
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!authService.isLoggedIn) return;
    // Build a one-shot client matching the active instance for identity refresh.
    final api = LemmyApiService(baseUrl: authService.activeInstanceUrl)
      ..setAuthToken(authService.jwt);
    try {
      await authService.refreshIdentity(api);
    } catch (_) {
      // Non-fatal — keep stored identity.
    } finally {
      api.dispose();
    }
  });
}
