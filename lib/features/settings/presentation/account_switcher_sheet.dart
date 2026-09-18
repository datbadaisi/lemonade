import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/app/router/routes.dart';
import 'package:bluerum/features/auth/domain/stored_account.dart';
import 'package:bluerum/features/auth/presentation/auth_controller.dart';
import 'package:bluerum/features/auth/presentation/login_screen.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';
import 'package:bluerum/shared/widgets/avatar/network_avatar.dart';

const Color _textPrimary = Color(0xFF000000);
const Color _textSecondary = Color(0xFF525252);

/// Bottom sheet listing saved accounts and an action to add a new one.
class AccountSwitcherSheet extends ConsumerWidget {
  const AccountSwitcherSheet({super.key, required this.parentContext});

  /// Settings (or other host) context — survives after this sheet is dismissed.
  final BuildContext parentContext;

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AccountSwitcherSheet(parentContext: context),
    );
  }

  /// Return to the profile tab.
  ///
  /// Settings is normally opened with [Navigator.push] from Profile, so a
  /// simple pop reveals Profile again. If Settings was opened as a go_router
  /// location instead, fall back to [GoRouter.go].
  void _returnToProfile() {
    if (!parentContext.mounted) return;
    final navigator = Navigator.of(parentContext);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    parentContext.go(AppRoutes.profile);
  }

  Future<void> _addAccount(BuildContext sheetContext, WidgetRef ref) async {
    Navigator.of(sheetContext).pop();
    if (!parentContext.mounted) return;

    final added = await Navigator.of(parentContext).push<bool>(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(isAddingAccount: true),
      ),
    );
    if (added == true) {
      _returnToProfile();
    }
  }

  Future<void> _switchTo(
    BuildContext sheetContext,
    WidgetRef ref,
    StoredAccount account,
  ) async {
    final auth = ref.read(authRepositoryProvider);
    if (account.id == auth.activeAccountId) {
      Navigator.of(sheetContext).pop();
      return;
    }
    await ref.read(authControllerProvider.notifier).switchAccount(account.id);
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
    _returnToProfile();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    final accounts = auth.accounts;
    final activeId = auth.activeAccountId;
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
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
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Accounts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ),
              if (accounts.isNotEmpty)
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final isActive = account.id == activeId;
                      return ListTile(
                        leading: _AccountAvatar(account: account),
                        title: Text(
                          'u/${account.username}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          account.instanceHost,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textSecondary,
                          ),
                        ),
                        trailing: isActive
                            ? const Icon(
                                MingCuteIcons.mgc_check_circle_fill,
                                color: _textPrimary,
                                size: 22,
                              )
                            : null,
                        onTap: () => _switchTo(context, ref, account),
                      );
                    },
                  ),
                ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    MingCuteIcons.mgc_add_line,
                    color: _textPrimary,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Add new account',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                onTap: () => _addAccount(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.account});

  final StoredAccount account;
  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    // Match post-card mini avatars: shimmer while loading, icon on error —
    // never a letter initial that flashes before the image appears.
    // Short list but still list-kit: gate + budget if user flings accounts.
    return NetworkAvatar.forList(
      size: _size,
      imageUrl: account.avatarUrl,
      fallbackIcon: MingCuteIcons.mgc_user_3_line,
      backgroundColor: const Color(0xFFE0E0E0),
      foregroundColor: _textSecondary,
    );
  }
}
