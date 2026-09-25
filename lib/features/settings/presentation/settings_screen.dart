import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/router/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/profile/presentation/saved_posts_screen.dart';
import 'package:bluerum/features/settings/presentation/blocks_screen.dart';
import 'package:bluerum/features/settings/presentation/edit_profile_screen.dart';
import 'package:bluerum/features/settings/presentation/account_switcher_sheet.dart';
import 'package:bluerum/features/settings/presentation/tips_guide_screen.dart';
import 'package:bluerum/features/community/presentation/subscribed_communities_screen.dart';
import 'package:bluerum/shared/widgets/auth/login_required_scaffold.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _textPrimary = Color(0xFF000000);
const Color _textSecondary = Color(0xFF525252);

const String _privacyPolicyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');
const String _termsOfServiceUrl = String.fromEnvironment(
  'TERMS_OF_SERVICE_URL',
);

class SettingsScreen extends ConsumerStatefulWidget {
  final int personId;

  const SettingsScreen({super.key, required this.personId});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  LemmyApiService get _api => ref.read(lemmyApiClientProvider);
  AuthService get _auth => ref.read(authRepositoryProvider);
  String _currentSort = 'New';

  @override
  void initState() {
    super.initState();
    _loadCurrentSort();
  }

  Future<void> _loadCurrentSort() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentSort = prefs.getString('bluerum_profile_sort') ?? 'New';
      });
    }
  }

  Future<void> _changeSort(String newSort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bluerum_profile_sort', newSort);
    if (mounted) {
      setState(() {
        _currentSort = newSort;
      });
    }
  }

  void _showSortSelector() {
    final sortOptions = ['New', 'Old', 'Controversial'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort profile posts & comments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ),
              ...sortOptions.map((sort) {
                final sel = _currentSort == sort;
                return ListTile(
                  leading: Icon(
                    sel
                        ? MingCuteIcons.mgc_check_circle_fill
                        : MingCuteIcons.mgc_round_line,
                    size: 22,
                    color: _textPrimary,
                  ),
                  title: Text(
                    sort,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                  onTap: () {
                    _changeSort(sort);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openExternalUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('URL is not configured.')));
      }
      return;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 13, color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 13,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).pop(); // Go back to profile screen
      await _auth.logout(api: _api);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(authRepositoryProvider).isLoggedIn) {
      return const LoginRequiredScaffold(title: 'Your settings are waiting');
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(MingCuteIcons.mgc_left_line, color: _textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          // Breathing room under Log Out so it isn't flush with the phone edge.
          bottom: MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          // Profile-only sort (posts & comments on profile tabs).
          ListTile(
            leading: const Icon(
              MingCuteIcons.mgc_sort_ascending_line,
              color: _textPrimary,
            ),
            title: const Text(
              'Profile sort',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentSort,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  MingCuteIcons.mgc_right_line,
                  size: 16,
                  color: _textSecondary,
                ),
              ],
            ),
            onTap: _showSortSelector,
          ),
          ListTile(
            leading: const Icon(
              MingCuteIcons.mgc_user_setting_line,
              color: _textPrimary,
            ),
            title: const Text(
              'Edit profile',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_right_line,
              size: 16,
              color: _textSecondary,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          // Saved Items
          ListTile(
            leading: const Icon(
              MingCuteIcons.mgc_bookmark_line,
              color: _textPrimary,
            ),
            title: const Text(
              'Saved',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_right_line,
              size: 16,
              color: _textSecondary,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SavedPostsScreen(personId: widget.personId),
                ),
              );
            },
          ),
          // Subscribed
          ListTile(
            leading: const Icon(
              MingCuteIcons.mgc_group_3_line,
              color: _textPrimary,
            ),
            title: const Text(
              'Subscribed',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_right_line,
              size: 16,
              color: _textSecondary,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      SubscribedCommunitiesScreen(personId: widget.personId),
                ),
              );
            },
          ),
          // Blocks
          ListTile(
            leading: const Icon(
              MingCuteIcons.mgc_forbid_circle_line,
              color: _textPrimary,
            ),
            title: const Text(
              'Blocks',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_right_line,
              size: 16,
              color: _textSecondary,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocksScreen(personId: widget.personId),
                ),
              );
            },
          ),
          // Accounts — switch or add another Lemmy account
          ListTile(
            leading: const Icon(
              MingCuteIcons.mgc_user_add_2_line,
              color: _textPrimary,
            ),
            title: const Text(
              'Add another account',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_right_line,
              size: 16,
              color: _textSecondary,
            ),
            onTap: () => AccountSwitcherSheet.show(context),
          ),
          // Tips — less-obvious gestures and shortcuts
          ListTile(
            leading: const Icon(
              MingCuteIcons.mgc_bulb_line,
              color: _textPrimary,
            ),
            title: const Text(
              'Tips & gestures',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_right_line,
              size: 16,
              color: _textSecondary,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TipsGuideScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_cafe_outlined, color: _textPrimary),
            title: const Text(
              'Lifetime supporter',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_right_line,
              size: 16,
              color: _textSecondary,
            ),
            onTap: () => context.push(AppRoutes.lifetime),
          ),
          ListTile(
            leading: const Icon(
              MingCuteIcons.mgc_safe_lock_line,
              color: _textPrimary,
            ),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_external_link_line,
              size: 16,
              color: _textSecondary,
            ),
            onTap: () => _openExternalUrl(_privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(
              MingCuteIcons.mgc_document_2_line,
              color: _textPrimary,
            ),
            title: const Text(
              'Terms of Service',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_external_link_line,
              size: 16,
              color: _textSecondary,
            ),
            onTap: () => _openExternalUrl(_termsOfServiceUrl),
          ),
          // Log Out
          ListTile(
            leading: const Icon(MingCuteIcons.mgc_exit_line, color: Colors.red),
            title: const Text(
              'Log Out',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.red,
              ),
            ),
            trailing: const Icon(
              MingCuteIcons.mgc_right_line,
              size: 16,
              color: Colors.red,
            ),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}
