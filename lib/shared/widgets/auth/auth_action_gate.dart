import 'package:flutter/material.dart';

import 'package:bluerum/features/auth/data/auth_repository.dart';

/// Shared login snackbars for vote/save and similar gated actions.
///
/// Returns `true` when the user is logged in and the action may proceed.
bool requireLogin(
  BuildContext context,
  AuthService auth, {
  required String message,
}) {
  if (auth.isLoggedIn) return true;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
  return false;
}

void showActionFailedSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
