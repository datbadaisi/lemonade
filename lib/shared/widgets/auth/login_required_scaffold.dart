import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/features/auth/presentation/login_screen.dart';

/// Blank logged-out fallback matching profile / notifications style:
/// title + Log in button on a white screen.
class LoginRequiredScaffold extends StatelessWidget {
  const LoginRequiredScaffold({
    super.key,
    required this.title,
  });

  final String title;

  static const Color _accent = Color(0xFF000000);
  static const Color _textPrimary = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      minimumSize: const Size(120, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (canPop)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  MingCuteIcons.mgc_left_line,
                  color: _textPrimary,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
