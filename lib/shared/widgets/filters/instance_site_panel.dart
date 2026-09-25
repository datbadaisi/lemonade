import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/shared/models/site.dart';
import 'package:bluerum/shared/widgets/markdown/bluerum_markdown.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';
import 'package:bluerum/features/profile/presentation/profile_screen.dart';

/// Instance header + scrollable about/stats/admins for the Home filter sheet.
class InstanceSitePanel extends ConsumerStatefulWidget {
  const InstanceSitePanel({
    super.key,
    this.cachedSiteResponse,
    this.onSiteResponseLoaded,
  });

  final GetSiteResponse? cachedSiteResponse;
  final ValueChanged<GetSiteResponse>? onSiteResponseLoaded;

  @override
  ConsumerState<InstanceSitePanel> createState() => _InstanceSitePanelState();
}

class _InstanceSitePanelState extends ConsumerState<InstanceSitePanel> {
  late Future<GetSiteResponse> _siteFuture;

  @override
  void initState() {
    super.initState();
    if (widget.cachedSiteResponse != null) {
      _siteFuture = Future.value(widget.cachedSiteResponse);
    } else {
      _siteFuture = Future(() async {
        final res = await ref.read(lemmyApiClientProvider).getSite();
        widget.onSiteResponseLoaded?.call(res);
        return res;
      });
    }
  }

  String get _baseUrl => ref.read(authRepositoryProvider).activeInstanceUrl;

  String _getHostname(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostname = _getHostname(_baseUrl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Instance Info Header
          FutureBuilder<GetSiteResponse>(
            future: _siteFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Skeleton.circle(size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Skeleton(
                            height: 16,
                            width: 120,
                            borderRadius: 4,
                          ),
                          const SizedBox(height: 6),
                          const Skeleton(
                            height: 12,
                            width: 80,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Skeleton(height: 22, width: 72, borderRadius: 12),
                  ],
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFE8E8E8),
                      child: Icon(
                        MingCuteIcons.mgc_globe_line,
                        color: Color(0xFF525252),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hostname,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF000000),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Lemmy Instance',
                            style: TextStyle(
                              color: Color(0xFF525252),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SupportLemmyBadge(),
                  ],
                );
              }

              final site = snapshot.data!.siteView.site;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NetworkAvatar(
                    size: 48,
                    imageUrl: site.icon,
                    fallbackIcon: MingCuteIcons.mgc_globe_line,
                    backgroundColor: const Color(0xFFE8E8E8),
                    foregroundColor: const Color(0xFF525252),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          site.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF000000),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hostname,
                          style: const TextStyle(
                            color: Color(0xFF525252),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SupportLemmyBadge(),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Scrollable area for instance detail information
          Expanded(
            child: FutureBuilder<GetSiteResponse>(
              future: _siteFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    children: [
                      // Banner skeleton
                      const Skeleton(
                        height: 110,
                        width: double.infinity,
                        borderRadius: 8,
                      ),
                      const SizedBox(height: 16),
                      // Description skeleton lines
                      const Skeleton(height: 12, width: double.infinity),
                      const SizedBox(height: 8),
                      const Skeleton(height: 12, width: 220),
                      const SizedBox(height: 24),
                      // Stats skeleton title & blocks
                      const Skeleton(height: 14, width: 80),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: List.generate(
                          6,
                          (index) => const Skeleton(height: 14, width: 70),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Admins skeleton title & blocks
                      const Skeleton(height: 14, width: 120),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Skeleton.circle(size: 20),
                          const SizedBox(width: 8),
                          const Skeleton(height: 12, width: 80),
                          const SizedBox(width: 24),
                          const Skeleton.circle(size: 20),
                          const SizedBox(width: 8),
                          const Skeleton(height: 12, width: 80),
                        ],
                      ),
                    ],
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final response = snapshot.data!;
                final siteView = response.siteView;
                final site = siteView.site;
                final counts = siteView.counts;
                final admins = response.admins;
                final version = response.version;

                const Color localTextPrimary = Color(0xFF000000);
                const Color localTextSecondary = Color(0xFF525252);
                const Color localBorderLight = Color(0xFFE0E0E0);

                Widget buildFlatStatInline(String value, String label) {
                  return RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: localTextPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: '$value ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: label,
                          style: const TextStyle(color: localTextSecondary),
                        ),
                      ],
                    ),
                  );
                }

                String formatNumber(int number) {
                  if (number >= 1000000) {
                    return '${(number / 1000000).toStringAsFixed(1)}M';
                  } else if (number >= 1000) {
                    return '${(number / 1000).toStringAsFixed(1)}K';
                  }
                  return number.toString();
                }

                Widget buildLetterAvatar(String title, double size) {
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

                return ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  children: [
                    // Header Banner of the instance
                    if (site.banner != null && site.banner!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: site.banner!,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                              const ShimmerPlaceholder(
                                height: 110,
                                width: double.infinity,
                              ),
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Version info if available
                    if (version.isNotEmpty) ...[
                      Text(
                        'Version: $version',
                        style: const TextStyle(
                          fontSize: 12,
                          color: localTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Short description
                    if (site.description != null &&
                        site.description!.trim().isNotEmpty) ...[
                      Text(
                        site.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: localTextSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Sidebar / About rules
                    if (site.sidebar != null &&
                        site.sidebar!.trim().isNotEmpty) ...[
                      const Text(
                        'About & Rules',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: localTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BluerumMarkdown(
                        data: site.sidebar!,
                        onTapLink: (text, href, title) {
                          if (href != null)
                            launchUrl(
                              Uri.parse(href),
                              mode: LaunchMode.externalApplication,
                            );
                        },
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            fontSize: 13,
                            color: localTextPrimary,
                            height: 1.5,
                          ),
                          a: BluerumMarkdownStyles.link(fontSize: 14),
                          code: BluerumMarkdownStyles.code(
                            fontSize: 12,
                            color: localTextPrimary,
                          ),
                          codeblockDecoration:
                              BluerumMarkdownStyles.codeblockDecoration,
                          blockquoteDecoration: const RoundedBorderDecoration(
                            color: Color(0xFFE0E0E0),
                            width: 3,
                            isHorizontal: false,
                          ),
                          blockquotePadding: const EdgeInsets.only(
                            left: 12,
                            top: 2,
                            bottom: 2,
                          ),
                          horizontalRuleDecoration:
                              const RoundedBorderDecoration(
                                color: Color(0xFFE0E0E0),
                                width: 2,
                                isHorizontal: true,
                              ),
                          h1: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: localTextPrimary,
                          ),
                          h2: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: localTextPrimary,
                          ),
                          h3: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: localTextPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Statistics
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: localTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        buildFlatStatInline(
                          formatNumber(counts.users),
                          'users',
                        ),
                        buildFlatStatInline(
                          formatNumber(counts.communities),
                          'communities',
                        ),
                        buildFlatStatInline(
                          formatNumber(counts.posts),
                          'posts',
                        ),
                        buildFlatStatInline(
                          formatNumber(counts.comments),
                          'comments',
                        ),
                        buildFlatStatInline(
                          formatNumber(counts.usersActiveDay),
                          'active/day',
                        ),
                        buildFlatStatInline(
                          formatNumber(counts.usersActiveWeek),
                          'active/week',
                        ),
                        buildFlatStatInline(
                          formatNumber(counts.usersActiveMonth),
                          'active/month',
                        ),
                        buildFlatStatInline(
                          formatNumber(counts.usersActiveHalfYear),
                          'active/6m',
                        ),
                      ],
                    ),

                    // Site Admins List
                    if (admins.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Site Administrators',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: localTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: admins.map((adminData) {
                          final adminView = PersonView.fromJson(
                            adminData as Map<String, dynamic>,
                          );
                          final admin = adminView.person;
                          final hasAvatar = admin.avatar != null;
                          final adminDisplayName =
                              admin.displayName != null &&
                                  admin.displayName!.trim().isNotEmpty
                              ? admin.displayName!
                              : admin.name;
                          final adminDomain =
                              Uri.tryParse(admin.actorId)?.host ??
                              'lemmy.world';
                          final federatedUsername =
                              '${admin.name}@$adminDomain';

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(
                                    username: federatedUsername,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  NetworkAvatar(
                                    size: 20,
                                    imageUrl: hasAvatar ? admin.avatar : null,
                                    name: adminDisplayName,
                                    fallback: buildLetterAvatar(
                                      adminDisplayName,
                                      20,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'u/${admin.name}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: localTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),


      ],
    );
  }
}

class SupportLemmyBadge extends StatelessWidget {
  const SupportLemmyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Donate to the Lemmy open-source project',
      child: GestureDetector(
        onTap: () {
          launchUrl(
            Uri.parse('https://join-lemmy.org/donate'),
            mode: LaunchMode.externalApplication,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MingCuteIcons.mgc_heart_fill,
                size: 10,
                color: Color(0xFFE11D48),
              ),
              SizedBox(width: 3),
              Text(
                // Short, project-scoped — not "support this instance".
                'Fund Lemmy',
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

